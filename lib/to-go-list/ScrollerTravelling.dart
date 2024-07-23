// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lakbay/To-Go-List/Screens/Travelling/TravellingButton.dart';
import 'package:lakbay/To-Go-List/Screens/Travelling/TravellingMapScreen.dart';
import 'package:intl/intl.dart';


class ScrollerTravelling extends StatefulWidget {
  final String? travelPlanId;

  const ScrollerTravelling({super.key, this.travelPlanId});

  @override
  _ScrollerTravellingState createState() => _ScrollerTravellingState();
}

class _ScrollerTravellingState extends State<ScrollerTravelling> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Set<String> uniqueSelectedPlaces = <String>{};
  Set<String> uniqueSelectedPlacesLat = <String>{};
  Set<String> uniqueSelectedPlacesLong = <String>{};
  Set<String> fromSelectedPlaces = <String>{};
  Map<String, dynamic> historyData = {
    'places': [], // List to store place information
    'schedule': {}, // Schedule data
  };

  List<String> scheduleKeys = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travelling Mode'),
      ),
      body: FutureBuilder(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data == null) {
            // Handle the case where snapshot.data is null
            return const Text('Data is null');
          } else {
            Map<String, dynamic> data = snapshot.data as Map<String, dynamic>;
            bool hasDates = scheduleKeys.isNotEmpty;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasDates)
                  _buildScheduleSection('Schedule', data['schedule']),
                _buildSection('To Go List', fromSelectedPlaces,
                    uniqueSelectedPlacesLat, uniqueSelectedPlacesLong),
                Center(
                  child: _buildButton(
                    'Go to Travel Map',
                    () {
                      // Navigate to the Packing List screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TravellingMapScreen(
                                selectedPlaces: fromSelectedPlaces)),
                      );
                    },
                  ),
                ),
                Center(
                  child: TravellingButton(
                      travelPlanId: widget.travelPlanId!, data: historyData),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadData() async {
    Map<String, dynamic> data = {
      'schedule': {}, // Provide a default value for schedule
    };

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return data;
      }

      String userId = currentUser.uid;

      // Load Favorites
      DatabaseReference travelPlansReference = FirebaseDatabase.instance
          .ref()
          .child("favorites/$userId/travelPlans/${widget.travelPlanId}/data");

      DatabaseEvent dataSnapshot = await travelPlansReference.once();
      final value = dataSnapshot.snapshot.value;

      if (value != null) {
        (value as Map<dynamic, dynamic>).forEach((key, value) async {
          String placeName = value['name'] as String? ?? 'Unknown Place';
          String placeNameLat =
              value['latitude'].toStringAsFixed(2) as String? ??
                  'Unknown Place';
          String placeNameLong =
              value['longitude'].toStringAsFixed(2) as String? ??
                  'Unknown Place';

          uniqueSelectedPlaces.add(placeName);
          uniqueSelectedPlacesLat.add(placeNameLat);
          uniqueSelectedPlacesLong.add(placeNameLong);
        });
      }

      // Load Schedule
      // Load Schedule
      DatabaseReference scheduleReference =
          _database.child("schedule/$userId/${widget.travelPlanId}");
      DatabaseEvent scheduleSnapshot = await scheduleReference.once();
      data['schedule'] =
          (scheduleSnapshot.snapshot.value as Map<dynamic, dynamic>)
              .cast<String, dynamic>(); // Convert to Map<String, dynamic>
      scheduleKeys = List<String>.from(data['schedule'].keys).reversed.toList();
      historyData['schedule'] = data['schedule'];
      historyData['places'] = uniqueSelectedPlaces.map((place) {
        // Retrieve latitude and longitude for the current place
        int index = uniqueSelectedPlaces.toList().indexOf(place);
        String placeNameLat = uniqueSelectedPlacesLat.elementAt(index);
        String placeNameLong = uniqueSelectedPlacesLong.elementAt(index);

        // Create a map for the place including name, latitude, and longitude
        Map<String, dynamic> placeInfo = {
          'name': place,
          'latitude': placeNameLat,
          'longitude': placeNameLong,
          'travelledAt': DateFormat('yyyy-MM-dd').format(DateTime.now()), 
        };

        return placeInfo;
      }).toList();
    } catch (error) {
      // Handle the error
    }

    return data;
  }

  Widget _buildSection(
    String title,
    Set<String> data,
    Set<String> uniqueSelectedPlacesLat,
    Set<String> uniqueSelectedPlacesLong,
  ) {
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
            height: 200,
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                if (index < uniqueSelectedPlacesLat.length &&
                    index < uniqueSelectedPlacesLong.length) {
                  String placeName = data.elementAt(index);
                  String placeNameLat =
                      uniqueSelectedPlacesLat.elementAt(index);
                  String placeNameLong =
                      uniqueSelectedPlacesLong.elementAt(index);

                  return CheckboxItem(
                    placeName: placeName,
                    placeNameLat: placeNameLat,
                    placeNameLong: placeNameLong,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  Widget _buildScheduleSection(String title, Map<String, dynamic> schedule) {
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
                    _handleSelectedPlacesUpdate(
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

  void _handleSelectedPlacesUpdate(List<String> selectedPlaces) {
    setState(() {
      uniqueSelectedPlaces.clear();
      fromSelectedPlaces = Set<String>.from(selectedPlaces);
    });
  }
}

class CheckboxItem extends StatefulWidget {
  final String placeName;
  final String placeNameLat;
  final String placeNameLong;

  const CheckboxItem({
    super.key,
    required this.placeName,
    required this.placeNameLat,
    required this.placeNameLong,
  });

  @override
  _CheckboxItemState createState() => _CheckboxItemState();
}

class _CheckboxItemState extends State<CheckboxItem> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        'Name: ${widget.placeName}, Latitude: ${widget.placeNameLat}, Longitude: ${widget.placeNameLong}',
      ),
      leading: Checkbox(
        value: isChecked,
        onChanged: (bool? value) {
          setState(() {
            isChecked = value ?? false;
          });
        },
      ),
    );
  }
}
