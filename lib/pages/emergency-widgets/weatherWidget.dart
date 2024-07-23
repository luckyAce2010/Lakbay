import 'package:flutter/material.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:recase/recase.dart';

// Create a provider for weather data using Riverpod
final weatherDataProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, location) async {
  const apiKey =
      'db26c2cc1c2f1b07379e16cfbab68c92'; // Replace with your OpenWeatherMap API key
  final url = Uri.parse(
      'http://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load weather data');
  }
});

class WeatherInfoWidget extends ConsumerWidget {
  final String location;

  const WeatherInfoWidget({super.key, required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherDataAsyncValue = ref.watch(weatherDataProvider(location));

    return weatherDataAsyncValue.when(
      data: (weatherData) {
        final iconCode = weatherData['weather'][0]['icon'];
        final String description = weatherData['weather'][0]['description'];
        final cityName = weatherData['name'];
        final tempKelvin = weatherData['main']['temp'];
        final tempCelsius = tempKelvin - 273.15;

        ReCase reCase = ReCase(description);
        String capitalizedDescription = reCase.titleCase;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.accentDarkGreenColor,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display weather icon
              Image.network(
                'http://openweathermap.org/img/w/$iconCode.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                width: 10.0,
              ),
              // Display weather description and city name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CardTitleText(
                      capitalizedDescription, AppColors.accentWhiteColor),
                  NormalText('$cityName', AppColors.accentWhiteColor),
                ],
              ),
              const Spacer(),
              // Display temperature
              Text(
                '${tempCelsius.toStringAsFixed(1)} °C',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentWhiteColor,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => const Text('Error loading weather data'),
    );
  }
}
