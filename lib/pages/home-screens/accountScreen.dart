// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:lakbay/pages/home-screens/recommendationScreen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 55.0),
            child: Column(
              // Wrap your widgets in a Column
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Good Day Traveller!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentDarkGreenColor,
                  ),
                ),
                const SizedBox(height: 20),
                const CardTitleText('Wishing you a joyful and safe travel',
                    AppColors.accentBlackColor),
                const SizedBox(height: 30),
                BoldNormalText(
                    '${currentUser?.email}', AppColors.accentBlackColor),
                const SizedBox(height: 10),
                BoldNormalText(
                    'Joined Lak-bay at: ${DateFormat('yyyy-MM-dd').format(currentUser!.metadata.creationTime!)}',
                    AppColors.accentBlackColor),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        AppColors.accentDarkGreenColor), // Green background
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Colors.white), // White text
                  ),
                  onPressed: () async {
                    await signOut(context);
                  },
                  child: const Text('Sign Out'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
