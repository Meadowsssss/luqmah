import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'session_models.dart';
import 'session_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance);
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

final sessionControllerProvider = ChangeNotifierProvider<SessionController>((
  ref,
) {
  final controller = SessionController(
    authRepository: ref.watch(authRepositoryProvider),
    sessionRepository: ref.watch(sessionRepositoryProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});

class SessionController extends ChangeNotifier {
  SessionController({
    required AuthRepository authRepository,
    required SessionRepository sessionRepository,
  }) : _authRepository = authRepository,
       _sessionRepository = sessionRepository {
    _subscription = _authRepository.authStateChanges().listen((_) {
      refresh();
    });
    refresh();
  }

  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;
  late final StreamSubscription<User?> _subscription;

  SessionSnapshot _snapshot = SessionSnapshot.loading();

  SessionSnapshot get snapshot => _snapshot;

  Future<void> refresh() async {
    final previous = _snapshot;
    _snapshot = previous.copyWith(isLoading: true);
    notifyListeners();
    _snapshot = await _sessionRepository.buildSnapshot(_authRepository.currentUser);
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    await _sessionRepository.clearVendorDemoAccess();
    await _authRepository.login(email: email, password: password);
    await refresh();
  }

  Future<void> registerCustomer({
    required String email,
    required String password,
  }) async {
    await _sessionRepository.clearVendorDemoAccess();
    final credential = await _authRepository.register(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      await _sessionRepository.setRoleForUser(user, AppRole.customer);
      await user.sendEmailVerification();
    }
    await refresh();
  }

  Future<void> continueAsVendorDemo() async {
    await _sessionRepository.enableVendorDemoAccess();
    await refresh();
  }

  Future<void> resendVerification() async {
    await _authRepository.sendEmailVerification();
  }

  Future<void> reloadVerification() async {
    await _authRepository.reloadCurrentUser();
    await refresh();
  }

  Future<void> logout() async {
    await _sessionRepository.clearVendorDemoAccess();
    if (_authRepository.currentUser != null) {
      await _authRepository.logout();
    }
    await refresh();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
