
import 'package:flutter/material.dart';
import '../data/restaurants_data.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/cart_icon_button.dart';

class RestaurantsPage extends StatelessWidget {
  const RestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 140,
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(width: 8),
            Icon(Icons.restaurant_menu, color: Color(0xFF2E7D32)),
            SizedBox(width: 6),
            Text(
              'Luqmah',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: const [
          CartIconButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ListView(
          children: [
            const Text(
              'Welcome to Luqmah',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Order from your favourite campus restaurants',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            for (final r in restaurants)
              RestaurantCard(
                restaurant: r,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/restaurant',
                    arguments: r,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
