import 'dart:convert';

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  // We generate a custom HTML data URI to show in the WebView since FakeStoreAPI only provides raw JSON.
  String getUrl({bool isDark = false}) {
    final bg = isDark ? '#0F172A' : '#ffffff';
    final textColor = isDark ? '#F1F5F9' : '#333333';
    final categoryBg = isDark ? '#1E293B' : '#eeeeee';
    final categoryText = isDark ? '#F8FAFC' : '#333333';
    final priceColor = isDark ? '#A855F7' : '#9333EA';

    final html = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: sans-serif; padding: 20px; line-height: 1.6; background-color: $bg; color: $textColor; }
          h1 { font-size: 24px; margin-bottom: 10px; }
          .price { font-size: 22px; font-weight: bold; color: $priceColor; margin-bottom: 15px; }
          .category { display: inline-block; background: $categoryBg; color: $categoryText; padding: 4px 8px; border-radius: 4px; font-size: 12px; text-transform: uppercase; margin-bottom: 15px; }
          ::-webkit-scrollbar { display: none; }
        </style>
      </head>
      <body>
        <div class="category">$category</div>
        <h1>$title</h1>
        <div class="price">\$${price.toStringAsFixed(2)}</div>
        <p>$description</p>
      </body>
      </html>
    ''';
    return Uri.dataFromString(html, mimeType: 'text/html', encoding: utf8).toString();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      category: json['category'],
      image: json['image'],
    );
  }

  /// Maps DummyJSON format to our Product model
  factory Product.fromDummyJson(Map<String, dynamic> json) {
    return Product(
      id: 1000 + (json['id'] as int), // Offset IDs to avoid collisions with FakeStoreAPI
      title: json['title'] ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
      category: json['category'] ?? 'general',
      image: json['thumbnail'] ?? json['images']?[0] ?? '',
    );
  }
}
