// ignore_for_file: empty_catches, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Setters {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> favoriteToDatabase({
    required Map<String, dynamic> cardData,
    required String travelPlanId,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return;
      }
      String userId = currentUser.uid;

      DatabaseReference favoritesReference = FirebaseDatabase.instance
          .ref()
          .child("favorites/$userId/$travelPlanId");

      DatabaseEvent event = await favoritesReference
          .orderByChild('place_id')
          .equalTo(cardData['place_id'])
          .once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        return;
      }

      Map<String, dynamic> newFavoriteData = {
        "place_id": cardData['place_id'],
        "name": cardData['name'],
        "description": cardData['description'],
        "latitude": cardData['latitude'],
        "longitude": cardData['longitude']
      };

      DatabaseReference newFavoriteRef = favoritesReference.push();
      await newFavoriteRef.set(newFavoriteData);
    } catch (error) {}
  }

  Future<void> favoritePlaces(List<String> placeCards) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }
    String userId = currentUser.uid;

    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child("favorites/$userId");

    DatabaseEvent event = await ref.once();

    if (event.snapshot.value != null) {
      dynamic data = event.snapshot.value;

      if (data is Map<String, dynamic>) {
        data.forEach((key, value) {
          if (value is Map<String, dynamic> && value['name'] != null) {
            placeCards.add(value['name']);
          }
        });
      }
    }
  }

  Future<void> addDataToFolder(
    String userId,
    String travelPlanId,
    String travelPlanName,
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    try {
      DatabaseReference travelPlansReference = FirebaseDatabase.instance
          .ref()
          .child("favorites/$userId/travelPlans/$travelPlanId/data/");

      await travelPlansReference.push().set(data);

      final String text = data['name'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$text added successfully to $travelPlanName!'),
          duration: const Duration(milliseconds: 500),
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  saveFolderToDatabase(
    String userId,
    String travelPlanId,
    String travelPlanName,
  ) async {
    try {
      DatabaseReference favoritesReference = FirebaseDatabase.instance
          .ref()
          .child("favorites/$userId/travelPlans/$travelPlanId");

      await favoritesReference.set({
        "travelPlanId": travelPlanId,
        "travelPlanName": travelPlanName,
        "smartSuggestions": "unset",
      });
    } catch (error) {}
  }

  travelDatetoDatabase({
    required String travelPlanId,
    required List<String> selectedPlaces,
    required String dateScheduleId,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return;
      }
      String userId = currentUser.uid;

      if (travelPlanId != null && dateScheduleId != null) {
        DatabaseReference favoritesReference = FirebaseDatabase.instance
            .ref()
            .child("schedule/$userId/$travelPlanId/$dateScheduleId");
        // Convert selectedPlaces to a JSON array
        List<dynamic> selectedPlacesJson = List<dynamic>.from(selectedPlaces);

        // Check if the data with dateScheduleId already exists
        DatabaseEvent dataSnapshot = (await favoritesReference.once());
        dynamic snapshot = dataSnapshot.snapshot.value;
        if (snapshot != null) {
          // Data with dateScheduleId already exists, update the selectedPlaces
          await favoritesReference.update({
            'selectedPlaces': selectedPlacesJson,
            // You can add other data as needed
          });
        } else {
          // Data with dateScheduleId doesn't exist, create a new entry
          await favoritesReference.set({
            'selectedPlaces': selectedPlacesJson,
            // You can add other data as needed
          });
        }
      }
    } catch (error) {
      // Handle errors
      if (kDebugMode) {
        print('Error: $error');
      }
    }
  }

  budgetPlaces({
    required String travelPlanId,
    required List<String> selectedPlaces,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return;
      }
      String userId = currentUser.uid;

      DatabaseReference favoritesReference =
          FirebaseDatabase.instance.ref().child("budget/$userId/$travelPlanId");

      // Convert selectedPlaces to a JSON array
      List<dynamic> selectedPlacesJson = List<dynamic>.from(selectedPlaces);

      // Check if the data already exists
      DatabaseEvent dataSnapshot = (await favoritesReference.once());
      dynamic snapshot = dataSnapshot.snapshot.value;

      if (snapshot != null) {
        // Data already exists, update the selectedPlaces and assign budgets
        await favoritesReference.update({
          'selectedPlaces': selectedPlacesJson,
          'budget': assignBudgets(selectedPlaces),
          // You can add other data as needed
        });
      } else {
        // Data doesn't exist, create a new entry with selectedPlaces and assigned budgets
        await favoritesReference.set({
          'selectedPlaces': selectedPlacesJson,
          'budget': assignBudgets(selectedPlaces),
          // You can add other data as needed
        });
      }
    } catch (error) {
      // Handle errors
      if (kDebugMode) {
        print('Error: $error');
      }
    }
  }

  packingSetter({
    required String travelPlanId,
    required String categoryName,
    required List<String> selectedItems,
    required String categoryId,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return;
      }
      String userId = currentUser.uid;

      DatabaseReference favoritesReference = FirebaseDatabase.instance
          .ref()
          .child("packing/$userId/$travelPlanId/$categoryId");

      // Convert selectedItems to a JSON array
      List<dynamic> selectedItemsJson = List<dynamic>.from(selectedItems);

      // Update or set the data in Firebase
      await favoritesReference.set({
        'categoryName': categoryName,
        'selectedItems': selectedItemsJson,
        // You can add other data as needed
      });
    } catch (error) {
      // Handle errors
      if (kDebugMode) {
        print('Error: $error');
      }
    }
  }

  assignBudgets(List<String> places) {
    // Define budget categories
    List<String?> budgets = ['low', 'medium', 'high', null];

    // Shuffle the budget categories
    budgets.shuffle();

    // Create a map to store the assigned budgets for each place
    Map<String, String?> assignedBudgets = {};

    // Assign budgets randomly to each place
    for (String place in places) {
      assignedBudgets[place] = budgets.removeLast();
    }

    // Return the list of assigned budgets
    return assignedBudgets.values.toList();
  }
}
