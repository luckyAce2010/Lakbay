// ignore_for_file: library_private_types_in_public_api, unused_import
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lakbay/to-go-list/Scroller.dart';
import 'package:permission_handler/permission_handler.dart';


//For APIS
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lakbay/api/getCurrentUserID.dart';

//Pages
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/authentication/splash_screen.dart';

//State Management
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lakbay/location/locationProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await CurrentUser.init();
  await dotenv.load(fileName: ".env");

  await requestLocationPermission(); // Request location permission when the app is launched


  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      ref.read(locationProvider.notifier).updateLocation();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating location: $e');
      }
    }

    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        primaryColor: AppColors.accentDarkGreenColor,
        focusColor: AppColors.accentDarkGreenColor,
        indicatorColor: AppColors.accentDarkGreenColor,
      ),
      home: SplashScreen(),
    );
  }
}

Future<void> requestLocationPermission() async {
  var status = await Permission.location.status;
  if (status.isDenied || status.isPermanentlyDenied) {
    // Request location permission
    await Permission.location.request();
  }
}