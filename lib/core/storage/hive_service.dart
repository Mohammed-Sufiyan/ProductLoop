import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String preferencesBox = 'preferences';
  static const String historyBox = 'history';
  static const String productCacheBox = 'productCache';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<bool>(preferencesBox);
    await Hive.openBox<dynamic>(historyBox);
    await Hive.openBox<dynamic>(productCacheBox);
    await Hive.openBox<dynamic>(settingsBox);
  }

  // Preferences
  Box<bool> get prefsBox => Hive.box<bool>(preferencesBox);

  void setPreference(int productId, bool isLiked) {
    prefsBox.put(productId, isLiked);
  }

  void removePreference(int productId) {
    prefsBox.delete(productId);
  }

  bool? getPreference(int productId) {
    return prefsBox.get(productId);
  }

  // History
  Box<dynamic> get histBox => Hive.box<dynamic>(historyBox);

  List<String> getHistory() {
    final history = histBox.get('visited_urls', defaultValue: <dynamic>[]) as List<dynamic>;
    return history.map((e) => e.toString()).toList();
  }

  void addUrlToHistory(String historyItem) {
    var history = getHistory();
    // Remove if already exists so we can bump it to the top
    try {
      final parsedNew = jsonDecode(historyItem);
      final String? targetId = parsedNew['id']?.toString() ?? parsedNew['url'];
      history.removeWhere((item) {
        try {
          final parsedOld = jsonDecode(item);
          return (parsedOld['id']?.toString() ?? parsedOld['url']) == targetId;
        } catch (_) {
          return item == targetId; // Handle legacy unencoded URLs seamlessly
        }
      });
    } catch (_) {
      history.removeWhere((item) => item == historyItem);
    }
    history.insert(0, historyItem); // Add to beginning
    histBox.put('visited_urls', history);
  }

  void clearHistory() {
    histBox.delete('visited_urls');
  }

  // Caching
  Box<dynamic> get cacheBox => Hive.box<dynamic>(productCacheBox);

  void cacheProducts(List<dynamic> productsJson) {
    cacheBox.put('cached_products', productsJson);
  }

  List<dynamic>? getCachedProducts() {
    return cacheBox.get('cached_products') as List<dynamic>?;
  }

  // Settings
  Box<dynamic> get setBox => Hive.box<dynamic>(settingsBox);

  void setDarkMode(bool isDark) {
    setBox.put('dark_mode', isDark);
  }

  bool get isDarkMode {
    return setBox.get('dark_mode', defaultValue: false) as bool;
  }

  void setHasSeenIntro(bool seen) {
    setBox.put('has_seen_intro', seen);
  }

  bool get hasSeenIntro {
    return setBox.get('has_seen_intro', defaultValue: false) as bool;
  }
}
