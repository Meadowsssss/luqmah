import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'backend_auth_repository.dart';
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
    backendAuthRepository: ref.watch(backendAuthRepositoryProvider),
    sessionRepository: ref.watch(sessionRepositoryProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});

class SessionController extends ChangeNotifier {
  SessionController({
    required AuthRepository authRepository,
    required BackendAuthRepository backendAuthRepository,
    required SessionRepository sessionRepository,
  }) : _authRepository = authRepository,
       _backendAuthRepository = backendAuthRepository,
       _sessionRepository = sessionRepository {
    _subscription = _authRepository.authStateChanges().listen((_) {
      refresh();
    });
    refresh(showLoading: true);
  }

  final AuthRepository _authRepository;
  final BackendAuthRepository _backendAuthRepository;
  final SessionRepository _sessionRepository;
  late final StreamSubscription<User?> _subscription;

  SessionSnapshot _snapshot = SessionSnapshot.loading();

  SessionSnapshot get snapshot => _snapshot;

  Future<void> refresh({bool showLoading = false}) async {
    if (showLoading) {
      final previous = _snapshot;
      _snapshot = previous.copyWith(
        isLoading: true,
        clearCustomerSyncError: true,
      );
      notifyListeners();
    }

    final next = await _sessionRepository.buildSnapshot(
      _authRepository.currentUser,
    );
    _snapshot = next;
    notifyListeners();

    await _syncCustomerBackendSessionIfNeeded();
  }

  Future<void> login({required String email, required String password}) async {
    await _sessionRepository.clearBackendSession();

    try {
      if (_authRepository.currentUser != null) {
        await _authRepository.logout();
      }

      await _authRepository.login(email: email, password: password);
      await _authRepository.reloadCurrentUser();

      if (_authRepository.currentUser?.emailVerified ?? false) {
        await _syncCustomerBackendSessionIfNeeded(
          forceRefreshFirebaseToken: true,
          rethrowOnFailure: true,
        );
      } else {
        await refresh();
      }
    } catch (error) {
      if (_authRepository.currentUser != null) {
        await _authRepository.logout();
      }
      await _sessionRepository.clearBackendSession();
      rethrow;
    }
  }

  Future<void> loginVendor({
    required String email,
    required String password,
  }) async {
    await _sessionRepository.clearBackendSession();
    if (_authRepository.currentUser != null) {
      await _authRepository.logout();
    }

    final session = await _backendAuthRepository.loginVendor(
      email: email,
      password: password,
    );
    await _sessionRepository.saveBackendSession(session);
    await refresh();
  }

  Future<void> loginAdmin({
    required String email,
    required String password,
  }) async {
    await _sessionRepository.clearBackendSession();
    if (_authRepository.currentUser != null) {
      await _authRepository.logout();
    }

    final session = await _backendAuthRepository.loginAdmin(
      email: email,
      password: password,
    );
    await _sessionRepository.saveBackendSession(session);
    await refresh();
  }

  Future<void> registerCustomer({
    required String email,
    required String password,
  }) async {
    await _sessionRepository.clearBackendSession();

    try {
      if (_authRepository.currentUser != null) {
        await _authRepository.logout();
      }

      final credential = await _authRepository.register(
        email: email,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      await refresh();
    } catch (error) {
      final user = _authRepository.currentUser;
      if (user != null) {
        await user.delete();
      }
      await _sessionRepository.clearBackendSession();
      rethrow;
    }
  }

  Future<void> resendVerification() async {
    await _authRepository.sendEmailVerification();
  }

  Future<void> reloadVerification() async {
    await _authRepository.reloadCurrentUser();

    if (_authRepository.currentUser?.emailVerified ?? false) {
      await _syncCustomerBackendSessionIfNeeded(
        forceRefreshFirebaseToken: true,
        rethrowOnFailure: true,
      );
      return;
    }

    await refresh();
  }

  Future<void> sendCustomerPasswordResetEmail(String email) async {
    await _authRepository.sendPasswordResetEmail(email.trim());
  }

  Future<void> changeCustomerPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _authRepository.changeCustomerPassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> updateCustomerPhoneNumber(String phoneNumber) async {
    final session = _snapshot.backendSession;
    if (session == null || session.token.isEmpty) {
      throw StateError(
        'A backend session is required to update this phone number.',
      );
    }

    final updatedPhoneNumber = await _backendAuthRepository
        .updateCustomerPhoneNumber(
          token: session.token,
          phoneNumber: phoneNumber,
        );
    final updatedSession = session.copyWith(
      user: session.user.copyWith(phoneNumber: updatedPhoneNumber),
    );

    await _sessionRepository.saveBackendSession(updatedSession);
    _snapshot = _snapshot.copyWith(backendSession: updatedSession);
    notifyListeners();
  }

  Future<void> changeVendorPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = _snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError(
        'A backend session is required to change this password.',
      );
    }

    await _backendAuthRepository.changeBackendPassword(
      token: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    await _sessionRepository.clearBackendSession();
    if (_authRepository.currentUser != null) {
      await _authRepository.logout();
    }
    await refresh();
  }

  Future<void> _syncCustomerBackendSessionIfNeeded({
    bool forceRefreshFirebaseToken = false,
    bool rethrowOnFailure = false,
  }) async {
    final firebaseUser = _authRepository.currentUser;
    if (firebaseUser == null) {
      return;
    }

    if (!(firebaseUser.emailVerified)) {
      await _sessionRepository.clearBackendSession();
      final next = await _sessionRepository.buildSnapshot(firebaseUser);
      _snapshot = next.copyWith(clearCustomerSyncError: true);
      notifyListeners();
      return;
    }

    final currentBackendSession = _snapshot.backendSession;
    if (currentBackendSession != null &&
        currentBackendSession.user.role == 'CUSTOMER' &&
        !forceRefreshFirebaseToken) {
      return;
    }

    try {
      final idToken = await _authRepository.getIdToken(
        forceRefresh: forceRefreshFirebaseToken,
      );
      final backendSession = await _backendAuthRepository
          .syncCustomerWithFirebase(idToken: idToken);
      await _sessionRepository.saveBackendSession(backendSession);
      _snapshot = SessionSnapshot(
        firebaseUser: _authRepository.currentUser,
        backendSession: backendSession,
        role: AppRole.customer,
        isLoading: false,
      );
      notifyListeners();
    } catch (error) {
      await _sessionRepository.clearBackendSession();
      _snapshot = SessionSnapshot(
        firebaseUser: _authRepository.currentUser,
        backendSession: null,
        role: AppRole.customer,
        isLoading: false,
        customerSyncError: error.toString(),
      );
      notifyListeners();

      if (rethrowOnFailure) {
        rethrow;
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
