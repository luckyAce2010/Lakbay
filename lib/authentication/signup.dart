// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lakbay/authentication/confirm.dart';
import 'package:lakbay/authentication/login.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lakbay/pages/signup-screens/getUserPreferences.dart';

//To be removed
import 'package:lakbay/pages/signup-screens/getContactList.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              height: MediaQuery.of(context).size.height + 20,
              // width: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Column(
                      children: <Widget>[
                        OnboardHeader(
                            'sign•up', AppColors.accentDarkGreenColor),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: CardTitleText(
                              'Username', AppColors.accentBlackColor),
                        ),
                        buildTextField(
                            "Enter your username", _usernameController),
                        const SizedBox(height: 10),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: CardTitleText(
                              'E-mail', AppColors.accentBlackColor),
                        ),
                        buildTextField("Enter your e-mail", _emailController),
                        const SizedBox(height: 10),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: CardTitleText(
                              'Password', AppColors.accentBlackColor),
                        ),
                        buildTextField('Password', _passwordController,
                            isPassword: true),
                        const SizedBox(height: 10),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: CardTitleText(
                              'Confirm Password', AppColors.accentBlackColor),
                        ),
                        buildTextField(
                            "Confirm Password", _confirmPasswordController,
                            isPassword: true),
                        const SizedBox(height: 10),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: CardTitleText(
                              'Phone Number', AppColors.accentBlackColor),
                        ),
                        buildTextField("Phone Number", _confirmPhoneController,
                            isPassword: false),
                        const SizedBox(height: 10),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                        padding: const EdgeInsets.only(top: 3, left: 3),
                        child: ElevatedButton(
                          onPressed: () {
                            String username = _usernameController.text;
                            String email = _emailController.text;
                            String password = _passwordController.text;
                            String confirmPassword =
                                _confirmPasswordController.text;
                            String phoneNumber = _confirmPhoneController.text;

                            // Perform sign-up logic
                            if (username.isNotEmpty &&
                                password == confirmPassword &&
                                password.isNotEmpty &&
                                phoneNumber.isNotEmpty) {
                              signUpWithEmailAndPassword(
                                  email, password, phoneNumber, context);
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                      "Warning",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: const Text(
                                      "Please fill up the form correctly",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          "OK",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 18,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: AppColors.accentDarkGreenColor,
                          ),
                          child: const Text(
                            "Sign-up",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                              color: AppColors.accentWhiteColor,
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    const Center(child: Text("Or")),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: AppColors.accentDarkGreenColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(
                                0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          signInWithGoogle(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Sign In with ",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black26,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              height: 60.0,
                              width: 60.0,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/authentication/google.png'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const CardTitleText("Already have an account?",
                            AppColors.accentDarkGreenColor),
                        Builder(
                          builder: (context) => TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: AppColors.accentDarkGreenColor,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

TextField buildTextField(String hintText, TextEditingController controller,
    {bool isPassword = false}) {
  return TextField(
    style: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14.0,
      color: AppColors.accentDarkGreenColor,
    ),
    controller: controller,
    obscureText: isPassword, // Set to true for password field
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: 'Poppins',
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.accentDarkGreenColor,
          width: 2.0,
          style: BorderStyle.solid,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: AppColors.accentDarkGreenColor,
          width: 2.0,
          style: BorderStyle.solid,
        ),
      ),
    ),
  );
}

final TextEditingController _usernameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final TextEditingController _confirmPasswordController =
    TextEditingController();

final TextEditingController _confirmPhoneController = TextEditingController();

signUpWithEmailAndPassword(
  String email,
  String password,
  String phoneNumber,
  context,
) async {
  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    if (FirebaseAuth.instance.currentUser != null) {
      // Navigate to the home page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }

    // Check if the user is signed up successfully
    if (FirebaseAuth.instance.currentUser != null) {
      // Navigate to the home page or perform any other post-sign-up actions
      print('User signed up successfully!');
      print(phoneNumber);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PreferencesPage(),
          // builder: (context) => Confirm(
          //   phoneNumber: phoneNumber,
          // ),
        ),
      );
    }
  } on FirebaseAuthException catch (e) {
    if (kDebugMode) {
      print(e.message);
    }
  }
}

Future<UserCredential?> signInWithGoogle(BuildContext context) async {
  String clientId = dotenv.env['CLIENT_ID']!;

  // Trigger the authentication flow
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: clientId,
  );

  try {
    // Start the Google Sign In process
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // Handle if the user cancels the sign-in process
    if (googleUser == null) {
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with the Google credential
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Navigate to the home page or perform any other post-sign-in actions
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PreferencesPage(),
      ),
    );

    return userCredential;
  } catch (error) {
    print('Error signing in with Google: $error');
    return null;
  }
}
