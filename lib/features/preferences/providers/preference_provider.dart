import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productloop/core/storage/hive_service.dart';

final preferenceProvider = NotifierProvider<PreferenceNotifier, Map<int, bool>>(PreferenceNotifier.new);

class PreferenceNotifier extends Notifier<Map<int, bool>> {
  @override
  Map<int, bool> build() {
    final box = HiveService().prefsBox;
    final Map<int, bool> initialPrefs = {};
    for (var key in box.keys) {
      if (key is int) {
        final val = box.get(key);
        if (val != null) initialPrefs[key] = val;
      }
    }
    return initialPrefs;
  }

  void togglePreference(int productId, bool isLiked) {
    final hiveService = HiveService();
    final currentStatus = state[productId];

    if (currentStatus == isLiked) {
      hiveService.removePreference(productId);
      state = Map.from(state)..remove(productId);
    } else {
      hiveService.setPreference(productId, isLiked);
      state = Map.from(state)..[productId] = isLiked;
    }
  }
}
