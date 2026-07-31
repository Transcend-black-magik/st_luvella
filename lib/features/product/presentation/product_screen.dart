import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens.dart';
import '../../../core/state/store_state.dart';
import '../../../core/widgets/editorial_widgets.dart';
import '../../catalog/domain/product.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.slug});
  final String slug;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  String size = 'M';
  String colour = 'Black';

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final product = products.firstWhere(
      (item) => item.slug == widget.slug,
      orElse: () => products.first,
    );
    final layout = context.width >= 950;
    return SingleChildScrollView(
      child: Column(
        children: [
          if (layout)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: _Gallery(product: product)),
                Expanded(
                  flex: 4,
                  child: _ProductPanel(
                    product: product,
                    size: size,
                    colour: colour,
                    onSize: (v) => setState(() => size = v),
                    onColour: (v) => setState(() => colour = v),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _Gallery(product: product),
                _ProductPanel(
                  product: product,
                  size: size,
                  colour: colour,
                  onSize: (v) => setState(() => size = v),
                  onColour: (v) => setState(() => colour = v),
                ),
              ],
            ),
          Padding(
            padding: context.pagePadding.copyWith(top: 86, bottom: 96),
            child: Column(
              children: [
                const SectionHeading(
                  eyebrow: 'Complete the line',
                  title: 'You may also like',
                ),
                const SizedBox(height: 34),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: context.isMobile ? 2 : 4,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.isMobile ? 1 : 4,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 26,
                    childAspectRatio: context.isMobile ? .76 : .61,
                  ),
                  itemBuilder: (context, index) => ProductCard(
                    product:
                        products[(products.indexOf(product) + index + 1) %
                            products.length],
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFE5E1DA),
    height: context.width >= 950 ? 820 : (context.isMobile ? 520 : 680),
    child: Stack(
      children: [
        Positioned.fill(
          child: ProductArtwork(
            product: product,
            heroTag: 'product-${product.id}',
          ),
        ),
        Positioned(
          left: 20,
          bottom: 20,
          child: Container(
            color: AppColors.white.withValues(alpha: .9),
            padding: const EdgeInsets.all(8),
            child: const Row(
              children: [
                Icon(Icons.zoom_in, size: 18),
                SizedBox(width: 7),
                Text('VIEW DETAIL'),
              ],
            ),
          ),
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: Column(
            children: List.generate(
              3,
              (i) => Container(
                width: 48,
                height: 62,
                margin: const EdgeInsets.only(top: 7),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: i == 0 ? AppColors.ink : AppColors.white,
                    width: i == 0 ? 2 : 1,
                  ),
                ),
                child: ProductArtwork(product: product),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProductPanel extends ConsumerWidget {
  const _ProductPanel({
    required this.product,
    required this.size,
    required this.colour,
    required this.onSize,
    required this.onColour,
  });
  final Product product;
  final String size;
  final String colour;
  final ValueChanged<String> onSize;
  final ValueChanged<String> onColour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wished = ref.watch(wishlistProvider).contains(product.id);
    return Container(
      color: AppColors.canvas,
      padding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 20 : 54,
        vertical: context.isMobile ? 38 : 58,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow('New collection / ${product.category}'),
          const SizedBox(height: 15),
          Text(
            product.name,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: context.isMobile ? 38 : 48,
              height: .98,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            product.formattedPrice,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Text(
            product.description,
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Eyebrow('Colour'), Text(colour)],
          ),
          const SizedBox(height: 12),
          Row(
            children: ['Black', 'Ivory', 'Vermilion']
                .map(
                  (value) => GestureDetector(
                    onTap: () => onColour(value),
                    child: Container(
                      width: 34,
                      height: 34,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colour == value
                              ? AppColors.ink
                              : Colors.transparent,
                        ),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: value == 'Black'
                              ? AppColors.ink
                              : (value == 'Ivory'
                                    ? const Color(0xFFE6DED0)
                                    : AppColors.accent),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Eyebrow('Select size'),
              UnderlineLink('SIZE GUIDE', onTap: () => _sizeGuide(context)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['XS', 'S', 'M', 'L', 'XL']
                .map(
                  (value) => SizedBox(
                    width: 55,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: size == value
                            ? AppColors.ink
                            : Colors.transparent,
                        foregroundColor: size == value
                            ? Colors.white
                            : AppColors.ink,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => onSize(value),
                      child: Text(value),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.circle, size: 8, color: AppColors.success),
              SizedBox(width: 8),
              Text('In stock — dispatches in 1–2 working days'),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref
                    .read(cartProvider.notifier)
                    .add(product, size: size, colour: colour);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to your bag')),
                );
              },
              child: const Text('ADD TO BAG'),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref
                        .read(cartProvider.notifier)
                        .add(product, size: size, colour: colour);
                    context.go('/checkout');
                  },
                  child: const Text('BUY NOW'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.outlined(
                tooltip: wished ? 'Remove from wishlist' : 'Save',
                onPressed: () =>
                    ref.read(wishlistProvider.notifier).toggle(product.id),
                icon: Icon(wished ? Icons.favorite : Icons.favorite_border),
              ),
            ],
          ),
          if (product.has3dAsset) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(selectedProductProvider.notifier).state = product;
                  ref.read(selectedFitSizeProvider.notifier).state = size;
                  ref.read(selectedFitColourProvider.notifier).state = colour;
                  context.go('/virtual-fit');
                },
                icon: const Icon(Icons.view_in_ar_outlined),
                label: const Text('TRY ON MY AVATAR'),
              ),
            ),
          ],
          const SizedBox(height: 34),
          ...[
            'Materials & care',
            'Delivery & returns',
            'Fit & model information',
          ].map(
            (title) => ExpansionTile(
              tilePadding: EdgeInsets.zero,
              shape: const Border(top: BorderSide(color: AppColors.border)),
              collapsedShape: const Border(
                top: BorderSide(color: AppColors.border),
              ),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.only(bottom: 18),
                  child: Text(
                    'Thoughtfully made and carefully finished. See our care guide for full details.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sizeGuide(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Size guide', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          const Text(
            'XS  82–86 cm chest\nS    87–91 cm chest\nM   92–97 cm chest\nL    98–104 cm chest\nXL  105–112 cm chest',
            style: TextStyle(height: 2),
          ),
        ],
      ),
    ),
  );
}
