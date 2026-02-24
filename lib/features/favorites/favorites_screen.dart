import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productloop/features/preferences/providers/preference_provider.dart';
import 'package:productloop/features/products/providers/product_providers.dart';
import 'package:productloop/features/products/ui/product_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final preferences = ref.watch(preferenceProvider);

    return productsAsync.when(
      data: (products) {
        final favoriteProducts = products.where((p) => preferences[p.id] == true).toList();

        if (favoriteProducts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No favorites yet.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: favoriteProducts.length,
          itemBuilder: (context, index) {
            return ProductCard(product: favoriteProducts[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Failed to load products: \${e.toString()}')),
    );
  }
}
