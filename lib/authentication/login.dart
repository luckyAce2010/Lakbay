import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/authentication/signup.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:lakbay/pages/home.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 120,
          horizontal: 30,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            _header(context),
            _inputField(context),
            const Spacer(),
            _signup(context),
          ],
        ),
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        OnboardHeader('sign•in', AppColors.accentDarkGreenColor),
      ],
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: CardTitleText('E-mail', AppColors.accentBlackColor),
        ),
        buildTextField("Enter your e-mail", _emailController),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: CardTitleText('Password', AppColors.accentBlackColor),
        ),
        buildTextField('Password', _passwordController, isPassword: true),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            // Get the values from the controllers here
            String email = _emailController.text;
            String password = _passwordController.text;

            // Call the signInWithEmailAndPassword function
            signInWithEmailAndPassword(email, password, context);
          },
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: AppColors.accentDarkGreenColor,
          ),
          child: const Text(
            'Sign-in',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.0,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
              color: AppColors.accentWhiteColor,
            ),
          ),
        ),
      ],
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CardTitleText(
            'Dont have an account?', AppColors.accentDarkGreenColor),
        Builder(
          builder: (context) => TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()),
              );
            },
            child: const Text(
              "Sign-up",
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
    );
  }
}

final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();

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

signInWithEmailAndPassword(
  String email,
  String password,
  context,
) async {
  try {
    // ignore: unused_local_variable
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    if (FirebaseAuth.instance.currentUser != null) {
      // Navigate to the home page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      if (kDebugMode) {
        print('No user found for that email.');
      }
    } else if (e.code == 'wrong-password') {
      if (kDebugMode) {
        print('Wrong password provided for that user.');
      }
    }
  }
}