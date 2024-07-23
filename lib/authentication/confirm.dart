// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/pages/signup-screens/getUserPreferences.dart';

class Confirm extends StatefulWidget {
  final String phoneNumber;

  const Confirm({super.key, required this.phoneNumber});

  @override
  _ConfirmState createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {
  TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              onChanged: (value) {
                if (value.length == 6) {
                  _validateCode();
                }
              },
              decoration: const InputDecoration(
                counterText: "",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _validateCode();
              },
              child: const Text('Confirm'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                print(widget.phoneNumber);
                AuthService.sentOtp(
                  phone: widget.phoneNumber,
                  errorStep: _showSnackBar,
                  nextStep: () {
                    _showSnackBar("OTP sent successfully");
                  },
                );
              },
              child: const Text('Send Verification Code'),
            ),
          ],
        ),
      ),
    );
  }

  void _validateCode() {
    String enteredCode = _otpController.text;
    AuthService.loginWithOtp(otp: enteredCode).then((result) {
      if (result == "Success") {
        _showSnackBar("OTP verification successful");

        // Add a delay of 1 second before navigating
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PreferencesPage(),
            ),
          );
        });
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static String verifyId = "";

  static Future sentOtp({
    required String phone,
    required Function errorStep,
    required Function nextStep,
  }) async {
    await _firebaseAuth
        .verifyPhoneNumber(
      timeout: const Duration(seconds: 30),
      phoneNumber: "+63$phone",
      verificationCompleted: (phoneAuthCredential) async {
        return;
      },
      verificationFailed: (error) async {
        errorStep("Error: $error");
      },
      codeSent: (verificationId, forceResendingToken) async {
        verifyId = verificationId;
        nextStep();
      },
      codeAutoRetrievalTimeout: (verificationId) async {
        return;
      },
    )
        .onError((error, stackTrace) {
      errorStep("Error: $error");
    });
  }

  static Future<String> loginWithOtp({required String otp}) async {
    final cred =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);

    try {
      final user = await _firebaseAuth.signInWithCredential(cred);
      if (user.user != null) {
        return "Success";
      } else {
        return "Error in Otp login";
      }
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  static Future logout() async {
    await _firebaseAuth.signOut();
  }

  static Future<bool> isLoggedIn() async {
    var user = _firebaseAuth.currentUser;
    return user != null;
  }
}
