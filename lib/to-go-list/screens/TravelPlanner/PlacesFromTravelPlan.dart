import 'package:flutter/material.dart';

class PlacesFromTravelPlan extends StatelessWidget {
  final List<String> selectedPlaces;

  const PlacesFromTravelPlan({super.key, required this.selectedPlaces});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16.0),
          const Text(
            'Selected Places:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12.0),
          if (selectedPlaces.isEmpty)
            const Text(
              'No places selected.',
              style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
            )
          else
            ListView(
              shrinkWrap: true,
              children: selectedPlaces.map((place) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    '• $place',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
