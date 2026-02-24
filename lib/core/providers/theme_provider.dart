import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productloop/core/storage/hive_service.dart';

final themeProvider = NotifierProvider<ThemeNotifier, bool>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    return HiveService().isDarkMode;
  }

  void toggleTheme() {
    state = !state;
    HiveService().setDarkMode(state);
  }
}
