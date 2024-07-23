import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lakbay/global-styling/colors.dart';

class TravellingButton extends StatefulWidget {
  const TravellingButton({
    Key? key,
    required this.travelPlanId,
    required this.data,
  }) : super(key: key);

  final String travelPlanId;
  final Map<String, dynamic> data;

  @override
  _TravellingButtonState createState() => _TravellingButtonState();
}

class _TravellingButtonState extends State<TravellingButton> {
  bool isPressed = false;

  void _onPressed(BuildContext context) {
    String title = 'Saved to History';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content:
            const Text('Location and Dates are now saved in travel history.'),
        actions: [
          TextButton(
            onPressed: () {
              travelPlanDone(widget.travelPlanId, widget.data);
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _ask(BuildContext context) {
    setState(() {
      isPressed = !isPressed;
    });

    if (isPressed) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Stop Confirmation'),
            content: const Text('Do you want to stop?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  // Add logic to execute when the user confirms stopping
                  print('Stopping...');
                  Navigator.pop(context); // Close the dialog

                  _onPressed(context);
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return  TextButton(
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(AppColors.accentDarkGreenColor),
        foregroundColor: MaterialStatePropertyAll(AppColors.accentWhiteColor),
        padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0)),
      ),
      onPressed: () => _ask(context),
      child: Text(
        isPressed ? 'Travel Now' : 'Done Travelling For This Day',
      ),
    );
  }
}

Future<void> travelPlanDone(
    String travelPlanId, Map<String, dynamic> data) async {
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? currentUser = auth.currentUser;
  if (currentUser == null) {
    return;
  }
  String userId = currentUser.uid;

  DatabaseReference ref = FirebaseDatabase.instance
      .ref()
      .child("history/$userId/travelPlans/$travelPlanId/0");

  Map<String, dynamic> historyData = {
    "travelled": true,
    "travelledAt": DateFormat('yyyy-MM-dd').format(DateTime.now()),
    "travelId": travelPlanId,
    "data": data,
  };

  await ref.set(historyData);
}
