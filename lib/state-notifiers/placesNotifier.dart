// ignore_for_file: file_names
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final placesNotifier = StateNotifierProvider<PlacesNotifier, List<String>>(
  (ref) => PlacesNotifier(),
);

class PlacesNotifier extends StateNotifier<List<String>> {
  PlacesNotifier() : super([]);

  void addPlaces(List<String> preferences) {
    state = List.from(state)..addAll(preferences);
    if (kDebugMode) {
      print(state);
      print("added $preferences");
    }
  }

  void removePlaces(String preference) {
    state = List.from(state)..remove(preference);
  }

  void resetPlaces() {
    state = [];
  }

  List<String> returnPlaces() {
    return state;
  }
}
