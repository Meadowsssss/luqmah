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

  Future<BackendAuthSession> registerCustomer({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': 'CUSTOMER',
      },
    );
    final session = BackendAuthSession.fromJson(response);
    if (session.user.role != 'CUSTOMER') {
      throw const ApiException('Customer access is required');
    }
    return session;
  }

  Future<BackendAuthSession> loginCustomer({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    final session = BackendAuthSession.fromJson(response);
    if (session.user.role != 'CUSTOMER') {
      throw const ApiException('Customer access is required');
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
      throw const ApiException('Vendor access is required');
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
    return BackendAuthSession.fromJson(response);
  }
}
