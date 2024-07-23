import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/authentication/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

//Pages
import 'package:lakbay/pages/home.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:lakbay/pages/onboarding.dart';
import 'package:lakbay/global-styling/colors.dart';

// ignore: use_key_in_widget_constructors
class SplashScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Replace this method with your logic to check if the user is new
  Future<bool> checkIfUserIsNew() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool isNewUser = prefs.getBool('isNewUser') ?? true;

    // If the user is new, set the flag to false for future checks
    if (isNewUser) {
      await prefs.setBool('isNewUser', false);
    }

    return isNewUser;
  }

  Future<bool> checkIfUserIsLoggedIn() async {

    User? currentUser = FirebaseAuth.instance.currentUser;

    bool isLoggedIn = false;

    if (currentUser != null) {
      isLoggedIn = true;
    }
    
    return isLoggedIn;
  }  

  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 4),
      () {
        checkIfUserIsLoggedIn().then((isLoggedIn) {
          if (isLoggedIn) {
            // User is logged in, navigate to HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else {
            // User is not logged in, check if it's a new user
            checkIfUserIsNew().then((isNewUser) {
              Navigator.pushReplacement(
                context,
                isNewUser
                    ? MaterialPageRoute(builder: (context) => buildOnboardingPage())
                    : MaterialPageRoute(builder: (context) => const LoginPage()), // Replace YourLoginPage with your actual login page widget
              );
            });
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/onboard/splash.png', // Replace with your background image asset
            fit: BoxFit.cover,
          ),

          // Centered Logo and App Name
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Your Logo Image
              Image(
                image: AssetImage(
                  'assets/images/onboard/appLogo.png',
                ),
                width: 175,
                height: 175,
              ),

              // Your App Name
              OnboardHeader('lak·báy', AppColors.accentWhiteColor),
            ],
          ),
        ],
      ),
    );
  }
}
