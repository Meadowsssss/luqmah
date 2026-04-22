import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/vendor.dart';

class VendorOrderCard extends StatelessWidget {
  final VendorOrder order;
  final ValueChanged<VendorOrderStatus?> onStatusChanged;
  final VoidCallback onTap;

  const VendorOrderCard({
    super.key,
    required this.order,
    required this.onStatusChanged,
    required this.onTap,
  });

  Color _statusColor(VendorOrderStatus status) {
    switch (status) {
      case VendorOrderStatus.accepted:
        return const Color(0xFF15B667);
      case VendorOrderStatus.inProgress:
        return const Color(0xFFEF8F00);
      case VendorOrderStatus.ready:
        return const Color(0xFF0097A7);
      case VendorOrderStatus.completed:
        return const Color(0xFF607D8B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'OID : ${order.id} | ${formatter.format(order.dateTime)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              order.customerName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            for (final item in order.items.take(2)) ...[
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  children: [
                    TextSpan(text: item.name),
                    TextSpan(
                      text: ' x ${item.quantity}',
                      style: const TextStyle(
                        color: Color(0xFF15B667),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.extras.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '(${item.extras.join(', ')})',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ),
              const SizedBox(height: 8),
            ],
            const Divider(height: 22, color: Color(0xFFEEEEEE)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.paymentMethod,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${order.total.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<VendorOrderStatus>(
                    value: order.status,
                    borderRadius: BorderRadius.circular(16),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    style: TextStyle(
                      color: _statusColor(order.status),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    items: VendorOrderStatus.values
                        .map(
                          (status) => DropdownMenuItem<VendorOrderStatus>(
                            value: status,
                            child: Text(status.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: onStatusChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
