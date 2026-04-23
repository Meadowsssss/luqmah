import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

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

  Future<SessionSnapshot> buildSnapshot(User? user) async {
    final backendSession = await loadBackendSession();

    if (backendSession != null) {
      return SessionSnapshot(
        firebaseUser: null,
        backendSession: backendSession,
        role: backendSession.user.role == 'ADMIN' ? AppRole.admin : AppRole.vendor,
        isLoading: false,
      );
    }

    if (user == null) {
      return const SessionSnapshot(
        firebaseUser: null,
        backendSession: null,
        role: AppRole.customer,
        isLoading: false,
      );
    }

    return SessionSnapshot(
      firebaseUser: user,
      backendSession: null,
      role: AppRole.customer,
      isLoading: false,
    );
  }
}
