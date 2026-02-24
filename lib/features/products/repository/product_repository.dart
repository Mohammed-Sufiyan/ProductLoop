import 'package:dio/dio.dart';
import 'package:productloop/core/api/api_client.dart';
import 'package:productloop/core/storage/hive_service.dart';
import 'package:productloop/features/products/models/product.dart';

class ProductRepository {
  final ApiClient _apiClient;
  final Dio _dummyDio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));

  ProductRepository(this._apiClient);

  Future<List<Product>> fetchProducts() async {
    try {
      // Fetch from both APIs in parallel
      final results = await Future.wait([
        _fetchFakeStoreProducts(),
        _fetchDummyJsonProducts(),
      ]);

      final allProducts = [...results[0], ...results[1]];

      // Cache the combined data
      final cacheData = allProducts.map((p) => {
        'id': p.id,
        'title': p.title,
        'price': p.price,
        'description': p.description,
        'category': p.category,
        'image': p.image,
      }).toList();
      HiveService().cacheProducts(cacheData);

      return allProducts;
    } catch (e) {
      // Offline fallback: Attempt to load from cache
      final cachedData = HiveService().getCachedProducts();
      if (cachedData != null && cachedData.isNotEmpty) {
        return cachedData.map((json) => Product.fromJson(Map<String, dynamic>.from(json))).toList();
      }
      rethrow;
    }
  }

  Future<List<Product>> _fetchFakeStoreProducts() async {
    try {
      final response = await _apiClient.get('/products');
      final data = response.data as List;
      return data.map((json) => Product.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (_) {
      return []; // If FakeStoreAPI fails, still show DummyJSON products
    }
  }

  Future<List<Product>> _fetchDummyJsonProducts() async {
    try {
      final response = await _dummyDio.get('/products?limit=30&skip=0');
      final data = response.data['products'] as List;
      return data.map((json) => Product.fromDummyJson(Map<String, dynamic>.from(json))).toList();
    } catch (_) {
      return []; // If DummyJSON fails, still show FakeStoreAPI products
    }
  }
}
