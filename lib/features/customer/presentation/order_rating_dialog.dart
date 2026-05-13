import 'package:flutter/material.dart';

import '../../../app/theme/luqmah_theme.dart';
import '../../../models/customer_order.dart';

class OrderRatingDialogResult {
  const OrderRatingDialogResult._({this.score, this.dismissed = false});

  const OrderRatingDialogResult.submit(int score) : this._(score: score);
  const OrderRatingDialogResult.later() : this._(dismissed: true);

  final int? score;
  final bool dismissed;
}

Future<OrderRatingDialogResult?> showOrderRatingDialog({
  required BuildContext context,
  required CustomerOrder order,
  required bool allowLater,
}) {
  return showDialog<OrderRatingDialogResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        _OrderRatingDialog(order: order, allowLater: allowLater),
  );
}

class _OrderRatingDialog extends StatefulWidget {
  const _OrderRatingDialog({required this.order, required this.allowLater});

  final CustomerOrder order;
  final bool allowLater;

  @override
  State<_OrderRatingDialog> createState() => _OrderRatingDialogState();
}

class _OrderRatingDialogState extends State<_OrderRatingDialog> {
  int _score = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate your order'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.order.restaurantName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'How was your restaurant experience?',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.luqmah.mutedText),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 1; index <= 5; index++)
                IconButton(
                  onPressed: () => setState(() => _score = index),
                  iconSize: 34,
                  color: const Color(0xFFD1A340),
                  icon: Icon(
                    index <= _score
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            widget.allowLater ? const OrderRatingDialogResult.later() : null,
          ),
          child: Text(widget.allowLater ? 'Later' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: _score == 0
              ? null
              : () => Navigator.of(
                  context,
                ).pop(OrderRatingDialogResult.submit(_score)),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
