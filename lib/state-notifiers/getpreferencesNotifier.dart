// ignore_for_file: file_names
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedPreferencesProvider =
    StateNotifierProvider<PreferencesNotifier, List<String>>(
  (ref) => PreferencesNotifier(),
);

class PreferencesNotifier extends StateNotifier<List<String>> {
  PreferencesNotifier() : super([]);

  void addPreference(String preference) {
    state = List.from(state)..add(preference);
  }

  void removePreference(String preference) {
    state = List.from(state)..remove(preference);
  }

  void resetPreferences() {
    state = [];
  }

  void selectAllPreferences() {
    state = [
      'Rural areas / countryside',
      'Parks',
      'Zoo',
      'Coffee Shops',
      'Beaches',
      'Resorts',
      'Mountains / Hiking',
      'Malls',
      'Hotels',
      'Historical Sites',
      'Social Hubs (Bars)',
      'Street Foods',
      'Restaurants',
    ];
  }
}
