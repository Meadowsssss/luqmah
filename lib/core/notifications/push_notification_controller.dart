import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router/app_router.dart';
import '../../features/session/backend_auth_repository.dart';
import '../../features/session/session_controller.dart';

final pushNotificationControllerProvider = Provider<void>((ref) {
  if (const bool.fromEnvironment('FLUTTER_TEST') ||
      kIsWeb ||
      defaultTargetPlatform != TargetPlatform.android) {
    return;
  }

  final controller = _PushNotificationController(ref);
  controller.start();
  ref.onDispose(controller.dispose);
});

class _PushNotificationController {
  _PushNotificationController(this._ref);

  final Ref _ref;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  String? _registeredPushToken;
  String? _registeredBackendToken;
  bool _started = false;

  void start() {
    if (_started) {
      return;
    }
    _started = true;

    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) {
      unawaited(_registerCurrentToken(token));
    });
    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessageTap,
    );
    unawaited(_handleInitialMessage());
    unawaited(_syncWithSession());

    _ref.listen(sessionControllerProvider, (previous, next) {
      final previousBackendToken = previous?.snapshot.backendToken;
      final nextBackendToken = next.snapshot.backendToken;
      if (previousBackendToken != null &&
          previousBackendToken.isNotEmpty &&
          (nextBackendToken == null || nextBackendToken.isEmpty)) {
        unawaited(_unregisterCurrentToken(previousBackendToken));
      }
      unawaited(_syncWithSession());
    });
  }

  Future<void> _syncWithSession() async {
    final backendToken = _ref.read(sessionControllerProvider).snapshot.backendToken;
    if (backendToken == null || backendToken.isEmpty) {
      _registeredBackendToken = null;
      return;
    }

    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) {
      return;
    }
    await _registerCurrentToken(token);
  }

  Future<void> _registerCurrentToken(String pushToken) async {
    final backendToken = _ref.read(sessionControllerProvider).snapshot.backendToken;
    if (backendToken == null || backendToken.isEmpty) {
      return;
    }
    if (_registeredPushToken == pushToken &&
        _registeredBackendToken == backendToken) {
      return;
    }

    await _ref.read(backendAuthRepositoryProvider).registerPushToken(
          token: backendToken,
          pushToken: pushToken,
          platform: 'android',
        );
    _registeredPushToken = pushToken;
    _registeredBackendToken = backendToken;
  }

  Future<void> _unregisterCurrentToken(String backendToken) async {
    final pushToken = _registeredPushToken ?? await _messaging.getToken();
    if (pushToken == null || pushToken.isEmpty) {
      _registeredBackendToken = null;
      return;
    }

    await _ref.read(backendAuthRepositoryProvider).unregisterPushToken(
          token: backendToken,
          pushToken: pushToken,
          platform: 'android',
        );
    _registeredPushToken = null;
    _registeredBackendToken = null;
  }

  Future<void> _handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      _handleMessageTap(message);
    }
  }

  void _handleMessageTap(RemoteMessage message) {
    final target = message.data['target'];
    final router = _ref.read(appRouterProvider);
    switch (target) {
      case 'vendor_orders':
        router.go('/vendor/orders');
        return;
      case 'customer_orders':
        router.go('/settings/orders');
        return;
    }
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _messageOpenedSubscription?.cancel();
  }
}
