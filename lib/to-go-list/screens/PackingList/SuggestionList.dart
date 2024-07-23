// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';

class SuggestionList extends StatefulWidget {
  final String travelPlanId;

  const SuggestionList({super.key, required this.travelPlanId});

  @override
  // ignore: no_logic_in_create_state
  State<SuggestionList> createState() =>
      _SuggestionListState(travelPlanId: travelPlanId);
}

class _SuggestionListState extends State<SuggestionList> {
  final String travelPlanId;

  _SuggestionListState({required this.travelPlanId});

  late String userId;

  @override
  void initState() {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        userId = currentUser.uid;
      }
      // ignore: empty_catches
    } catch (error) {}

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      // Assuming you have a function that returns the list of locations
      future: getSuggestionList(travelPlanId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No data available');
        } else {
          // Map to store suggestions for each preference type

          // Map to accumulate unique suggestions for each preference type across all locations
          Map<String, Set<String>> accumulatedSuggestions = {};

          Map<String, Set<String>> accumulatedEssentials = {};

          String category = 'Essentials';

          Set<String> suggestionsEssentials = {};
          Set<String> suggestionsItem = {};
          // Process each location to accumulate unique suggestions
          for (var locationData in snapshot.data!) {
            String preferences = locationData['preferences'] ?? '';
            List<String> suggestions = [];

            // Add specific items for "Parks" category
            if (preferences == 'Parks') {
              suggestionsEssentials.addAll(['Sunscreen', 'Water']);
              suggestionsItem.addAll(['Snacks', 'Hat', 'Picnic Blanket']);
            } else if (preferences == 'Zoo') {
              suggestionsEssentials.addAll(['Extra Clothes', 'Water']);
              suggestionsItem.addAll(['Camera']);
            } else if (preferences == 'Coffee Shops') {
              suggestionsEssentials.addAll(['Money']);
              suggestionsItem.addAll(['Laptop', 'Chargers', 'Notebook', 'Pen']);
            } else if (preferences == 'Beaches') {
              suggestionsEssentials.addAll(['Sunscreen', 'Sunglasses', 'Hat']);
              suggestionsItem.addAll(
                  ['Swimwear', 'Personal Hygiene Items', 'Reservations']);
            } else if (preferences == 'Resorts') {
              suggestionsEssentials.addAll(['Reservations', 'Sunscreen']);
              suggestionsItem.addAll([
                'Swimwear',
                'Extra Clothes',
                'Personal Hygiene Items',
              ]);
            } else if (preferences == 'Mountains / Hiking') {
              suggestionsEssentials.addAll([
                'First-Aid Kit',
                'Hiking Gears',
                'Sunscreen',
                'Hat',
                'Water'
              ]);
              suggestionsItem.addAll([
                'Compass',
                'Guidebook',
                'Personal Hygiene Items',
                'Tents',
              ]);
            } else if (preferences == 'Malls') {
              suggestionsEssentials.addAll(['Water', 'Money']);
              suggestionsItem.addAll(['Shopping List', 'Reservations']);
            } else if (preferences == 'Hotels') {
              suggestionsEssentials.addAll(['Money']);
              suggestionsItem
                  .addAll(['Reservations', 'Personal Hygiene Items']);
            } else if (preferences == 'Historical Sites') {
              suggestionsEssentials.addAll(['Extra Clothes', 'Sunscreen']);
              suggestionsItem.addAll(['Camera']);
            } else if (preferences == 'Social Hubs (Bars)') {
              suggestionsEssentials.addAll(['Money', 'ID']);
              suggestionsItem.addAll(['Medications']);
            } else if (preferences == 'Restaurant') {
              suggestionsEssentials.addAll(['Money']);
              suggestionsItem.addAll(['Reservations']);
            }

            // Add the category and its suggestions to the map
            accumulatedEssentials[category] = suggestionsEssentials;
            accumulatedSuggestions[category] = suggestionsItem;

            // Add unique suggestions to the accumulated list
            for (var suggestion in suggestions) {
              if (accumulatedSuggestions.containsKey(preferences)) {
                accumulatedSuggestions[preferences]!.add(suggestion);
              } else {
                accumulatedSuggestions[preferences] = {suggestion};
              }
            }
          }

          // Build UI using the accumulated suggestions
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 25.0,
                  horizontal: 25.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentSmokeGreenColor,
                  border: Border.all(
                    width: 1.5,
                    color: AppColors.accentLightGreenColor,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ColumnsTitleText(
                        'Essentials', AppColors.accentBlackColor),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: accumulatedEssentials.entries.map((entry) {
                        Set<String> suggestions = entry.value;

                        // Create a Text widget for each suggestion
                        List<Widget> suggestionWidgets = suggestions
                            .map((suggestion) => Text(
                                  suggestion,
                                  style: const TextStyle(
                                    color: AppColors.accentBlackColor,
                                    height: 2,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ))
                            .toList();

                        // Create a Column to display the suggestions
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: suggestionWidgets,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15.0),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.accentSmokeGreenColor,
                  border: Border.all(
                    width: 1.5,
                    color: AppColors.accentLightGreenColor,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 25.0,
                  horizontal: 25.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ColumnsTitleText(
                        'Suggested Item', AppColors.accentBlackColor),
                    const SizedBox(
                      height: 10.0,
                    ),
                    // Create a Set to store unique suggestions
                    ...Set<String>.from(accumulatedSuggestions.values
                            .expand((suggestions) => suggestions))
                        // Iterate over the unique suggestions and generate Column widgets
                        .map((suggestion) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BoldNormalText(
                                  suggestion,
                                  AppColors.accentBlackColor,
                                ),
                                const SizedBox(
                                  height: 8.0,
                                ), // Adjust the height as needed
                              ],
                            ))
                        .toList(),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  // Function to get the list of locations
  Future<List<Map<String, dynamic>>> getSuggestionList(
      String travelPlanId) async {
    List<Map<String, dynamic>> suggestionsLocations = [];
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
          String price = locationData['price'] ?? 'No Price Available';
          String preferences = locationData['preferences'];
          suggestionsLocations.add({
            'name': name,
            'price': price,
            'preferences': preferences,
          });
        });
      }

      return suggestionsLocations;
    }

    return [];
  }
}
