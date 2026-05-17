import 'package:firebase_auth/firebase_auth.dart';

import 'backend_auth_repository.dart';

enum AppRole { customer, vendor, admin }

class SessionSnapshot {
  const SessionSnapshot({
    required this.firebaseUser,
    required this.backendSession,
    required this.role,
    required this.isLoading,
    this.customerSyncError,
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
  final String? customerSyncError;

  bool get isSignedIn => firebaseUser != null || backendSession != null;
  bool get isEmailVerified {
    if (role == AppRole.customer) {
      return firebaseUser?.emailVerified ?? false;
    }
    return backendSession != null;
  }

  bool get isVendorSurface => role == AppRole.vendor;
  bool get isAdminSurface => role == AppRole.admin;
  bool get hasBackendSession => backendSession != null;
  bool get needsCustomerBackendSync =>
      role == AppRole.customer &&
      firebaseUser != null &&
      (firebaseUser?.emailVerified ?? false) &&
      backendSession == null;

  String get email => backendSession?.user.email ?? firebaseUser?.email ?? '';
  String get displayName => backendSession?.user.name ?? firebaseUser?.displayName ?? '';
  String get phoneNumber => backendSession?.user.phoneNumber ?? '';
  String? get backendToken => backendSession?.token;

  SessionSnapshot copyWith({
    User? firebaseUser,
    BackendAuthSession? backendSession,
    AppRole? role,
    bool? isLoading,
    String? customerSyncError,
    bool clearCustomerSyncError = false,
  }) {
    return SessionSnapshot(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      backendSession: backendSession ?? this.backendSession,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      customerSyncError: clearCustomerSyncError
          ? null
          : customerSyncError ?? this.customerSyncError,
    );
  }
}
