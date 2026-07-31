import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luvella/app/app.dart';
import 'package:st_luvella/app/router.dart';
import 'package:st_luvella/core/state/store_state.dart';
import 'package:st_luvella/features/catalog/domain/product.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('editorial homepage renders on desktop', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: LuvellaApp()));
    await tester.pumpAndSettle();

    expect(find.text('st.luvella'), findsWidgets);
    expect(find.text('FORM\nFOLLOWS\nFEELING'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile homepage uses accessible compact navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: LuvellaApp()));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Open menu'), findsOneWidget);
    expect(find.byTooltip('Search'), findsOneWidget);
    expect(find.byTooltip('Shopping bag, 0 items'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('protected order route redirects to sign in', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LuvellaApp(),
      ),
    );
    router.go('/orders');
    await tester.pumpAndSettle();

    expect(find.text('Welcome back.'), findsOneWidget);
    expect(find.byKey(const Key('auth-submit')), findsOneWidget);
  });

  test('cart notifier keeps selected SKU and calculates quantities', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(cartProvider.notifier)
        .add(sampleProducts.first, size: 'L', colour: 'Vermilion');
    container
        .read(cartProvider.notifier)
        .add(sampleProducts.first, size: 'L', colour: 'Vermilion');

    final cart = container.read(cartProvider);
    expect(cart.single.quantity, 2);
    expect(cart.single.size, 'L');
    expect(container.read(cartTotalProvider), sampleProducts.first.price * 2);
  });
}
