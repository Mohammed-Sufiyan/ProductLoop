import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productloop/features/preferences/providers/preference_provider.dart';
import 'package:productloop/features/products/models/product.dart';
import 'package:productloop/features/products/ui/product_details_screen.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferenceProvider);
    final bool? isLiked = preferences[product.id];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetails(context, product),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Hero(
                    tag: 'product_image_${product.id}',
                    child: Image.network(
                      product.image,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey));
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildAnimatedIconButton(
                          icon: Icons.thumb_down,
                          isActive: isLiked == false,
                          activeColor: Colors.red,
                          onPressed: () {
                            ref.read(preferenceProvider.notifier).togglePreference(product.id, false);
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildAnimatedIconButton(
                          icon: Icons.thumb_up,
                          isActive: isLiked == true,
                          activeColor: Colors.green,
                          onPressed: () {
                            ref.read(preferenceProvider.notifier).togglePreference(product.id, true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIconButton({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isActive ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Icon(
            icon,
            key: ValueKey<bool>(isActive),
            color: isActive ? activeColor : Colors.grey,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _openDetails(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(
          product: product,
        ),
      ),
    );
  }
}
