import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/state/store_state.dart';
import '../features/admin/presentation/admin_screen.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/avatar/presentation/avatar_wizard.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/catalog/presentation/catalog_screens.dart';
import '../features/checkout/presentation/checkout_screen.dart';
import '../features/orders/presentation/orders_screen.dart';
import '../features/product/presentation/product_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/storefront/presentation/home_screen.dart';
import '../features/virtual_fit/presentation/virtual_fit_screen.dart';
import 'store_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final signedIn = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final path = state.uri.path;
      final protected =
          path == '/profile' ||
          path.startsWith('/orders') ||
          path.startsWith('/admin');
      if (protected && !signedIn) {
        return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => StoreShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/shop',
            builder: (context, state) => const CatalogScreen(),
          ),
          GoRoute(
            path: '/collections',
            builder: (context, state) => const CollectionsIndexScreen(),
          ),
          GoRoute(
            path: '/collections/:slug',
            builder: (context, state) => CatalogScreen(
              mode: 'collections',
              slug: state.pathParameters['slug'],
            ),
          ),
          GoRoute(
            path: '/new-arrivals',
            builder: (context, state) => const CatalogScreen(mode: 'new'),
          ),
          GoRoute(
            path: '/product/:slug',
            builder: (context, state) =>
                ProductScreen(slug: state.pathParameters['slug']!),
          ),
          GoRoute(
            path: '/wishlist',
            builder: (context, state) => const WishlistScreen(),
          ),
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/orders/:id',
            builder: (context, state) =>
                OrdersScreen(orderId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => AuthScreen(
              mode: AuthMode.login,
              redirectTo: state.uri.queryParameters['from'],
            ),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => AuthScreen(
              mode: AuthMode.register,
              redirectTo: state.uri.queryParameters['from'],
            ),
          ),
          GoRoute(
            path: '/forgot-password',
            builder: (context, state) =>
                const AuthScreen(mode: AuthMode.forgot),
          ),
          GoRoute(
            path: '/outfits',
            builder: (context, state) => const _OutfitsScreen(),
          ),
          GoRoute(
            path: '/outfit/:slug',
            redirect: (context, state) => '/virtual-fit',
          ),
          GoRoute(
            path: '/outproduct/:slug',
            redirect: (context, state) =>
                '/product/${state.pathParameters['slug']}',
          ),
          GoRoute(
            path: '/avatar/reviewfits',
            redirect: (context, state) => '/virtual-fit',
          ),
        ],
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/avatar/create',
        builder: (context, state) => const AvatarWizard(),
      ),
      GoRoute(
        path: '/avatar/review',
        builder: (context, state) => const AvatarWizard(initialStep: 6),
      ),
      GoRoute(
        path: '/virtual-fit',
        builder: (context, state) => const VirtualFitScreen(),
      ),
      GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
      GoRoute(
        path: '/admin/:section',
        builder: (context, state) =>
            AdminScreen(section: state.pathParameters['section'] ?? 'overview'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('404', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            const Text('This page has moved out of frame.'),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('RETURN HOME'),
            ),
          ],
        ),
      ),
    ),
  );
});

class _OutfitsScreen extends StatelessWidget {
  const _OutfitsScreen();
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.style_outlined, size: 48),
          const SizedBox(height: 18),
          Text(
            'Saved outfits',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 10),
          const Text('Your saved styling sessions will appear here.'),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: () => context.go('/virtual-fit'),
            child: const Text('STYLE A NEW OUTFIT'),
          ),
        ],
      ),
    ),
  );
}
