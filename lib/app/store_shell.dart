import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/tokens.dart';
import '../core/state/store_state.dart';
import '../core/widgets/editorial_widgets.dart';

class StoreShell extends ConsumerWidget {
  const StoreShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    return Scaffold(
      drawer: context.width < 1100 ? const _MobileDrawer() : null,
      body: SafeArea(
        child: Column(
          children: [
            const _AnnouncementBar(),
            _Header(cartCount: count),
            const Divider(),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementBar extends StatelessWidget {
  const _AnnouncementBar();
  @override
  Widget build(BuildContext context) => Container(
    height: 31,
    color: AppColors.ink,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Text(
      'COMPLIMENTARY DELIVERY IN NIGERIA ON ORDERS OVER ₦150,000',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.white,
        fontSize: 9,
        letterSpacing: 1.4,
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.cartCount});
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    final mobile = context.width < 1100;
    return SizedBox(
      height: 74,
      child: Padding(
        padding: context.pagePadding,
        child: Row(
          children: [
            if (mobile)
              Builder(
                builder: (context) => IconButton(
                  tooltip: 'Open menu',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu),
                ),
              )
            else
              SizedBox(
                width: 440,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      _NavLink('Shop', '/shop'),
                      _NavLink('Collections', '/collections'),
                      _NavLink('New arrivals', '/new-arrivals'),
                      _NavLink('Virtual fit', '/virtual-fit'),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: InkWell(
                  onTap: () => context.go('/'),
                  child: const BrandLogo(height: 30, fontSize: 20),
                ),
              ),
            ),
            SizedBox(
              width: mobile ? 116 : 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Search',
                    onPressed: () => _showSearch(context),
                    icon: const Icon(Icons.search, size: 21),
                  ),
                  if (!mobile)
                    IconButton(
                      tooltip: 'Wishlist',
                      onPressed: () => context.go('/wishlist'),
                      icon: const Icon(Icons.favorite_border, size: 21),
                    ),
                  if (!mobile)
                    IconButton(
                      tooltip: 'Account',
                      onPressed: () => context.go('/profile'),
                      icon: const Icon(Icons.person_outline, size: 22),
                    ),
                  Badge(
                    label: Text('$cartCount'),
                    isLabelVisible: cartCount > 0,
                    child: IconButton(
                      tooltip: 'Shopping bag, $cartCount items',
                      onPressed: () => context.go('/cart'),
                      icon: const Icon(Icons.shopping_bag_outlined, size: 21),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: const RoundedRectangleBorder(),
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.isMobile ? 18 : 80,
        vertical: 50,
      ),
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: 14),
            Expanded(
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search pieces, collections and stories…',
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    ),
  );
}

class _NavLink extends StatelessWidget {
  const _NavLink(this.label, this.path);
  final String label;
  final String path;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 18),
    child: InkWell(
      onTap: () => context.go(path),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
  );
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer();
  @override
  Widget build(BuildContext context) {
    final links = [
      ('Shop', '/shop'),
      ('Collections', '/collections'),
      ('New arrivals', '/new-arrivals'),
      ('Virtual fit', '/virtual-fit'),
      ('Wishlist', '/wishlist'),
      ('Account', '/profile'),
      ('Orders', '/orders'),
    ];
    return Drawer(
      shape: const RoundedRectangleBorder(),
      backgroundColor: AppColors.canvas,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BrandLogo(height: 30, fontSize: 20),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 42),
              ...links.map(
                (link) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    link.$1,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  trailing: const Icon(Icons.arrow_outward, size: 18),
                  onTap: () {
                    Navigator.pop(context);
                    context.go(link.$2);
                  },
                ),
              ),
              const Spacer(),
              const Text('Nigeria / NGN'),
            ],
          ),
        ),
      ),
    );
  }
}
