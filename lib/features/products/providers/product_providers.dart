import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productloop/core/api/api_client.dart';
import 'package:productloop/features/products/models/product.dart';
import 'package:productloop/features/products/repository/product_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRepository(apiClient);
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchProducts();
});
