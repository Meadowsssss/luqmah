import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';

final backendAuthRepositoryProvider = Provider<BackendAuthRepository>((ref) {
  return BackendAuthRepository(ref.watch(apiClientProvider));
});

class BackendAuthUser {
  const BackendAuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String role;

  factory BackendAuthUser.fromJson(Map<String, dynamic> json) {
    return BackendAuthUser(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}

class BackendAuthSession {
  const BackendAuthSession({required this.token, required this.user});

  final String token;
  final BackendAuthUser user;

  factory BackendAuthSession.fromJson(Map<String, dynamic> json) {
    return BackendAuthSession(
      token: json['token'] as String,
      user: BackendAuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

class BackendAuthRepository {
  const BackendAuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<BackendAuthSession> syncCustomerWithFirebase({
    required String idToken,
  }) async {
    final response = await _apiClient.post(
      '/auth/firebase/customer',
      body: {'idToken': idToken},
    );
    final session = BackendAuthSession.fromJson(response);
    if (session.user.role != 'CUSTOMER') {
      throw const ApiException(
        'Customer access is required',
        code: 'AUTH_ROLE_MISMATCH',
      );
    }
    return session;
  }

  Future<BackendAuthSession> loginVendor({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    final session = BackendAuthSession.fromJson(response);
    if (session.user.role != 'VENDOR') {
      throw const ApiException(
        'Vendor access is required',
        code: 'AUTH_ROLE_MISMATCH',
      );
    }
    return session;
  }

  Future<BackendAuthSession> loginAdmin({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/admin/login',
      body: {'email': email, 'password': password},
    );
    final session = BackendAuthSession.fromJson(response);
    if (session.user.role != 'ADMIN') {
      throw const ApiException(
        'Admin access is required',
        code: 'AUTH_ROLE_MISMATCH',
      );
    }
    return session;
  }

  Future<void> changeBackendPassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.patch(
      '/users/me/password',
      token: token,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
