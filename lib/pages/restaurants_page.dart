import 'package:flutter/material.dart';

import '../data/restaurants_data.dart';
import '../widgets/account_menu_button.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/restaurant_card.dart';
import 'customer_settings_page.dart';

class RestaurantsPage extends StatelessWidget {
  const RestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: const Color(0xFFF6F7F9),
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Luqmah',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 2),
            Text(
              'Campus favourites, ready when you are',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          const CartIconButton(),
          AccountMenuButton(
            onProfileTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerSettingsPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF15343A), Color(0xFF214D4A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Open now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Discover restaurants around campus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fast bites, hot meals, and drinks from the spots students order most.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _InfoPill(
                      icon: Icons.local_fire_department,
                      text: 'Most selling',
                    ),
                    _InfoPill(icon: Icons.timer_outlined, text: '10-30 min'),
                    _InfoPill(icon: Icons.star_rounded, text: '4.3+ rated'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Choose a restaurant',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap a place to explore its menu and start building your cart.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          for (final restaurant in restaurants)
            RestaurantCard(
              restaurant: restaurant,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/restaurant',
                  arguments: restaurant,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
