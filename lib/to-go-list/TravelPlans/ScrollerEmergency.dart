// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ScrollerEmergency extends StatefulWidget {
  const ScrollerEmergency({super.key});

  @override
  _ScrollerEmergencyState createState() => _ScrollerEmergencyState();
}

class _ScrollerEmergencyState extends State<ScrollerEmergency> {
  late LocationData currentLocation;
  late double temperature; // Example variable to hold temperature data
  late String weatherCondition;

  @override
  void initState() {
    super.initState();
    getLocationAndWeatherData();
  }

  Future<void> getLocationAndWeatherData() async {
    Location location = Location();
    currentLocation = await location.getLocation();

    if (currentLocation != null) {
      double latitude = currentLocation.latitude;
      double longitude = currentLocation.longitude;

      String apiKey = await getApi();

      String apiUrl =
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> weatherData = json.decode(response.body);

        // Update UI with weather data
        setState(() {
          temperature = weatherData['main']['temp'] -
              273.15; // Convert from Kelvin to Celsius
          weatherCondition = weatherData['weather'][0]['main'];
        });
      } else {}
    } else {}
  }

  Future<String> getApi() async {
    return 'db26c2cc1c2f1b07379e16cfbab68c92';
  }

  Widget buildWeatherIcon() {
    IconData icon;
    String message;
    String reminder;

    switch (weatherCondition) {
      case 'Rain':
        icon = Icons.umbrella;
        message = 'Bring an umbrella';
        reminder = 'Remember to bring an umbrella!';
        break;
      case 'Clouds':
        icon = Icons.cloud;

        message = 'Cloudy weather';
        reminder = 'It might be cloudy today.';
        break;
      case 'Clear':
        icon = Icons.wb_sunny;
        message = 'Clear sky';
        reminder = 'Enjoy the clear sky!';
        break;
      default:
        icon = Icons.warning;
        message = 'Unknown weather condition';
        reminder = 'No specific reminder for this weather condition.';
        break;
    }

    return Column(
      children: [
        Icon(icon, size: 170, color: Colors.blue),
        const SizedBox(height: 10),
        Text(message,
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
        const SizedBox(height: 5), // Adjust spacing
        Text(reminder, style: const TextStyle(fontSize: 14, color: Colors.red)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: currentLocation == null
            ? const CircularProgressIndicator()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                child: Column(
                  children: [
                    const Text(
                      'Current Weather:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),
                    temperature != null
                        ? Column(
                            children: [
                              Text(
                                'Temperature: ${temperature.toStringAsFixed(2)}°C',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 20),
                              buildWeatherIcon(),
                            ],
                          )
                        : Container(), // Display temperature and weather icon if available
                  ],
                ),
              ),
      ),
    );
  }
}

class Location {
  Future<LocationData> getLocation() async {
    // Implement the logic to get the current location
    // Return a LocationData object
    // For simplicity, using hardcoded values in this example
    return LocationData(14.5850368, 121.0843136);
  }
}

class LocationData {
  final double latitude;
  final double longitude;

  LocationData(this.latitude, this.longitude);
}
