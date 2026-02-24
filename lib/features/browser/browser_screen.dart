import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:productloop/features/browser/history_provider.dart';

class BrowserScreen extends ConsumerStatefulWidget {
  final int productId;
  final String imageUrl;
  final String url;
  final String title;

  const BrowserScreen({
    super.key, 
    required this.productId,
    required this.imageUrl,
    required this.url, 
    required this.title
  });

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Track detailed history when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyPayload = jsonEncode({
        'id': widget.productId,
        'title': widget.title,
        'image': widget.imageUrl,
        'url': widget.url,
        'timestamp': DateTime.now().toIso8601String(),
      });
      ref.read(historyProvider.notifier).addUrlToHistory(historyPayload);
    });

    _controller = WebViewController();
    
    if (kIsWeb) {
      // NavigationDelegate is not fully supported on web, so we stop loading immediately
      _isLoading = false;
    } else {
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
        );
    }
    
    _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            height: 120,
            child: Center(
              child: Hero(
                tag: 'product_image_${widget.productId}',
                child: Image.network(widget.imageUrl),
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
