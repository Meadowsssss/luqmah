import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/vendor.dart';
import '../../services/vendor_store.dart';
import '../../widgets/account_menu_button.dart';
import '../../widgets/vendor/vendor_access_guard.dart';
import 'vendor_placeholder_page.dart';

class VendorOrderDetailsPage extends StatelessWidget {
  final String orderId;

  const VendorOrderDetailsPage({super.key, required this.orderId});

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

    return VendorAccessGuard(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        body: SafeArea(
          child: ValueListenableBuilder<List<VendorOrder>>(
            valueListenable: VendorStore.orders,
            builder: (context, _, __) {
              final order = VendorStore.orderById(orderId);

              if (order == null) {
                return const Center(child: Text('Order not found'));
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                order.id,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatter.format(order.dateTime),
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: _statusColor(
                            order.status,
                          ).withValues(alpha: 0.15),
                          child: Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: _statusColor(order.status),
                          ),
                        ),
                        AccountMenuButton(
                          onProfileTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VendorPlaceholderPage(
                                  title: 'Profile',
                                  icon: Icons.storefront_rounded,
                                  message:
                                      'Vendor profile settings will live here once the backend account data is connected.',
                                  currentIndex: 3,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order.customerName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: const Color(0xFF0EC56D),
                                child: IconButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Call ${order.customerPhone}',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.call_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              for (
                                int index = 0;
                                index < order.items.length;
                                index++
                              )
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == order.items.length - 1
                                        ? 0
                                        : 14,
                                  ),
                                  child: _OrderItemRow(
                                    item: order.items[index],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final item in order.items) ...[
                                _SummaryRow(
                                  label: item.quantity > 1
                                      ? '${item.name} x ${item.quantity}'
                                      : item.name,
                                  value:
                                      '\$${item.lineTotal.toStringAsFixed(0)}',
                                  accent: item.quantity > 1,
                                ),
                                const SizedBox(height: 14),
                              ],
                              const Divider(color: Color(0xFFEAEAEA)),
                              const SizedBox(height: 12),
                              _SummaryRow(
                                label: 'Subtotal',
                                value: '\$${order.subtotal.toStringAsFixed(0)}',
                              ),
                              const SizedBox(height: 16),
                              _SummaryRow(
                                label: 'Applied Coupon',
                                value: order.coupon == 0
                                    ? '\$0'
                                    : '-\$${order.coupon.abs().toStringAsFixed(0)}',
                                accentColor: const Color(0xFFE05353),
                              ),
                              const SizedBox(height: 18),
                              const Divider(color: Color(0xFFEAEAEA)),
                              const SizedBox(height: 14),
                              _SummaryRow(
                                label: 'Grand Total',
                                value: '\$${order.total.toStringAsFixed(0)}',
                                bold: true,
                                accentColor: const Color(0xFF15B667),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Status',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<VendorOrderStatus>(
                                  value: order.status,
                                  borderRadius: BorderRadius.circular(16),
                                  onChanged: (status) {
                                    if (status != null) {
                                      VendorStore.updateOrderStatus(
                                        order.id,
                                        status,
                                      );
                                    }
                                  },
                                  items: VendorOrderStatus.values
                                      .map(
                                        (status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status.label),
                                        ),
                                      )
                                      .toList(growable: false),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final VendorOrderItem item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 3),
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF15B667)),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 3.5,
                  backgroundColor: Color(0xFF15B667),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.extras.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.extras.join(', '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '${item.quantity}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 20),
            Text(
              '\$${item.lineTotal.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFECECEC)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool accent;
  final Color? accentColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.accent = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? (accent ? const Color(0xFF15B667) : null);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: bold ? 18 : 15,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18 : 15,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
