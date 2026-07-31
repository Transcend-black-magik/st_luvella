import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens.dart';
import '../../../core/state/store_state.dart';
import '../../../core/widgets/editorial_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => StorePage(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Private account'),
                const SizedBox(height: 12),
                Text(
                  'Hello, Amara.',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ],
            ),
          ),
          if (!context.isMobile)
            OutlinedButton(
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
                context.go('/');
              },
              child: const Text('SIGN OUT'),
            ),
        ],
      ),
      const SizedBox(height: 48),
      LayoutBuilder(
        builder: (context, box) => Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            _ProfileCard(
              width: context.isMobile ? box.maxWidth : (box.maxWidth - 36) / 3,
              icon: Icons.shopping_bag_outlined,
              label: 'ORDERS',
              title: '2 active orders',
              action: 'TRACK DELIVERY',
              onTap: () => context.go('/orders'),
            ),
            _ProfileCard(
              width: context.isMobile ? box.maxWidth : (box.maxWidth - 36) / 3,
              icon: Icons.accessibility_new,
              label: 'FIT PROFILE',
              title: 'Avatar ready',
              action: 'OPEN FITTING ROOM',
              onTap: () => context.go('/virtual-fit'),
            ),
            _ProfileCard(
              width: context.isMobile ? box.maxWidth : (box.maxWidth - 36) / 3,
              icon: Icons.favorite_border,
              label: 'SAVED',
              title: '${ref.watch(wishlistProvider).length} saved pieces',
              action: 'VIEW WISHLIST',
              onTap: () => context.go('/wishlist'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 54),
      const Divider(),
      const SizedBox(height: 36),
      Text(
        'Account details',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 22),
      Wrap(
        spacing: 40,
        runSpacing: 22,
        children: const [
          SizedBox(
            width: 300,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Email'),
              subtitle: Text('amara@example.com'),
              trailing: Icon(Icons.edit_outlined),
            ),
          ),
          SizedBox(
            width: 300,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Default address'),
              subtitle: Text('Ikoyi, Lagos'),
              trailing: Icon(Icons.edit_outlined),
            ),
          ),
          SizedBox(
            width: 300,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Privacy & body data'),
              subtitle: Text('Manage consent and deletion'),
              trailing: Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
      if (context.isMobile) ...[
        const SizedBox(height: 35),
        OutlinedButton(
          onPressed: () {
            ref.read(authProvider.notifier).signOut();
            context.go('/');
          },
          child: const Text('SIGN OUT'),
        ),
      ],
    ],
  );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.title,
    required this.action,
    required this.onTap,
  });
  final double width;
  final IconData icon;
  final String label;
  final String title;
  final String action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 230,
    color: AppColors.white,
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 27),
        const Spacer(),
        Eyebrow(label),
        const SizedBox(height: 8),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        UnderlineLink(action, onTap: onTap),
      ],
    ),
  );
}
