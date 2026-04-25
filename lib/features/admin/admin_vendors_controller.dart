import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/session_controller.dart';
import 'admin_repository.dart';

class AdminVendorsController extends AsyncNotifier<List<AdminVendorRecord>> {
  AdminRepository get _repository => ref.read(adminRepositoryProvider);

  @override
  Future<List<AdminVendorRecord>> build() async {
    final token = ref.watch(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      return const [];
    }
    return _repository.loadVendors(token);
  }

  Future<void> createVendor({
    required String name,
    required String email,
    required String password,
    required String restaurantTitle,
    required String restaurantDescription,
    required String restaurantAddress,
    required String coverImage,
    required List<String> categories,
  }) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Admin session is required');
    }

    await _repository.createVendor(
      token: token,
      name: name,
      email: email,
      password: password,
      restaurantTitle: restaurantTitle,
      restaurantDescription: restaurantDescription,
      restaurantAddress: restaurantAddress,
      coverImage: coverImage,
      categories: categories,
    );
    ref.invalidateSelf();
    await future;
  }

  Future<String> deleteVendor(String vendorId) async {
    final token = ref.read(sessionControllerProvider).snapshot.backendToken;
    if (token == null || token.isEmpty) {
      throw StateError('Admin session is required');
    }

    final message = await _repository.deleteVendor(token: token, vendorId: vendorId);
    ref.invalidateSelf();
    await future;
    return message;
  }
}

final adminVendorsControllerProvider =
    AsyncNotifierProvider<AdminVendorsController, List<AdminVendorRecord>>(
      AdminVendorsController.new,
    );
