// ignore_for_file: empty_catches, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class Getters {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List> getFavorites(String travelPlanId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return [];
    }
    String userId = currentUser.uid;

    DatabaseReference favoritesReference = FirebaseDatabase.instance
        .ref()
        .child("favorites/$userId/$travelPlanId");

    DatabaseEvent event = await favoritesReference.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      dynamic data = snapshot.value;

      if (data is Map<String, dynamic>) {
        return data.values.toList();
      }
    }

    return [];
  }

  Future<List<String>> getScheduleData(String travelPlanId) async {
    List<String> selectedPlaces = [];

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return selectedPlaces;
      }

      String userId = currentUser.uid;
      DatabaseReference scheduleReference = FirebaseDatabase.instance
          .ref()
          .child("schedule/$userId/$travelPlanId");

      DatabaseEvent dataSnapshot = await scheduleReference.once();
      dynamic data = dataSnapshot.snapshot.value;

      if (data is Map<String, dynamic>) {
        // Assuming there's a key for selected places in the schedule data
        if (data['selectedPlaces'] is List<dynamic>) {
          selectedPlaces = List<String>.from(data['selectedPlaces']);
        }
      }
    } catch (error) {}

    return selectedPlaces;
  }

  Future<Map<String, List<String>>> loadTravelPlanFromDatabase() async {
    Map<String, List<String>> result = {
      'travelPlanNames': [],
      'travelPlanIds': [],
    };

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return result;
      }

      String userId = currentUser.uid;
      Query travelPlansReference = FirebaseDatabase.instance
          .ref()
          .child("favorites/$userId/travelPlans");

      DatabaseEvent dataSnapshot = await travelPlansReference.once();

      dynamic data = dataSnapshot.snapshot.value;

      if (data is Map<String, dynamic> && data.isNotEmpty) {
        data.forEach((key, value) {
          result['travelPlanNames']!.add(value['travelPlanName']);
          result['travelPlanIds']!.add(value['travelPlanId']);
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error in loadTravelPlanFromDatabase: $error");
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> getBudgetData(String travelPlanId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return {};
      }

      String userId = currentUser.uid;
      Query budgetReference =
          FirebaseDatabase.instance.ref().child("budget/$userId/$travelPlanId");

      DatabaseEvent dataSnapshot = await budgetReference.once();
      dynamic data = dataSnapshot.snapshot.value;

      if (kDebugMode) {
        print('hekki');
        print(data);
      }

      if (data is Map<dynamic, dynamic> &&
          data['selectedPlaces'] is List<dynamic> &&
          data['budget'] is List<dynamic>) {
        return {
          'selectedPlaces': List<String>.from(data['selectedPlaces']),
          'budget': List<String?>.from(data['budget']),
        };
      }
    } catch (error) {}

    return {};
  }
}

// Helper function to assign budgets randomly
List<String?> assignBudgets(List<String> places) {
  List<String?> budgets = ['low', 'medium', 'high', null];
  budgets.shuffle();

  Map<String, String?> assignedBudgets = {};
  for (String place in places) {
    assignedBudgets[place] = budgets.removeLast();
  }

  return assignedBudgets.values.toList();
}

Future<List<Map<String, String>>> getLocationList(String travelPlanId) async {
  List<Map<String, String>> locations = [];
  Set<String> uniqueNames = <String>{};

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    DatabaseReference dataReference = FirebaseDatabase.instance
        .ref()
        .child("favorites/${currentUser.uid}/travelPlans/$travelPlanId/data");

    DatabaseEvent dataSnapshot = await dataReference.once();
    dynamic data = dataSnapshot.snapshot.value;

    if (data != null && data is Map) {
      data.forEach((locationId, locationData) {
        String name = locationData['name'] ?? 'No Name';
        String price = locationData['price_level'] ?? 'No Price Available';

        // if (kDebugMode) {
        //   print('Location ID: $locationId, Name: $name, Price: $price');
        // }

        // Check if the name already exists, and add to the set if not
        if (!uniqueNames.contains(name)) {
          uniqueNames.add(name);
          locations.add({
            'name': name,
            'price_level': price,
          });
        }
      });
    }
  }

  return locations;
}
