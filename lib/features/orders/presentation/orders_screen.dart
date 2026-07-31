import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens.dart';
import '../../../core/widgets/editorial_widgets.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, this.orderId});
  final String? orderId;
  @override
  Widget build(BuildContext context) {
    if (orderId != null) return _OrderDetail(id: orderId!);
    return StorePage(
      children: [
        const Eyebrow('Private account'),
        const SizedBox(height: 12),
        Text('Your orders', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 42),
        ...[
          ('BN-2048', 'IN TRANSIT', '₦218,000', 'Arrives 03 Aug'),
          ('BN-1981', 'DELIVERED', '₦85,000', 'Delivered 16 Jul'),
        ].map(
          (order) => InkWell(
            onTap: () => context.go('/orders/${order.$1}'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      order.$1,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Eyebrow(
                          order.$2,
                          color: order.$2 == 'IN TRANSIT'
                              ? AppColors.success
                              : null,
                        ),
                        const SizedBox(height: 5),
                        Text(order.$4),
                      ],
                    ),
                  ),
                  Text(order.$3),
                  const SizedBox(width: 18),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderDetail extends StatelessWidget {
  const _OrderDetail({required this.id});
  final String id;
  @override
  Widget build(BuildContext context) => StorePage(
    children: [
      UnderlineLink('← ALL ORDERS', onTap: () => context.go('/orders')),
      const SizedBox(height: 24),
      const Eyebrow('Order / In transit'),
      const SizedBox(height: 12),
      Text(id, style: Theme.of(context).textTheme.displayMedium),
      const SizedBox(height: 40),
      Container(
        color: AppColors.white,
        padding: EdgeInsets.all(context.isMobile ? 22 : 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expected Saturday, 03 August',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 28),
            const _Timeline(),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'DHL Express · Tracking 320954201',
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Timeline extends StatelessWidget {
  const _Timeline();
  @override
  Widget build(BuildContext context) => Column(
    children:
        [
              ('Order confirmed', true),
              ('Prepared at studio', true),
              ('With delivery partner', true),
              ('Delivered', false),
            ]
            .map(
              (step) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(
                        step.$2
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: step.$2 ? AppColors.success : AppColors.border,
                      ),
                      Container(width: 1, height: 34, color: AppColors.border),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      step.$1,
                      style: TextStyle(
                        fontWeight: step.$2 ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
  );
}
