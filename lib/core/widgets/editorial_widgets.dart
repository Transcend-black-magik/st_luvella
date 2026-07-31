import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/catalog/domain/product.dart';
import '../design_system/tokens.dart';
import '../state/store_state.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.light = false,
    this.height = 30,
    this.fontSize = 20,
    this.suffix,
  });

  final bool light;
  final double height;
  final double fontSize;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final color = light ? AppColors.white : AppColors.ink;
    return Semantics(
      container: true,
      label: suffix == null ? 'st.luvella' : 'st.luvella $suffix',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: height,
              child: ClipRect(
                child: Transform.scale(
                  scale: 2.08,
                  child: Image.asset(
                    'lib/assets/logo.png',
                    fit: BoxFit.contain,
                    color: color,
                    colorBlendMode: BlendMode.srcIn,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
            SizedBox(width: height * .28),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'st.luvella',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.8,
                    height: 1,
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    suffix!,
                    style: TextStyle(
                      color: color.withValues(alpha: .65),
                      fontSize: fontSize * .48,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: color ?? AppColors.muted,
      fontWeight: FontWeight.w800,
      letterSpacing: 2.1,
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.action,
    this.dark = false,
  });
  final String eyebrow;
  final String title;
  final Widget? action;
  final bool dark;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(eyebrow, color: dark ? AppColors.border : null),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: dark ? Colors.white : null,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      ...action == null ? const <Widget>[] : <Widget>[action!],
    ],
  );
}

class UnderlineLink extends StatelessWidget {
  const UnderlineLink(
    this.label, {
    super.key,
    required this.onTap,
    this.light = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool light;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      foregroundColor: light ? Colors.white : AppColors.ink,
      padding: const EdgeInsets.symmetric(vertical: 8),
      shape: const RoundedRectangleBorder(),
      textStyle: const TextStyle(
        decoration: TextDecoration.underline,
        decorationThickness: 1.5,
        fontWeight: FontWeight.w700,
      ),
    ),
    child: Text(label),
  );
}

class ProductArtwork extends StatelessWidget {
  const ProductArtwork({
    super.key,
    required this.product,
    this.heroTag,
    this.fit = BoxFit.cover,
  });
  final Product product;
  final Object? heroTag;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final image = SizedBox.expand(
      child: ClipRect(
        child: Transform.scale(
          scale: 2.02,
          alignment: product.imageAlignment,
          child: Image.asset(
            'assets/images/catalog_sheet.png',
            fit: fit,
            alignment: product.imageAlignment,
            semanticLabel: '${product.name} product photograph',
          ),
        ),
      ),
    );
    return heroTag == null ? image : Hero(tag: heroTag!, child: image);
  }
}

class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product, this.compact = false});
  final Product product;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wished = ref.watch(wishlistProvider).contains(product.id);
    return Semantics(
      button: true,
      label: '${product.name}, ${product.formattedPrice}',
      child: InkWell(
        onTap: () => context.go('/product/${product.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductArtwork(
                    product: product,
                    heroTag: 'product-${product.id}',
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: product.isNew
                        ? const _ProductBadge('NEW')
                        : const SizedBox.shrink(),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton.filledTonal(
                      tooltip: wished
                          ? 'Remove from wishlist'
                          : 'Save to wishlist',
                      onPressed: () => ref
                          .read(wishlistProvider.notifier)
                          .toggle(product.id),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.white.withValues(alpha: .9),
                        foregroundColor: AppColors.ink,
                      ),
                      icon: Icon(
                        wished ? Icons.favorite : Icons.favorite_border,
                        size: 19,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ref.read(cartProvider.notifier).add(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} added to bag'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Text('QUICK ADD'),
                          ),
                        ),
                        if (product.has3dAsset && !compact) ...[
                          const SizedBox(width: 6),
                          IconButton.filled(
                            tooltip: 'Try on avatar',
                            onPressed: () {
                              ref.read(selectedProductProvider.notifier).state =
                                  product;
                              ref.read(selectedFitSizeProvider.notifier).state =
                                  'M';
                              ref
                                      .read(selectedFitColourProvider.notifier)
                                      .state =
                                  'Black';
                              context.go('/virtual-fit');
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.ink,
                              fixedSize: const Size(52, 52),
                            ),
                            icon: const Icon(Icons.view_in_ar_outlined),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.category.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.muted,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  product.formattedPrice,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductBadge extends StatelessWidget {
  const _ProductBadge(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.accent,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900),
    ),
  );
}

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final columns = [
      ('SHOP', ['New arrivals', 'Ready to wear', 'Accessories', 'Gift cards']),
      (
        'CLIENT SERVICES',
        ['Delivery & returns', 'Size guide', 'Contact', 'Care'],
      ),
      ('ABOUT', ['Our story', 'Responsibility', 'Journal', 'Careers']),
    ];
    return Container(
      color: AppColors.ink,
      padding: context.pagePadding.copyWith(top: 64, bottom: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 72,
            runSpacing: 42,
            children: [
              SizedBox(
                width: context.isMobile ? context.width - 36 : 330,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandLogo(light: true, height: 42, fontSize: 30),
                    const SizedBox(height: 16),
                    Text(
                      'Considered fashion, made for how you actually live.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppColors.border),
                    ),
                  ],
                ),
              ),
              ...columns.map(
                (column) => SizedBox(
                  width: 170,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Eyebrow(column.$1, color: Colors.white),
                      const SizedBox(height: 14),
                      ...column.$2.map(
                        (link) => Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Text(
                            link,
                            style: const TextStyle(color: AppColors.border),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 64),
          const Divider(color: Color(0xFF3B3B39)),
          const SizedBox(height: 22),
          const Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              Text(
                '© 2026 st.luvella',
                style: TextStyle(color: AppColors.muted),
              ),
              Text('Privacy', style: TextStyle(color: AppColors.muted)),
              Text('Terms', style: TextStyle(color: AppColors.muted)),
              Text('Nigeria / NGN', style: TextStyle(color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class StorePage extends StatelessWidget {
  const StorePage({
    super.key,
    required this.children,
    this.paddingTop = 48,
    this.includeFooter = true,
  });
  final List<Widget> children;
  final double paddingTop;
  final bool includeFooter;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: context.pagePadding.copyWith(top: paddingTop, bottom: 72),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
        if (includeFooter) const AppFooter(),
      ],
    ),
  );
}
