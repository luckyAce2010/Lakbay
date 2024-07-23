// ignore: file_names
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lakbay/location/getLocation.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, LocationData?>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<LocationData?> {
  LocationNotifier() : super(null);

  Future<void> updateLocation() async {
    LocationData locationData = await LocationService().getCurrentPosition();
    state = locationData;
  }
}