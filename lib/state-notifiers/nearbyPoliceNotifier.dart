import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


final policeStationProvider = StateNotifierProvider<PoliceStationNotifier, List<PoliceStation>>((ref) {
  return PoliceStationNotifier();
});

class PoliceStationNotifier extends StateNotifier<List<PoliceStation>> {
  PoliceStationNotifier() : super([]);

  Future<void> fetchNearbyPoliceStations(double latitude, double longitude, String type) async {
    final apiKey = 'AIzaSyC8KhMfL0uOnxmyfagABb9tm-CRphTEydI'; // Replace with your Google API key
    final radius = 5000; // Search within a 5km radius

    final placesApiUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$type&key=$apiKey';

    final response = await http.get(Uri.parse(placesApiUrl));

    if(response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      final List<dynamic> results = data['results'] as List<dynamic>;

      final List<PoliceStation> policeStations = results.map((result) {
        return PoliceStation(
          name: result['name'] as String,
          vicinity: result['vicinity'] as String,
          latitude: result['geometry']['location']['lat'] as double,
          longitude: result['geometry']['location']['lng'] as double,
        );
      }).toList();

      state = policeStations;
    } else {
      throw Exception('Failed to fetch nearby police stations');
    }
  }
}

class PoliceStation {
  final String name;
  final String vicinity;
  final double latitude;
  final double longitude;

  PoliceStation({required this.name, required this.vicinity, required this.latitude, required this.longitude});
}