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
    refresh();
  }

  final AuthRepository _authRepository;
  final BackendAuthRepository _backendAuthRepository;
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
    await _sessionRepository.clearBackendSession();
    try {
      await _authRepository.login(email: email, password: password);
      final session = await _backendAuthRepository.loginCustomer(
        email: email,
        password: password,
      );
      await _sessionRepository.saveBackendSession(session);
      await refresh();
    } catch (error) {
      if (_authRepository.currentUser != null) {
        await _authRepository.logout();
      }
      await _sessionRepository.clearBackendSession();
      rethrow;
    }
  }

  Future<void> loginVendor({required String email, required String password}) async {
    if (_authRepository.currentUser != null) {
      await _authRepository.logout();
    }
    final session = await _backendAuthRepository.loginVendor(email: email, password: password);
    await _sessionRepository.saveBackendSession(session);
    await refresh();
  }

  Future<void> loginAdmin({required String email, required String password}) async {
    if (_authRepository.currentUser != null) {
      await _authRepository.logout();
    }
    final session = await _backendAuthRepository.loginAdmin(email: email, password: password);
    await _sessionRepository.saveBackendSession(session);
    await refresh();
  }

  Future<void> registerCustomer({
    required String email,
    required String password,
  }) async {
    await _sessionRepository.clearBackendSession();
    try {
      final credential = await _authRepository.register(
        email: email,
        password: password,
      );
      final backendSession = await _backendAuthRepository.registerCustomer(
        name: _displayNameFromEmail(email),
        email: email,
        password: password,
      );
      await _sessionRepository.saveBackendSession(backendSession);
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

  String _displayNameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) {
      return 'Luqmah Student';
    }

    final words = localPart
        .split(RegExp(r'[._-]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .toList(growable: false);

    return words.isEmpty ? 'Luqmah Student' : words.join(' ');
  }

  Future<void> resendVerification() async {
    await _authRepository.sendEmailVerification();
  }

  Future<void> reloadVerification() async {
    await _authRepository.reloadCurrentUser();
    await refresh();
  }

  Future<void> logout() async {
    await _sessionRepository.clearBackendSession();
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
