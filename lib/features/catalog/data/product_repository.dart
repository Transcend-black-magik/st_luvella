import '../domain/product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> listProducts({String? category, String? query});
  Future<Product?> getProduct(String slug);
}

class MockProductRepository implements ProductRepository {
  @override
  Future<Product?> getProduct(String slug) async {
    for (final product in sampleProducts) {
      if (product.slug == slug) return product;
    }
    return null;
  }

  @override
  Future<List<Product>> listProducts({String? category, String? query}) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return sampleProducts.where((product) {
      final matchesCategory =
          category == null || category == 'All' || product.category == category;
      final matchesQuery =
          query == null ||
          product.name.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }
}
