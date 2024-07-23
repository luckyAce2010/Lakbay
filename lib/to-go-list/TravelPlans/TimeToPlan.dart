// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/to-go-list/screens/TravelPlanner/DateCard.dart';
import 'package:lakbay/to-go-list/TravelPlans/BuildScheduleSection.dart';

import '../Screens/TravelPlanner/PlacesFromTravelPlan.dart';

class TimeToPlan extends StatefulWidget {
  final travelPlanId;

  const TimeToPlan({
    super.key,
    required this.travelPlanId,
  });

  @override
  // ignore: library_private_types_in_public_api
  TimeToPlanState createState() => TimeToPlanState();
}

class TimeToPlanState extends State<TimeToPlan> {
  List<String> dateCards = ['Select a Date'];
  List<String> selectedPlaces = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Set<String> uniqueSelectedPlaces = <String>{};
  Set<String> uniqueSelectedPlacesLat = <String>{};
  Set<String> uniqueSelectedPlacesLong = <String>{};
  Set<String> fromSelectedPlaces = <String>{};

  List<String> scheduleKeys = [];

  Future<void> onAddCard() async {
    setState(() {
      dateCards.add(dateCards[dateCards.length - 1]);
      dateCards = ['Select a Date'];
    });
    initState();
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
      DatabaseReference scheduleReference =
          _database.child("schedule/$userId/${widget.travelPlanId}");
      DatabaseEvent scheduleSnapshot = await scheduleReference.once();
      data['schedule'] =
          (scheduleSnapshot.snapshot.value as Map<dynamic, dynamic>)
              .cast<String, dynamic>(); // Convert to Map<String, dynamic>
      scheduleKeys = List<String>.from(data['schedule'].keys);
    } catch (error) {
      // Handle the error
    }

    return data;
  }

  Future<void> selectPlacesFromSavedTravelPlans() async {
    Set<String> uniqueSelectedPlaces = <String>{};

    String selectedFolderId = widget.travelPlanId;

    User? currentUser = FirebaseAuth.instance.currentUser;
    String userId = currentUser!.uid;

    DatabaseReference travelPlansReference = FirebaseDatabase.instance
        .ref()
        .child("favorites/$userId/travelPlans/$selectedFolderId/data");

    DatabaseEvent dataSnapshot = await travelPlansReference.once();
    final value = dataSnapshot.snapshot.value;

    if (value != null) {
      (value as Map<dynamic, dynamic>).forEach((key, value) async {
        String placeName = value['name'] as String? ?? 'Unknown Place';

        uniqueSelectedPlaces.add(placeName);
      });
    }

    List<String> uniquePlacesList = uniqueSelectedPlaces.toList();

    setState(() {
      selectedPlaces = uniquePlacesList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadData(),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          Map<String, dynamic> data = snapshot.data ?? {};
          List<String> scheduleKeys = List<String>.from(data['schedule'].keys);
          bool hasDates = scheduleKeys.isNotEmpty;

          return ListView(
            children: [
              NewTravelDate(
                dateCards: hasDates ? dateCards : ['Select a Date'],
                selectedPlaces: selectedPlaces,
                travelPlanId: widget.travelPlanId,
              ),
              if (hasDates)
                BuildScheduleSection(
                    'Schedule', data['schedule'], scheduleKeys),
              NewTravelDateButton(
                onAddCard: onAddCard,
                travelPlanId: widget.travelPlanId,
              ),
              Column(
                children: [
                  PlacesFromTravelPlan(selectedPlaces: selectedPlaces),
                ],
              ),
              const SizedBox(height:75),
            ],
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    selectPlacesFromSavedTravelPlans();
  }
}