import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/customer_order.dart';

class CustomerOrdersRepository {
  static const _storageKey = 'customer_order_history';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<CustomerOrder>> loadOrders() async {
    final prefs = await _instance;
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const <CustomerOrder>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => CustomerOrder.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> saveOrders(List<CustomerOrder> orders) async {
    final prefs = await _instance;
    final encoded = jsonEncode(
      orders.map((order) => order.toJson()).toList(growable: false),
    );
    await prefs.setString(_storageKey, encoded);
  }
}
