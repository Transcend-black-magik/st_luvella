import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens.dart';
import '../../../core/state/store_state.dart';
import '../../../core/widgets/editorial_widgets.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key, this.mode = 'shop', this.slug});
  final String mode;
  final String? slug;

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String category = 'All';
  String sort = 'Featured';
  bool showFilters = false;

  @override
  Widget build(BuildContext context) {
    final allProducts = ref.watch(productsProvider);
    var products = widget.mode == 'new'
        ? allProducts.where((p) => p.isNew).toList()
        : allProducts;
    if (category != 'All') {
      products = products.where((p) => p.category == category).toList();
    }
    if (sort == 'Price: low to high') {
      products = [...products]..sort((a, b) => a.price.compareTo(b.price));
    }
    if (sort == 'Price: high to low') {
      products = [...products]..sort((a, b) => b.price.compareTo(a.price));
    }
    final title = widget.mode == 'collections'
        ? (widget.slug == null ? 'Collections' : 'Soft structure')
        : (widget.mode == 'new' ? 'New arrivals' : 'Shop all');
    final count = context.width >= 1200
        ? (showFilters ? 3 : 4)
        : (context.width >= 700 ? 2 : 1);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CatalogBanner(
            title: title,
            isCollection: widget.mode == 'collections',
          ),
          Padding(
            padding: context.pagePadding.copyWith(top: 24, bottom: 92),
            child: Column(
              children: [
                _FilterBar(
                  category: category,
                  sort: sort,
                  showFilters: showFilters,
                  productCount: products.length,
                  onFilters: () => setState(() => showFilters = !showFilters),
                  onCategory: (value) => setState(() => category = value),
                  onSort: (value) => setState(() => sort = value),
                ),
                const Divider(),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showFilters && context.width >= 850) ...[
                      const SizedBox(width: 220, child: _FilterPanel()),
                      const SizedBox(width: 28),
                    ],
                    Expanded(
                      child: products.isEmpty
                          ? const _EmptyCatalog()
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: products.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: count,
                                    crossAxisSpacing: 18,
                                    mainAxisSpacing: 42,
                                    childAspectRatio: count == 1 ? .76 : .61,
                                  ),
                              itemBuilder: (context, index) =>
                                  ProductCard(product: products[index]),
                            ),
                    ),
                  ],
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

class _CatalogBanner extends StatelessWidget {
  const _CatalogBanner({required this.title, required this.isCollection});
  final String title;
  final bool isCollection;

  @override
  Widget build(BuildContext context) => Container(
    height: context.isMobile ? 280 : 360,
    color: isCollection ? AppColors.accent : AppColors.charcoal,
    padding: context.pagePadding.copyWith(top: 40, bottom: 36),
    child: Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Text(
            isCollection ? '02' : 'ALL',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: context.isMobile ? 90 : 170,
              color: (isCollection ? AppColors.ink : Colors.white).withValues(
                alpha: .09,
              ),
              height: .8,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(
                isCollection ? 'Collection / 02' : 'The complete edit',
                color: isCollection ? AppColors.ink : AppColors.border,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: isCollection ? AppColors.ink : Colors.white,
                  fontSize: context.isMobile ? 53 : 88,
                  height: .9,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isCollection
                    ? 'A study in relaxed precision and sculptural ease.'
                    : 'Modern wardrobe foundations, cut with intention.',
                style: TextStyle(
                  color: isCollection ? AppColors.ink : AppColors.border,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.category,
    required this.sort,
    required this.showFilters,
    required this.productCount,
    required this.onFilters,
    required this.onCategory,
    required this.onSort,
  });
  final String category;
  final String sort;
  final bool showFilters;
  final int productCount;
  final VoidCallback onFilters;
  final ValueChanged<String> onCategory;
  final ValueChanged<String> onSort;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 70,
    child: Row(
      children: [
        OutlinedButton.icon(
          onPressed: onFilters,
          icon: Icon(showFilters ? Icons.close : Icons.tune, size: 18),
          label: Text(showFilters ? 'CLOSE' : 'FILTERS'),
        ),
        if (!context.isMobile) ...[
          const SizedBox(width: 20),
          DropdownButton<String>(
            value: category,
            underline: const SizedBox.shrink(),
            items: [
              'All',
              'Tops',
              'Bottoms',
              'Outerwear',
              'Dresses',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => onCategory(v!),
          ),
        ],
        const Spacer(),
        Text(
          '$productCount PIECES',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.muted,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(width: 22),
        DropdownButton<String>(
          value: sort,
          underline: const SizedBox.shrink(),
          items: ['Featured', 'Price: low to high', 'Price: high to low']
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text(
                    context.isMobile && v.startsWith('Price') ? 'Price' : v,
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => onSort(v!),
        ),
      ],
    ),
  );
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search',
        ),
      ),
      const SizedBox(height: 24),
      ...[
        'CATEGORY',
        'SIZE',
        'COLOUR',
        'AVAILABILITY',
        'FIT',
        'PRICE RANGE',
      ].map(
        (label) => ExpansionTile(
          tilePadding: EdgeInsets.zero,
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  label == 'SIZE' ? 'XS   S   M   L   XL' : 'All options',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 420,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 38),
          const SizedBox(height: 18),
          Text(
            'Nothing matches those filters',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Clear a filter and discover something new.',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
}

class CollectionsIndexScreen extends StatelessWidget {
  const CollectionsIndexScreen({super.key});
  @override
  Widget build(BuildContext context) => StorePage(
    children: [
      const Eyebrow('Collection index / 2026'),
      const SizedBox(height: 16),
      Text(
        'Collections',
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: context.isMobile ? 58 : 98,
        ),
      ),
      const SizedBox(height: 48),
      ...[
        ('01', 'Soft structure', 'Quiet tailoring for days in motion.'),
        ('02', 'After light', 'Evening pieces with a softened edge.'),
        ('03', 'Everyday form', 'The foundations that do the most.'),
      ].map(
        (item) => InkWell(
          onTap: () => context.go('/collections/soft-structure'),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                SizedBox(width: 60, child: Eyebrow(item.$1)),
                Expanded(
                  child: Text(
                    item.$2,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                if (!context.isMobile)
                  Expanded(
                    child: Text(
                      item.$3,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                const Icon(Icons.arrow_outward),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
