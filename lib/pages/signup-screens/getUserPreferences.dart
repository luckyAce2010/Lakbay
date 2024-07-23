import 'package:flutter/material.dart';
import 'package:lakbay/pages/signup-screens/getContactList.dart';
import 'package:lakbay/state-notifiers/getpreferencesNotifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class _DatabaseService {
  static final CollectionReference _userDetailsRef =
      FirebaseFirestore.instance.collection('user-details');

  static Future<void> saveUserPreferences(List<String> preferences) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        // Reference to the user's document in the "user-details" collection
        DocumentReference userDocumentRef = _userDetailsRef.doc(userId);

        // Update the 'preferences' field in the document
        await userDocumentRef.set({'preferences': preferences});
      }
    } catch (error) {
      print("Error saving user preferences: $error");
    }
  }
}

class PreferencesPage extends ConsumerWidget {
  final List<String> preferences = [
    'Parks',
    'Zoo',
    'Coffee Shops',
    'Beaches',
    'Resorts',
    'Mountains / Hiking',
    'Malls',
    'Hotels',
    'Historical Sites',
    'Social Hubs (Bars)',
    'Restaurants',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPreferences = ref.watch(selectedPreferencesProvider);

    return Scaffold(
      backgroundColor: AppColors.accentWhiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 15.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const OnboardHeader('preferences', AppColors.accentDarkGreenColor),
                const SizedBox(height: 15),
                const NormalText('Pick atleast 5 Preferences', AppColors.accentBlackColor),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: preferences.map((preference) {
                    return _buildPreferenceButton(preference, selectedPreferences, ref);
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextButton(
                  
                  style:TextButton.styleFrom(backgroundColor: AppColors.accentWhiteColor, ),
                  onPressed: () {
                    ref.read(selectedPreferencesProvider.notifier).selectAllPreferences();
                  },
                  child: const Text('Select All', style: TextStyle(fontFamily: 'Poppins', color: AppColors.accentBlackColor),),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    ref.read(selectedPreferencesProvider.notifier).resetPreferences();
                  },
                  child: const Text('Reset', style: TextStyle(fontFamily: 'Poppins', color: AppColors.accentBlackColor),),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async{
                    if (selectedPreferences.length < 5) {
                      _showAlertDialog(context);
                    } else {

                      //Put this into the database
                      print('Selected Preferences: $selectedPreferences');

                      await _DatabaseService.saveUserPreferences(selectedPreferences);

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => ContactListPage(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration( 
                      color: AppColors.accentDarkGreenColor,
                      borderRadius: BorderRadius.circular(10.0),
                     
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    width: double.infinity,
                    child: const Text('Continue', style: TextStyle(color: AppColors.accentWhiteColor, fontFamily: 'Poppins'), textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceButton(String preference, List<String> selectedPreferences, WidgetRef ref) {
    bool isSelected = selectedPreferences.contains(preference);

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          ref.read(selectedPreferencesProvider.notifier).removePreference(preference);
        } else {
          ref.read(selectedPreferencesProvider.notifier).addPreference(preference);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentDarkGreenColor : AppColors.accentWhiteColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accentDarkGreenColor, width: 2),
        ),
        child: Text(
          preference,
          style: TextStyle(color: isSelected ? AppColors.accentWhiteColor : AppColors.accentBlackColor,
          fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 14.0),
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Please choose at least 5 preferences before proceeding.', style: TextStyle(fontFamily: 'Poppins'),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK', style: TextStyle(fontFamily: 'Poppins'),),
            ),
          ],
        );
      },
    );
  }
}