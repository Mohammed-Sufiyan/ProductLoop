import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productloop/features/products/models/product.dart';
import 'package:productloop/features/products/providers/product_providers.dart';

final categoryFilterProvider = NotifierProvider<CategoryFilterNotifier, String>(CategoryFilterNotifier.new);

class CategoryFilterNotifier extends Notifier<String> {
  @override
  String build() {
    return 'All'; // Default filter
  }

  void setCategory(String category) {
    state = category;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() {
    return ''; // Default empty search
  }

  void setSearchQuery(String query) {
    state = query;
  }
}

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final selectedCategory = ref.watch(categoryFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  return productsAsync.whenData((products) {
    return products.where((p) {
      final matchesCategory = selectedCategory == 'All' || p.category.toLowerCase() == selectedCategory.toLowerCase();
      final matchesSearch = searchQuery.isEmpty || p.title.toLowerCase().contains(searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  });
});
