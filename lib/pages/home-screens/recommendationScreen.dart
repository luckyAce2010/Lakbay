import 'package:flutter/material.dart';
import 'package:lakbay/PlaceLister/ClickableCardsScreen.dart';

//Firebase and Authentications
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lakbay/authentication/login.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

//In order to get data from the riverpod state
//Change the stateless widget into ConsumerWidget
class RecommendationScreen extends ConsumerWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ClickableCardsScreen();
  }
}

Future<void> signOut(BuildContext context) async {
  // Store the context in a local variable
  final navContext = context;

  await FirebaseAuth.instance.signOut();

  // Check if the widget is still mounted before navigating
  if (navContext.mounted) {
    // Navigate to the login page after sign-out
    Navigator.of(navContext).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }
}
