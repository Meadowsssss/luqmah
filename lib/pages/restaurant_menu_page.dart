
import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/cart_icon_button.dart';

class RestaurantMenuPage extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantMenuPage({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        actions: const [
          CartIconButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: ListView(
          children: [
            Text(
              restaurant.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Menu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final item in restaurant.menu) MenuItemCard(item: item),
          ],
        ),
      ),
    );
  }
}
