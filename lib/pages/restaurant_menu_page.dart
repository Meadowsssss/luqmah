import 'package:flutter/material.dart';

import '../models/restaurant.dart';
import '../services/cart_service.dart';
import '../widgets/account_menu_button.dart';
import '../widgets/cart_icon_button.dart';
import 'customer_settings_page.dart';

class RestaurantMenuPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantMenuPage({super.key, required this.restaurant});

  @override
  State<RestaurantMenuPage> createState() => _RestaurantMenuPageState();
}

class _RestaurantMenuPageState extends State<RestaurantMenuPage> {
  late final List<String> _categories;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();

    final orderedCategories = <String>['Most Selling'];
    for (final item in widget.restaurant.menu) {
      if (!orderedCategories.contains(item.category)) {
        orderedCategories.add(item.category);
      }
    }
    _categories = orderedCategories;
    _selectedCategory = _categories.first;
  }

  List<MenuItem> get _visibleItems {
    if (_selectedCategory == 'Most Selling') {
      final popularItems = widget.restaurant.menu
          .where((item) => item.isMostSelling)
          .toList(growable: false);
      return popularItems.isNotEmpty ? popularItems : widget.restaurant.menu;
    }

    return widget.restaurant.menu
        .where((item) => item.category == _selectedCategory)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 8,
        title: const SizedBox.shrink(),
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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [
          Text(
            restaurant.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            restaurant.tags.join(', '),
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFF6B57),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                restaurant.rating,
                style: const TextStyle(
                  color: Color(0xFFFF6B57),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${restaurant.menu.length * 31} Reviews',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 1.9,
              child: Image.network(
                restaurant.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF0F0F0),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 42,
                      color: Colors.black38,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = category == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = category);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFFFF0ED) : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFFF6B57)
                            : const Color(0xFFEDEDED),
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFFFF6B57)
                            : Colors.black54,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          for (final item in _visibleItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RestaurantMenuTile(item: item),
            ),
        ],
      ),
    );
  }
}

class _RestaurantMenuTile extends StatelessWidget {
  final MenuItem item;

  const _RestaurantMenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: CartService.itemCount,
      builder: (context, _, __) {
        final quantity = CartService.items[item] ?? 0;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: Colors.black54,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${item.price.toStringAsFixed(2)} JD',
                      style: const TextStyle(
                        color: Color(0xFFFF6B57),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (quantity == 0)
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15343A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => CartService.addItem(item),
                          child: const Text('Add to cart'),
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => CartService.removeItem(item),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => CartService.addItem(item),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  item.image,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  cacheWidth: 400,
                  cacheHeight: 400,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: 100,
                      color: const Color(0xFFF0F0F0),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.black38,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
