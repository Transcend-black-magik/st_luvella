import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/catalog/domain/product.dart';

final productsProvider = Provider<List<Product>>((ref) => sampleProducts);

class CartLine {
  const CartLine({
    required this.product,
    this.size = 'M',
    this.colour = 'Black',
    this.quantity = 1,
  });
  final Product product;
  final String size;
  final String colour;
  final int quantity;
  CartLine copyWith({int? quantity}) => CartLine(
    product: product,
    size: size,
    colour: colour,
    quantity: quantity ?? this.quantity,
  );
}

class CartNotifier extends StateNotifier<List<CartLine>> {
  CartNotifier() : super(const []);

  void add(Product product, {String size = 'M', String colour = 'Black'}) {
    final index = state.indexWhere(
      (line) =>
          line.product.id == product.id &&
          line.size == size &&
          line.colour == colour,
    );
    if (index < 0) {
      state = [
        ...state,
        CartLine(product: product, size: size, colour: colour),
      ];
    } else {
      final next = [...state];
      next[index] = next[index].copyWith(quantity: next[index].quantity + 1);
      state = next;
    }
  }

  void removeAt(int index) => state = [...state]..removeAt(index);
  void changeQuantity(int index, int delta) {
    final next = [...state];
    final quantity = next[index].quantity + delta;
    if (quantity <= 0) {
      next.removeAt(index);
    } else {
      next[index] = next[index].copyWith(quantity: quantity);
    }
    state = next;
  }

  void clear() => state = const [];
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartLine>>(
  (ref) => CartNotifier(),
);
final cartCountProvider = Provider<int>(
  (ref) =>
      ref.watch(cartProvider).fold(0, (total, line) => total + line.quantity),
);
final cartTotalProvider = Provider<int>(
  (ref) => ref
      .watch(cartProvider)
      .fold(0, (total, line) => total + line.product.price * line.quantity),
);

class WishlistNotifier extends StateNotifier<Set<String>> {
  WishlistNotifier() : super(<String>{});
  void toggle(String id) =>
      state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, Set<String>>(
  (ref) => WishlistNotifier(),
);

class MockAuthNotifier extends StateNotifier<bool> {
  MockAuthNotifier() : super(false);
  void signIn() => state = true;
  void signOut() => state = false;
}

final authProvider = StateNotifierProvider<MockAuthNotifier, bool>(
  (ref) => MockAuthNotifier(),
);
final selectedProductProvider = StateProvider<Product?>((ref) => null);
final selectedFitSizeProvider = StateProvider<String>((ref) => 'M');
final selectedFitColourProvider = StateProvider<String>((ref) => 'Black');
