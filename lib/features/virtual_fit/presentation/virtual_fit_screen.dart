import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens.dart';
import '../../../core/state/store_state.dart';
import '../../../core/widgets/editorial_widgets.dart';
import '../../catalog/domain/product.dart';
import 'three_d_viewer.dart';

class VirtualFitScreen extends ConsumerStatefulWidget {
  const VirtualFitScreen({super.key});
  @override
  ConsumerState<VirtualFitScreen> createState() => _VirtualFitScreenState();
}

class _VirtualFitScreenState extends ConsumerState<VirtualFitScreen> {
  final viewerKey = GlobalKey<ThreeDViewerState>();
  String category = 'Tops';
  String size = 'M';
  String colour = 'Black';
  ViewerMode mode = ViewerMode.sampleGlb;
  late List<Product> outfit;

  @override
  void initState() {
    super.initState();
    outfit = [];
    size = ref.read(selectedFitSizeProvider);
    colour = ref.read(selectedFitColourProvider);
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final selected = ref.watch(selectedProductProvider) ?? products.first;
    if (outfit.isEmpty) outfit = [selected, products[2]];
    final desktop = context.width >= 1050;
    return Scaffold(
      backgroundColor: const Color(0xFFE7E2D8),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              onFallback: () => setState(
                () => mode = mode == ViewerMode.sampleGlb
                    ? ViewerMode.fallback2d
                    : ViewerMode.sampleGlb,
              ),
            ),
            Expanded(
              child: desktop
                  ? Row(
                      children: [
                        SizedBox(
                          width: 250,
                          child: _CategoryPanel(
                            category: category,
                            products: products,
                            onCategory: (v) => setState(() => category = v),
                            onAdd: _addGarment,
                          ),
                        ),
                        Expanded(
                          child: _AvatarStage(viewerKey: viewerKey, mode: mode),
                        ),
                        SizedBox(
                          width: 330,
                          child: _FitPanel(
                            product: selected,
                            size: size,
                            colour: colour,
                            outfit: outfit,
                            onSize: _selectSize,
                            onColour: _selectColour,
                            onAdd: _addOne,
                            onAddOutfit: _addOutfit,
                            onSave: _saveOutfit,
                            onShare: _share,
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: context.isMobile ? 540 : 650,
                            child: _AvatarStage(
                              viewerKey: viewerKey,
                              mode: mode,
                            ),
                          ),
                          SizedBox(
                            height: 220,
                            child: _CategoryPanel(
                              category: category,
                              products: products,
                              onCategory: (v) => setState(() => category = v),
                              onAdd: _addGarment,
                              compact: true,
                            ),
                          ),
                          _FitPanel(
                            product: selected,
                            size: size,
                            colour: colour,
                            outfit: outfit,
                            onSize: _selectSize,
                            onColour: _selectColour,
                            onAdd: _addOne,
                            onAddOutfit: _addOutfit,
                            onSave: _saveOutfit,
                            onShare: _share,
                          ),
                        ],
                      ),
                    ),
            ),
            if (desktop)
              _OutfitTray(
                outfit: outfit,
                onRemove: (product) => setState(() => outfit.remove(product)),
                onDuplicate: () => setState(() => outfit = [...outfit]),
              ),
          ],
        ),
      ),
    );
  }

  void _addGarment(Product product) {
    ref.read(selectedProductProvider.notifier).state = product;
    setState(() {
      outfit.removeWhere((item) => item.category == product.category);
      outfit.add(product);
    });
  }

  void _selectSize(String value) {
    ref.read(selectedFitSizeProvider.notifier).state = value;
    setState(() => size = value);
  }

  void _selectColour(String value) {
    ref.read(selectedFitColourProvider.notifier).state = value;
    setState(() => colour = value);
  }

  void _addOne() {
    ref
        .read(cartProvider.notifier)
        .add(
          ref.read(selectedProductProvider) ?? ref.read(productsProvider).first,
          size: size,
          colour: colour,
        );
    _toast('Selected piece added to bag');
  }

  void _addOutfit() {
    for (final item in outfit) {
      ref
          .read(cartProvider.notifier)
          .add(
            item,
            size: item == (ref.read(selectedProductProvider) ?? outfit.first)
                ? size
                : 'M',
            colour: colour,
          );
    }
    context.go('/cart');
  }

  void _saveOutfit() => showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      shape: const RoundedRectangleBorder(),
      title: const Text('Save this outfit'),
      content: const TextField(
        decoration: InputDecoration(
          labelText: 'Outfit name',
          hintText: 'Gallery opening',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialog);
            _toast('Outfit saved');
          },
          child: const Text('SAVE'),
        ),
      ],
    ),
  );
  void _share() => showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      shape: const RoundedRectangleBorder(),
      title: const Text('Privacy-safe preview'),
      content: const Text(
        'Your share link includes the styled outfit image and product names only. Body measurements, profile data and photo sources are never included.',
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialog);
            _toast('Private preview link copied');
          },
          child: const Text('COPY SAFE LINK'),
        ),
      ],
    ),
  );
  void _toast(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onFallback});
  final VoidCallback onFallback;
  @override
  Widget build(BuildContext context) => Container(
    height: 64,
    color: AppColors.ink,
    padding: EdgeInsets.symmetric(horizontal: context.isMobile ? 14 : 24),
    child: Row(
      children: [
        IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.close, color: Colors.white),
          tooltip: 'Exit fitting room',
        ),
        const SizedBox(width: 8),
        const Text(
          'st.luvella',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        if (!context.isMobile) ...[
          const SizedBox(width: 22),
          const Eyebrow(
            'Virtual fitting room / Private',
            color: AppColors.border,
          ),
        ],
        const Spacer(),
        if (!context.isMobile)
          TextButton.icon(
            onPressed: onFallback,
            icon: const Icon(Icons.devices, color: Colors.white, size: 17),
            label: const Text(
              'SWITCH VIEW',
              style: TextStyle(color: Colors.white),
            ),
          ),
        IconButton(
          onPressed: () => context.go('/cart'),
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
          tooltip: 'Shopping bag',
        ),
      ],
    ),
  );
}

class _CategoryPanel extends StatelessWidget {
  const _CategoryPanel({
    required this.category,
    required this.products,
    required this.onCategory,
    required this.onAdd,
    this.compact = false,
  });
  final String category;
  final List<Product> products;
  final ValueChanged<String> onCategory;
  final ValueChanged<Product> onAdd;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    const categories = [
      'Tops',
      'Bottoms',
      'Outerwear',
      'Dresses',
      'Shoes',
      'Accessories',
    ];
    final list = products.where((p) => p.has3dAsset).toList();
    return Container(
      color: AppColors.canvas,
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            const Eyebrow('Wardrobe'),
            const SizedBox(height: 17),
          ],
          SizedBox(
            height: compact ? 42 : null,
            child: compact
                ? ListView(
                    scrollDirection: Axis.horizontal,
                    children: categories
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(item),
                              selected: category == item,
                              onSelected: (_) => onCategory(item),
                            ),
                          ),
                        )
                        .toList(),
                  )
                : Column(
                    children: categories
                        .map(
                          (item) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              item,
                              style: TextStyle(
                                fontWeight: category == item
                                    ? FontWeight.w800
                                    : FontWeight.w400,
                              ),
                            ),
                            trailing: category == item
                                ? const Icon(Icons.arrow_forward, size: 16)
                                : null,
                            onTap: () => onCategory(item),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),
          if (!compact) const Divider(),
          if (!compact) const SizedBox(height: 16),
          if (!compact) const Eyebrow('Suggested for you'),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              scrollDirection: compact ? Axis.horizontal : Axis.vertical,
              children: list
                  .take(5)
                  .map(
                    (product) => InkWell(
                      onTap: () => onAdd(product),
                      child: Container(
                        width: compact ? 105 : null,
                        margin: EdgeInsets.only(
                          right: compact ? 10 : 0,
                          bottom: compact ? 0 : 12,
                        ),
                        child: compact
                            ? ProductArtwork(product: product)
                            : Row(
                                children: [
                                  SizedBox(
                                    width: 62,
                                    height: 78,
                                    child: ProductArtwork(product: product),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          maxLines: 2,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          product.formattedPrice,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.add_circle_outline),
                                ],
                              ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarStage extends StatelessWidget {
  const _AvatarStage({required this.viewerKey, required this.mode});
  final GlobalKey<ThreeDViewerState> viewerKey;
  final ViewerMode mode;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: ThreeDViewer(key: viewerKey, mode: mode),
      ),
      Positioned(
        left: 0,
        right: 0,
        bottom: 18,
        child: Center(
          child: Container(
            color: AppColors.ink.withValues(alpha: .88),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Wrap(
              spacing: 3,
              children: [
                _StageButton(
                  Icons.rotate_left,
                  'Rotate left',
                  () => viewerKey.currentState?.rotate(-.25),
                ),
                _StageButton(
                  Icons.rotate_right,
                  'Rotate right',
                  () => viewerKey.currentState?.rotate(.25),
                ),
                _StageButton(
                  Icons.zoom_in,
                  'Zoom in',
                  () => viewerKey.currentState?.zoomBy(.1),
                ),
                _StageButton(
                  Icons.zoom_out,
                  'Zoom out',
                  () => viewerKey.currentState?.zoomBy(-.1),
                ),
                _StageButton(
                  Icons.refresh,
                  'Reset',
                  () => viewerKey.currentState?.reset(),
                ),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        top: 16,
        right: 16,
        child: Container(
          color: AppColors.white.withValues(alpha: .92),
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 'front', label: Text('F')),
              ButtonSegment(value: 'side', label: Text('S')),
              ButtonSegment(value: 'back', label: Text('B')),
            ],
            selected: const {'front'},
            onSelectionChanged: (v) => viewerKey.currentState?.setView(v.first),
          ),
        ),
      ),
    ],
  );
}

class _StageButton extends StatelessWidget {
  const _StageButton(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: label,
    onPressed: onTap,
    color: Colors.white,
    icon: Icon(icon, size: 19),
  );
}

class _FitPanel extends StatelessWidget {
  const _FitPanel({
    required this.product,
    required this.size,
    required this.colour,
    required this.outfit,
    required this.onSize,
    required this.onColour,
    required this.onAdd,
    required this.onAddOutfit,
    required this.onSave,
    required this.onShare,
  });
  final Product product;
  final String size;
  final String colour;
  final List<Product> outfit;
  final ValueChanged<String> onSize;
  final ValueChanged<String> onColour;
  final VoidCallback onAdd;
  final VoidCallback onAddOutfit;
  final VoidCallback onSave;
  final VoidCallback onShare;
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.white,
    padding: const EdgeInsets.all(22),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Eyebrow('On your avatar'),
          const SizedBox(height: 10),
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 5),
          Text(product.formattedPrice),
          const SizedBox(height: 24),
          const Eyebrow('Recommended size'),
          const SizedBox(height: 10),
          Row(
            children: ['S', 'M', 'L']
                .map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(v),
                      selected: size == v,
                      onSelected: (_) => onSize(v),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Eyebrow('Fit confidence'),
              Text(
                '92%',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const LinearProgressIndicator(
            value: .92,
            color: AppColors.success,
            backgroundColor: AppColors.border,
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 7,
            children: [
              Chip(label: Text('SHOULDER · REGULAR')),
              Chip(label: Text('WAIST · FITTED')),
              Chip(label: Text('HIP · LOOSE')),
            ],
          ),
          const SizedBox(height: 20),
          const Eyebrow('Colour'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            children: ['Black', 'Ivory', 'Vermilion']
                .map(
                  (v) => ChoiceChip(
                    label: Text(v),
                    selected: colour == v,
                    onSelected: (_) => onColour(v),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Container(
            color: const Color(0xFFEAF3EE),
            padding: const EdgeInsets.all(13),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, color: AppColors.success, size: 18),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Size M should feel close at the waist with ease through the hip.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: onAddOutfit,
            child: Text('ADD OUTFIT (${outfit.length}) TO BAG'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onAdd, child: const Text('ADD THIS PIECE')),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onSave,
            child: const Text('SAVE & NAME OUTFIT'),
          ),
          TextButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.ios_share, size: 17),
            label: const Text('SHARE SAFE PREVIEW'),
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          const Eyebrow('Body summary'),
          const SizedBox(height: 9),
          const Text(
            'Profile: My everyday fit\nHeight: 170 cm · Updated today',
            style: TextStyle(color: AppColors.muted, height: 1.7),
          ),
          const SizedBox(height: 8),
          const Text(
            'Measurements stay private and are never shown in shared links.',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    ),
  );
}

class _OutfitTray extends StatelessWidget {
  const _OutfitTray({
    required this.outfit,
    required this.onRemove,
    required this.onDuplicate,
  });
  final List<Product> outfit;
  final ValueChanged<Product> onRemove;
  final VoidCallback onDuplicate;
  @override
  Widget build(BuildContext context) => Container(
    height: 128,
    color: AppColors.ink,
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
    child: Row(
      children: [
        const SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Eyebrow('On a hanger', color: AppColors.border),
              SizedBox(height: 6),
              Text(
                'OUTFIT 01',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: outfit
                .map(
                  (product) => Container(
                    width: 210,
                    margin: const EdgeInsets.only(right: 10),
                    color: AppColors.charcoal,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 65,
                          child: ProductArtwork(product: product),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => onRemove(product),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
          ),
          onPressed: onDuplicate,
          icon: const Icon(Icons.copy_outlined),
          label: const Text('DUPLICATE'),
        ),
      ],
    ),
  );
}
