import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/cart_service.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;

  const MenuItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      // Whenever the cart changes, this rebuilds.
      valueListenable: CartService.itemCount,
      builder: (context, _, __) {
        final qty = CartService.items[item] ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.image,
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                  // Small optimization so it doesn't fetch huge images
                  cacheWidth: 280,
                  cacheHeight: 280,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 70,
                      width: 70,
                      alignment: Alignment.center,
                      child: const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 70,
                      width: 70,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 20),
                    );
                  },
                ),
              ),

              const SizedBox(width: 14),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.price.toStringAsFixed(2)} JD',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // BUTTONS (ADD or +/-)
              qty == 0
                  ? SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          CartService.addItem(item);
                        },
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            CartService.removeItem(item);
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(
                          '$qty',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            CartService.addItem(item);
                          },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
            ],
          ),
        );
      },
    );
  }
}
