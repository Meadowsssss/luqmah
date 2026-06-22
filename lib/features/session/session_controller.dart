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
  static const _minimumStartupLoadingDuration = Duration(seconds: 2);

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
  PendingCustomerProfile? _pendingProfile;

  SessionSnapshot get snapshot => _snapshot;
  PendingCustomerProfile? get pendingProfile => _pendingProfile;

  Future<void> refresh({bool showLoading = false}) async {
    if (showLoading) {
      final previous = _snapshot;
      _snapshot = previous.copyWith(
        isLoading: true,
        clearCustomerSyncError: true,
      );
      notifyListeners();
    }

    final minimumLoading = showLoading
        ? Future<void>.delayed(_minimumStartupLoadingDuration)
        : null;
    final next = await _sessionRepository.buildSnapshot(
      _authRepository.currentUser,
    );
    if (minimumLoading != null) {
      await minimumLoading;
    }
    _snapshot = next;
    _pendingProfile = await _sessionRepository.loadPendingCustomerProfile();
    notifyListeners();

    await _syncCustomerBackendSessionIfNeeded();
  }

  Future<void> login({required String email, required String password}) async {
    final normalizedEmail = email.trim();
    await _sessionRepository.clearBackendSession();
    await _sessionRepository.clearPendingCustomerProfile();

    try {
      if (_authRepository.currentUser != null) {
        await _authRepository.logout();
      }

      await _authRepository.login(email: normalizedEmail, password: password);
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
    final normalizedEmail = email.trim();
    await _sessionRepository.clearBackendSession();
    await _sessionRepository.clearPendingCustomerProfile();
    if (_authRepository.currentUser != null) {
      await _authRepository.logout();
    }

    final session = await _backendAuthRepository.loginVendor(
      email: normalizedEmail,
      password: password,
    );
    await _sessionRepository.saveBackendSession(session);
    await refresh();
  }

  Future<void> loginAdmin({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    await _sessionRepository.clearBackendSession();
    await _sessionRepository.clearPendingCustomerProfile();
    if (_authRepository.currentUser != null) {
      await _authRepository.logout();
    }

    final session = await _backendAuthRepository.loginAdmin(
      email: normalizedEmail,
      password: password,
    );
    await _sessionRepository.saveBackendSession(session);
    await refresh();
  }

  Future<void> registerCustomer({
    required String name,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    final normalizedName = name.trim();
    final normalizedPhoneNumber = phoneNumber.trim();
    final normalizedEmail = email.trim();
    await _sessionRepository.clearBackendSession();
    await _sessionRepository.clearPendingCustomerProfile();

    try {
      if (_authRepository.currentUser != null) {
        await _authRepository.logout();
      }

      final profile = PendingCustomerProfile(
        name: normalizedName,
        phoneNumber: normalizedPhoneNumber,
        email: normalizedEmail,
        password: password,
      );
      await _sessionRepository.savePendingCustomerProfile(profile);

      final actionCodeSettings = ActionCodeSettings(
        url: 'https://luqmah-14bc5.firebaseapp.com/verify-email',
        handleCodeInApp: true,
        androidPackageName: 'com.example.flutter_application_1',
        androidInstallApp: true,
        androidMinimumVersion: '12',
        iOSBundleId: 'com.example.flutterApplication1',
      );

      await _authRepository.sendSignInLinkToEmail(
        email: normalizedEmail,
        actionCodeSettings: actionCodeSettings,
      );

      await refresh();
    } catch (error) {
      await _sessionRepository.clearBackendSession();
      await _sessionRepository.clearPendingCustomerProfile();
      rethrow;
    }
  }

  Future<void> resendVerification() async {
    final profile = await _sessionRepository.loadPendingCustomerProfile();
    if (profile != null && profile.email.isNotEmpty) {
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://luqmah-14bc5.firebaseapp.com/verify-email',
        handleCodeInApp: true,
        androidPackageName: 'com.example.flutter_application_1',
        androidInstallApp: true,
        androidMinimumVersion: '12',
        iOSBundleId: 'com.example.flutterApplication1',
      );
      await _authRepository.sendSignInLinkToEmail(
        email: profile.email,
        actionCodeSettings: actionCodeSettings,
      );
    }
  }

  Future<void> completeEmailLinkRegistration(
    String emailLink, {
    String? email,
    String? name,
    String? phone,
    String? password,
  }) async {
    final storedProfile = await _sessionRepository.loadPendingCustomerProfile();
    final finalEmail = email?.trim() ?? storedProfile?.email ?? '';
    final finalName = name?.trim() ?? storedProfile?.name ?? '';
    final finalPhone = phone?.trim() ?? storedProfile?.phoneNumber ?? '';
    final finalPassword = password ?? storedProfile?.password ?? '';

    if (finalEmail.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'Email address is required to complete sign in.',
      );
    }

    final credential = await _authRepository.signInWithEmailLink(
      email: finalEmail,
      emailLink: emailLink,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user-returned',
        message: 'Could not complete sign in.',
      );
    }

    if (finalName.isNotEmpty) {
      await _authRepository.updateCurrentUserDisplayName(finalName);
    }

    if (finalPassword.isNotEmpty) {
      await user.updatePassword(finalPassword);
    }

    if (finalName.isNotEmpty && finalPhone.isNotEmpty) {
      await _sessionRepository.savePendingCustomerProfile(
        PendingCustomerProfile(
          name: finalName,
          phoneNumber: finalPhone,
        ),
      );
    }

    await _syncCustomerBackendSessionIfNeeded(
      forceRefreshFirebaseToken: true,
      rethrowOnFailure: true,
    );

    await _sessionRepository.clearPendingCustomerProfile();
    await refresh();
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

  Future<void> updateCustomerName(String name) async {
    final session = _snapshot.backendSession;
    if (session == null || session.token.isEmpty) {
      throw StateError('A backend session is required to update this name.');
    }

    final updatedName = await _backendAuthRepository.updateCustomerName(
      token: session.token,
      name: name,
    );
    final updatedSession = session.copyWith(
      user: session.user.copyWith(name: updatedName),
    );

    if (_authRepository.currentUser != null) {
      await _authRepository.updateCurrentUserDisplayName(updatedName);
    }

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
    await _sessionRepository.clearPendingCustomerProfile();
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
      final pendingProfile = await _sessionRepository
          .loadPendingCustomerProfile();
      final idToken = await _authRepository.getIdToken(
        forceRefresh: forceRefreshFirebaseToken,
      );
      final backendSession = await _backendAuthRepository
          .syncCustomerWithFirebase(
            idToken: idToken,
            name: pendingProfile?.name,
            phoneNumber: pendingProfile?.phoneNumber,
          );
      await _sessionRepository.saveBackendSession(backendSession);
      await _sessionRepository.clearPendingCustomerProfile();
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
