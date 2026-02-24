import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productloop/core/storage/hive_service.dart';

final historyProvider = NotifierProvider<HistoryNotifier, List<String>>(HistoryNotifier.new);

class HistoryNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final history = HiveService().getHistory();
    // Auto-migrate: remove legacy raw data:text/html entries
    final cleaned = history.where((item) => !item.startsWith('data:')).toList();
    if (cleaned.length != history.length) {
      HiveService().histBox.put('visited_urls', cleaned);
    }
    return cleaned;
  }

  void addUrlToHistory(String url) {
    HiveService().addUrlToHistory(url);
    state = HiveService().getHistory();
  }

  void clearHistory() {
    HiveService().clearHistory();
    state = [];
  }

  void replaceHistory(List<String> newHistory) {
    HiveService().histBox.put('visited_urls', newHistory);
    state = newHistory;
  }
}
