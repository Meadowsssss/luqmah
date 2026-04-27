import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend_auth_repository.dart';
import 'session_models.dart';

class SessionRepository {
  static const _backendSessionKey = 'backend_session';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveBackendSession(BackendAuthSession session) async {
    final prefs = await _instance;
    await prefs.setString(_backendSessionKey, jsonEncode(session.toJson()));
  }

  Future<BackendAuthSession?> loadBackendSession() async {
    final prefs = await _instance;
    final raw = prefs.getString(_backendSessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return BackendAuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearBackendSession() async {
    final prefs = await _instance;
    await prefs.remove(_backendSessionKey);
  }

  Future<SessionSnapshot> buildSnapshot(User? firebaseUser) async {
    final backendSession = await loadBackendSession();

    if (backendSession == null) {
      return SessionSnapshot(
        firebaseUser: firebaseUser,
        backendSession: null,
        role: AppRole.customer,
        isLoading: false,
      );
    }

    final role = switch (backendSession.user.role) {
      'ADMIN' => AppRole.admin,
      'VENDOR' => AppRole.vendor,
      _ => AppRole.customer,
    };

    if (role == AppRole.customer && firebaseUser == null) {
      await clearBackendSession();
      return const SessionSnapshot(
        firebaseUser: null,
        backendSession: null,
        role: AppRole.customer,
        isLoading: false,
      );
    }

    return SessionSnapshot(
      firebaseUser: firebaseUser,
      backendSession: backendSession,
      role: role,
      isLoading: false,
    );
  }
}
