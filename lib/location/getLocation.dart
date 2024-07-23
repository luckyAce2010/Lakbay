// ignore: file_names
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class LocationData {
  final double latitude;
  final double longitude;
  final String city;
  final String cityRegion;
  final String formattedAddress;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.cityRegion,
    required this.formattedAddress,
  });
}

class LocationService {
  Future<LocationData> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // Handle the case where location service is not enabled
      throw LocationServiceDisabledException();
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      // Handle the case where location permission is denied
      throw LocationPermissionDeniedException();
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;
      String fetchedCity = '';
      String formattedAddress = '';

      const apiKey = 'AIzaSyC8KhMfL0uOnxmyfagABb9tm-CRphTEydI';

          //disabled as of now
          // 'AIzaSyC8KhMfL0uOnxmyfagABb9tm-CRphTEydI'; // Replace with your API key
      final apiUrl =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List;

          if (results.isNotEmpty) {
            final addressComponents = results[0]['address_components'] as List;

            for (final component in addressComponents) {
              final types = component['types'] as List;

              if (types.contains('locality')) {
                fetchedCity = component['long_name'];
              }

              if (types.contains('administrative_area_level_1')) {
                formattedAddress = component['long_name']; // Corrected line
              }
            }
          }
        }
      }

      String cityWithPostalCode = '';

      // Split the address by commas
      List<String> addressParts = formattedAddress.split(',');

      // Assuming the city is the second part and postal code is the third part in the split list
      if (addressParts.length >= 3) {
        cityWithPostalCode = '${addressParts[1].trim()}, ${addressParts[2].trim()}';
      } else {
        print('Invalid address format');
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        city: fetchedCity,
        cityRegion: cityWithPostalCode,
        formattedAddress: formattedAddress,
      );
    } catch (e) {
      // Handle other errors that might occur during location retrieval
      throw LocationRetrievalException(e.toString());
    }
  }
}

class LocationServiceDisabledException implements Exception {
  final String message = 'Location service is disabled.';
}

class LocationPermissionDeniedException implements Exception {
  final String message = 'Location permission is denied.';
}

class LocationRetrievalException implements Exception {
  final String message;

  LocationRetrievalException(String errorMessage)
      : message = 'Location retrieval error: $errorMessage';
}
