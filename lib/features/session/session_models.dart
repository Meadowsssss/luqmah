import 'package:firebase_auth/firebase_auth.dart';

import 'backend_auth_repository.dart';

enum AppRole { customer, vendor, admin }

class SessionSnapshot {
  const SessionSnapshot({
    required this.firebaseUser,
    required this.backendSession,
    required this.role,
    required this.isLoading,
  });

  factory SessionSnapshot.loading() {
    return const SessionSnapshot(
      firebaseUser: null,
      backendSession: null,
      role: AppRole.customer,
      isLoading: true,
    );
  }

  final User? firebaseUser;
  final BackendAuthSession? backendSession;
  final AppRole role;
  final bool isLoading;

  bool get isSignedIn => firebaseUser != null || backendSession != null;
  bool get isEmailVerified {
    if (role == AppRole.customer) {
      return firebaseUser?.emailVerified ?? false;
    }
    return backendSession != null || (firebaseUser?.emailVerified ?? false);
  }
  bool get isVendorSurface => role == AppRole.vendor;
  bool get isAdminSurface => role == AppRole.admin;
  String get email => backendSession?.user.email ?? firebaseUser?.email ?? '';
  String get displayName => backendSession?.user.name ?? firebaseUser?.displayName ?? '';
  String? get backendToken => backendSession?.token;

  SessionSnapshot copyWith({
    User? firebaseUser,
    BackendAuthSession? backendSession,
    AppRole? role,
    bool? isLoading,
  }) {
    return SessionSnapshot(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      backendSession: backendSession ?? this.backendSession,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
