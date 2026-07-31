import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens.dart';
import '../../../core/state/store_state.dart';
import '../../../core/widgets/editorial_widgets.dart';

String formatNaira(int value) =>
    '₦${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    if (cart.isEmpty) {
      return StorePage(
        children: [
          SizedBox(
            height: 430,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Eyebrow('Your bag / 00'),
                const SizedBox(height: 18),
                Text(
                  'Your bag is waiting.',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Discover pieces designed to live with you.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 26),
                ElevatedButton(
                  onPressed: () => context.go('/shop'),
                  child: const Text('EXPLORE THE SHOP'),
                ),
              ],
            ),
          ),
        ],
      );
    }
    final items = Column(
      children: [
        ...cart.asMap().entries.map((entry) {
          final line = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: context.isMobile ? 100 : 150,
                  height: context.isMobile ? 132 : 190,
                  child: ProductArtwork(product: line.product),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Eyebrow(line.product.category),
                      const SizedBox(height: 8),
                      Text(
                        line.product.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${line.colour} / ${line.size}',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.outlined(
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .changeQuantity(entry.key, -1),
                            icon: const Icon(Icons.remove, size: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text('${line.quantity}'),
                          ),
                          IconButton.outlined(
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .changeQuantity(entry.key, 1),
                            icon: const Icon(Icons.add, size: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatNaira(line.product.price * line.quantity),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 22),
                    IconButton(
                      tooltip: 'Remove ${line.product.name}',
                      onPressed: () =>
                          ref.read(cartProvider.notifier).removeAt(entry.key),
                      icon: const Icon(Icons.close, size: 19),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
    final summary = _OrderSummary(
      total: total,
      checkout: () => context.go('/checkout'),
    );
    return StorePage(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Your selection'),
                  const SizedBox(height: 10),
                  Text(
                    'Shopping bag',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ],
              ),
            ),
            Text('${ref.watch(cartCountProvider)} ITEMS'),
          ],
        ),
        const SizedBox(height: 40),
        if (context.width >= 950)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: items),
              const SizedBox(width: 54),
              Expanded(flex: 4, child: summary),
            ],
          )
        else
          Column(children: [items, const SizedBox(height: 36), summary]),
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.total, required this.checkout});
  final int total;
  final VoidCallback checkout;
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.white,
    padding: const EdgeInsets.all(28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Order summary', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 26),
        _SummaryLine('Subtotal', formatNaira(total)),
        const SizedBox(height: 12),
        const _SummaryLine('Delivery', 'Calculated at checkout'),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        _SummaryLine('Total', formatNaira(total), strong: true),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: checkout,
          child: const Text('SECURE CHECKOUT →'),
        ),
        const SizedBox(height: 14),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 15),
            SizedBox(width: 6),
            Text(
              'Secure checkout · Paystack',
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine(this.label, this.value, {this.strong = false});
  final String label;
  final String value;
  final bool strong;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: strong ? const TextStyle(fontWeight: FontWeight.w800) : null,
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    ],
  );
}

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(wishlistProvider);
    final products = ref
        .watch(productsProvider)
        .where((p) => ids.contains(p.id))
        .toList();
    return StorePage(
      children: [
        const Eyebrow('Saved for later'),
        const SizedBox(height: 12),
        Text('Wishlist', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 42),
        if (products.isEmpty)
          SizedBox(
            height: 320,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 38),
                  const SizedBox(height: 15),
                  const Text('No saved pieces yet.'),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () => context.go('/shop'),
                    child: const Text('START EXPLORING'),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.width >= 1100
                  ? 4
                  : (context.width >= 650 ? 2 : 1),
              mainAxisSpacing: 34,
              crossAxisSpacing: 18,
              childAspectRatio: context.isMobile ? .76 : .61,
            ),
            itemBuilder: (_, i) => ProductCard(product: products[i]),
          ),
      ],
    );
  }
}
