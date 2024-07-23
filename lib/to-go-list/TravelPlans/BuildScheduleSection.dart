// ignore: file_names
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
Widget BuildScheduleSection(
    String title, Map<String, dynamic> schedule, List<String> scheduleKeys) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: scheduleKeys.length,
            itemBuilder: (context, index) {
              String key = scheduleKeys[index];
              return GestureDetector(
                onTap: () {
                  showSelectedPlacesPopup(
                    context,
                    key,
                    List<String>.from(schedule[key]['selectedPlaces']),
                  );
                },
                child: Card(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(key),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(),
      ],
    ),
  );
}

Future<void> showSelectedPlacesPopup(
    BuildContext context, String date, List<String> selectedPlaces) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Selected Places for $date'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: selectedPlaces.map((place) => Text(place)).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
