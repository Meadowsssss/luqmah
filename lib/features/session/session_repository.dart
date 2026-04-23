import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'session_models.dart';

class SessionRepository {
  static const _rolePrefix = 'role:';
  static const _vendorDemoKey = 'vendor_demo_access';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _storageKey(String identifier) => '$_rolePrefix$identifier';

  Future<bool> isVendorDemoEnabled() async {
    final prefs = await _instance;
    return prefs.getBool(_vendorDemoKey) ?? false;
  }

  Future<void> enableVendorDemoAccess() async {
    final prefs = await _instance;
    await prefs.setBool(_vendorDemoKey, true);
  }

  Future<void> clearVendorDemoAccess() async {
    final prefs = await _instance;
    await prefs.remove(_vendorDemoKey);
  }

  Future<void> setRoleForIdentifier(String identifier, AppRole role) async {
    final prefs = await _instance;
    await prefs.setString(_storageKey(identifier), role.name);
  }

  Future<void> setRoleForUser(User user, AppRole role) async {
    await setRoleForIdentifier(user.uid, role);
    final email = user.email;
    if (email != null && email.isNotEmpty) {
      await setRoleForIdentifier(email, role);
    }
  }

  Future<AppRole> resolveRole(User user) async {
    final prefs = await _instance;
    final fromUid = prefs.getString(_storageKey(user.uid));
    final email = user.email;
    final fromEmail = email == null ? null : prefs.getString(_storageKey(email));
    final storedRole = fromUid ?? fromEmail;
    return storedRole == AppRole.vendor.name ? AppRole.vendor : AppRole.customer;
  }

  Future<SessionSnapshot> buildSnapshot(User? user) async {
    final vendorDemoEnabled = await isVendorDemoEnabled();

    if (user == null) {
      return SessionSnapshot(
        user: null,
        role: vendorDemoEnabled ? AppRole.vendor : AppRole.customer,
        isVendorDemo: vendorDemoEnabled,
        isLoading: false,
      );
    }

    final role = await resolveRole(user);

    return SessionSnapshot(
      user: user,
      role: role,
      isVendorDemo: false,
      isLoading: false,
    );
  }
}
