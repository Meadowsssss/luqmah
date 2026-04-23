import 'package:firebase_auth/firebase_auth.dart';

enum AppRole { customer, vendor }

class SessionSnapshot {
  const SessionSnapshot({
    required this.user,
    required this.role,
    required this.isVendorDemo,
    required this.isLoading,
  });

  factory SessionSnapshot.loading() {
    return const SessionSnapshot(
      user: null,
      role: AppRole.customer,
      isVendorDemo: false,
      isLoading: true,
    );
  }

  final User? user;
  final AppRole role;
  final bool isVendorDemo;
  final bool isLoading;

  bool get isSignedIn => user != null;
  bool get isEmailVerified => user?.emailVerified ?? false;
  bool get isVendorSurface => isVendorDemo || role == AppRole.vendor;
  String get email => user?.email ?? '';

  SessionSnapshot copyWith({
    User? user,
    AppRole? role,
    bool? isVendorDemo,
    bool? isLoading,
  }) {
    return SessionSnapshot(
      user: user ?? this.user,
      role: role ?? this.role,
      isVendorDemo: isVendorDemo ?? this.isVendorDemo,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
