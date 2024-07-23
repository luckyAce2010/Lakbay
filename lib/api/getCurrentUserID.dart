// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';

class CurrentUser {
  static String? userId;

  static Future<void> init() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
    } else {
      userId = null;
    }
  }
}
