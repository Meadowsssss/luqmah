import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/customer/data/restaurant_repository.dart';
import '../../features/customer/orders/customer_orders_controller.dart';
import '../../features/session/session_controller.dart';
import '../../features/session/session_models.dart';
import '../../features/vendor/vendor_data_controller.dart';
import 'realtime_event.dart';
import 'realtime_service.dart';

final realtimeSyncControllerProvider = Provider<void>((ref) {
  final service = ref.watch(realtimeServiceProvider);

  void syncSession() {
    final snapshot = ref.read(sessionControllerProvider).snapshot;
    final token = snapshot.backendToken;
    if (token == null || token.isEmpty) {
      service.disconnect();
      return;
    }
    service.connect(token);
  }

  syncSession();
  ref.listen(sessionControllerProvider, (_, __) => syncSession());

  final lifecycleObserver = _RealtimeLifecycleObserver(
    onResume: syncSession,
    onSuspend: service.disconnect,
  );
  WidgetsBinding.instance.addObserver(lifecycleObserver);

  final subscription = service.events.listen((event) {
    handleRealtimeEvent(ref, event);
  });

  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(lifecycleObserver);
    subscription.cancel();
    service.disconnect();
  });
});

class _RealtimeLifecycleObserver extends WidgetsBindingObserver {
  _RealtimeLifecycleObserver({required this.onResume, required this.onSuspend});

  final VoidCallback onResume;
  final VoidCallback onSuspend;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        onSuspend();
        break;
    }
  }
}

void handleRealtimeEvent(Ref ref, RealtimeEvent event) {
  final snapshot = ref.read(sessionControllerProvider).snapshot;
  if (snapshot.role == AppRole.vendor &&
      event.type == RealtimeEventTypes.orderCreated) {
    unawaited(SystemSound.play(SystemSoundType.alert));
  }
  final actions = actionsForRealtimeEvent(snapshot.role, event);
  if (actions.isEmpty) {
    return;
  }

  if (actions.contains(RealtimeSyncAction.refreshCustomerOrders)) {
    unawaited(ref.read(customerOrdersControllerProvider.notifier).applyRealtimeEvent(event));
  }
  if (actions.contains(RealtimeSyncAction.refreshVendorData)) {
    unawaited(ref.read(vendorDataControllerProvider.notifier).applyRealtimeEvent(event));
  }
  if (actions.contains(RealtimeSyncAction.refreshRestaurants)) {
    final restaurantId = event.restaurantId;
    final isBusy = event.isBusy;
    if (event.type == RealtimeEventTypes.restaurantUpdated &&
        restaurantId != null &&
        isBusy != null) {
      ref.read(restaurantsProvider.notifier).patchBusyState(restaurantId, isBusy);
    } else {
      unawaited(ref.read(restaurantsProvider.notifier).refreshSilently());
    }
  }
  if (actions.contains(RealtimeSyncAction.refreshRestaurantDetail)) {
    final restaurantId = event.restaurantId;
    if (restaurantId != null && restaurantId.isNotEmpty) {
      final isBusy = event.isBusy;
      final detailController = ref.read(restaurantByIdProvider(restaurantId).notifier);
      if (event.type == RealtimeEventTypes.restaurantUpdated && isBusy != null) {
        detailController.patchBusyState(isBusy);
      } else {
        unawaited(detailController.refreshSilently());
      }
    }
  }
}

enum RealtimeSyncAction {
  refreshCustomerOrders,
  refreshVendorData,
  refreshRestaurants,
  refreshRestaurantDetail,
}

Set<RealtimeSyncAction> actionsForRealtimeEvent(
  AppRole role,
  RealtimeEvent event,
) {
  switch (event.type) {
    case RealtimeEventTypes.ready:
      return const <RealtimeSyncAction>{};
    case RealtimeEventTypes.orderCreated:
    case RealtimeEventTypes.orderUpdated:
      if (role == AppRole.customer) {
        return const {RealtimeSyncAction.refreshCustomerOrders};
      }
      if (role == AppRole.vendor) {
        return const {RealtimeSyncAction.refreshVendorData};
      }
      return const <RealtimeSyncAction>{};
    case RealtimeEventTypes.restaurantUpdated:
    case RealtimeEventTypes.menuUpdated:
    case RealtimeEventTypes.ratingCreated:
      final actions = <RealtimeSyncAction>{
        RealtimeSyncAction.refreshRestaurants,
        if (event.restaurantId != null && event.restaurantId!.isNotEmpty)
          RealtimeSyncAction.refreshRestaurantDetail,
      };
      if (role == AppRole.vendor) {
        actions.add(RealtimeSyncAction.refreshVendorData);
      }
      if (event.type == RealtimeEventTypes.ratingCreated &&
          role == AppRole.customer) {
        actions.add(RealtimeSyncAction.refreshCustomerOrders);
      }
      return actions;
    default:
      return const <RealtimeSyncAction>{};
  }
}
