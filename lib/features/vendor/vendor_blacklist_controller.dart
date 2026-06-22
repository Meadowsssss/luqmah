import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/vendor.dart';
import '../session/session_controller.dart';
import 'vendor_data_controller.dart';
import 'vendor_repository.dart';

class VendorBlacklistController
    extends AsyncNotifier<List<VendorBlacklistEntry>> {
  VendorRepository get _repository => ref.read(vendorRepositoryProvider);

  @override
  Future<List<VendorBlacklistEntry>> build() async {
    final token = ref.watch(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      return const <VendorBlacklistEntry>[];
    }

    return _repository.loadBlacklist(token);
  }

  Future<void> refreshSilently() async {
    final previous = state.value;
    final next = await AsyncValue.guard(build);
    if (previous != null && next.hasError) {
      return;
    }
    state = next;
  }

  Future<void> blacklistCustomer({
    required String customerId,
    String? reason,
  }) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    final entry = await _repository.blacklistCustomer(
      token: token,
      customerId: customerId,
      reason: reason,
    );

    final currentEntries = state.value ?? const <VendorBlacklistEntry>[];
    state = AsyncData([
      entry,
      ...currentEntries.where((item) => item.customerId != customerId),
    ]);
    await ref.read(vendorDataControllerProvider.notifier).refreshSilently();
  }

  Future<void> removeCustomer(String customerId) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Vendor session is required');
    }

    final removedCustomerId = await _repository.removeBlacklistCustomer(
      token: token,
      customerId: customerId,
    );

    final currentEntries = state.value ?? const <VendorBlacklistEntry>[];
    state = AsyncData(
      currentEntries
          .where((entry) => entry.customerId != removedCustomerId)
          .toList(growable: false),
    );
  }
}

final vendorBlacklistControllerProvider =
    AsyncNotifierProvider<
      VendorBlacklistController,
      List<VendorBlacklistEntry>
    >(VendorBlacklistController.new);

final vendorBlacklistEntryByCustomerIdProvider =
    Provider.family<AsyncValue<VendorBlacklistEntry?>, String>((
      ref,
      customerId,
    ) {
      final state = ref.watch(vendorBlacklistControllerProvider);
      return state.whenData((entries) {
        for (final entry in entries) {
          if (entry.customerId == customerId) {
            return entry;
          }
        }
        return null;
      });
    });
