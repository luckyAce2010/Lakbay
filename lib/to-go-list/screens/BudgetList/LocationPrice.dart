// ignore_for_file: library_private_types_in_public_api, no_logic_in_create_state

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/api/getters.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';

class LocationPrice extends StatefulWidget {
  final String travelPlanId;

  const LocationPrice({
    super.key,
    required this.travelPlanId,
  });

  @override
  _LocationPriceState createState() =>
      _LocationPriceState(travelPlanId: travelPlanId);
}

class _LocationPriceState extends State<LocationPrice> {
  final String travelPlanId;

  _LocationPriceState({required this.travelPlanId});
  late List<Map<String, String>> locations;

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

  Future<void> fetchLocations() async {
    // Fetch locations and update the state
    List<Map<String, String>> newLocations =
        await getLocationList(travelPlanId);
    setState(() {
      locations = newLocations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, String>>>(
      future: getLocationList(travelPlanId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No data available');
        } else {
          List<Map<String, String>> locations = snapshot.data!;
    
          return Container(
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
                const ColumnsTitleText('From This Planner', AppColors.accentBlackColor),
                const SizedBox(height: 10.0,),
                ListView.builder(
                  shrinkWrap: true, // Add this line
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    String name = locations[index]['name'] ?? 'No Name';
                    String price = locations[index]['price_level'] ?? 'No Price Available';
                    
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: BoldNormalText(name, AppColors.accentBlackColor),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  BoldNormalText(price, AppColors.accentBlackColor),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
