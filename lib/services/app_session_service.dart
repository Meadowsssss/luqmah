import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppRole { customer, vendor }

class SessionIdentity {
  final AppRole role;
  final String title;
  final String subtitle;
  final bool isDemo;

  const SessionIdentity({
    required this.role,
    required this.title,
    required this.subtitle,
    this.isDemo = false,
  });
}

class AppSessionService {
  static const _rolePrefix = 'role:';
  static const _vendorDemoKey = 'vendor_demo_access';
  static SharedPreferences? _prefs;
  static final ValueNotifier<AppRole> role = ValueNotifier<AppRole>(
    AppRole.customer,
  );

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await refreshRoleFromCurrentUser();
  }

  static Future<bool> isVendorDemoEnabled() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    return prefs.getBool(_vendorDemoKey) ?? false;
  }

  static Future<void> enableVendorDemoAccess() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setBool(_vendorDemoKey, true);
    role.value = AppRole.vendor;
  }

  static Future<void> clearVendorDemoAccess() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.remove(_vendorDemoKey);
  }

  static String _storageKey(String identifier) => '$_rolePrefix$identifier';

  static Future<void> setRoleForIdentifier(
    String identifier,
    AppRole nextRole,
  ) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setString(_storageKey(identifier), nextRole.name);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null &&
        (currentUser.uid == identifier || currentUser.email == identifier)) {
      role.value = nextRole;
    }
  }

  static Future<void> setRoleForCurrentUser(AppRole nextRole) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await setRoleForIdentifier(user.uid, nextRole);
    if (user.email != null && user.email!.isNotEmpty) {
      await setRoleForIdentifier(user.email!, nextRole);
    }
  }

  static Future<AppRole> refreshRoleFromCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final vendorDemoEnabled = await isVendorDemoEnabled();

    if (user == null) {
      role.value = vendorDemoEnabled ? AppRole.vendor : AppRole.customer;
      return role.value;
    }

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;

    final fromUid = prefs.getString(_storageKey(user.uid));
    final fromEmail = user.email == null
        ? null
        : prefs.getString(_storageKey(user.email!));
    final storedRole = fromUid ?? fromEmail;

    role.value = storedRole == AppRole.vendor.name
        ? AppRole.vendor
        : AppRole.customer;
    return role.value;
  }

  static Future<SessionIdentity> currentIdentity() async {
    final user = FirebaseAuth.instance.currentUser;
    final vendorDemoEnabled = await isVendorDemoEnabled();

    if (vendorDemoEnabled && user == null) {
      return const SessionIdentity(
        role: AppRole.vendor,
        title: 'Vendor Demo',
        subtitle: 'Temporary local vendor session',
        isDemo: true,
      );
    }

    final currentRole = await refreshRoleFromCurrentUser();
    final email = user?.email;

    if (currentRole == AppRole.vendor) {
      return SessionIdentity(
        role: AppRole.vendor,
        title: email == null || email.isEmpty ? 'Vendor Account' : email,
        subtitle: 'Vendor workspace connected',
      );
    }

    return SessionIdentity(
      role: AppRole.customer,
      title: email == null || email.isEmpty ? 'Customer Account' : email,
      subtitle: 'Customer browsing session',
    );
  }
}
