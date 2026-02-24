import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productloop/features/products/providers/filter_provider.dart';
import 'package:productloop/features/products/providers/product_providers.dart';
import 'package:productloop/features/products/ui/product_card.dart';
import 'package:productloop/features/products/ui/skeleton_product_card.dart';

class ProductFeedScreen extends ConsumerWidget {
  const ProductFeedScreen({super.key});

  final List<String> categories = const [
    'All',
    'electronics',
    'jewelery',
    "men's clothing",
    "women's clothing",
    'beauty',
    'fragrances',
    'furniture',
    'groceries',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredProductsAsync = ref.watch(filteredProductsProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (value) => ref.read(searchQueryProvider.notifier).setSearchQuery(value),
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
              ),
            ),
          ),
        ),
        
        // Category Filter Row
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final isSelected = selectedCategory == categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(
                    categories[index].toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(categoryFilterProvider.notifier).setCategory(categories[index]);
                    }
                  },
                  showCheckmark: false,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              );
            },
          ),
        ),
        
        // Product Feed list View
        Expanded(
          child: filteredProductsAsync.when(
            data: (products) {
              if (products.isEmpty) {
                return const Center(child: Text('No products available for this category.'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  // ignore: unused_result
                  ref.refresh(productsProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                ),
              );
            },
            loading: () => ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: 4,
              itemBuilder: (context, index) => const SkeletonProductCard(),
            ),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load products.',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // ignore: unused_result
                        ref.refresh(productsProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
