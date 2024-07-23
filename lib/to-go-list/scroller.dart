// ignore_for_file: library_private_types_in_public_api, unused_import

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/To-Go-List/TravelPlans/TimeToPlan.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/to-go-list/ScrollerTravelling.dart';
import 'package:lakbay/to-go-list/screens/MapScreen.dart';
import 'package:lakbay/to-go-list/screens/budgetlist/BudgetListScreen.dart';
import 'package:lakbay/to-go-list/screens/ScrollerEmergency.dart';

import '../api/getters.dart';
import 'Screens/PackingList/PackingListScreen.dart';

class Scroller extends StatefulWidget {
  final String travelPlanId;

  const Scroller({super.key, required this.travelPlanId});

  @override
  _ScrollerState createState() => _ScrollerState();
}

class _ScrollerState extends State<Scroller> {
  late int selectedIndex;
  late String travelPlanId;
  final List<String> buttonLabels = [
    'Travel Planner',
    'Directions',
    'Budget Planner',
    'Packing List',
    'Emergency',
  ];

  @override
  void initState() {
    final Getters getters = Getters();

    super.initState();
    travelPlanId = widget.travelPlanId;

    selectedIndex = 0; // Set the default selected index
    getters.getScheduleData(travelPlanId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.accentWhiteColor,
        title: const Text('To Go List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical:8.0, horizontal: 8.0),
                child: Row(
                  children: [
                    for (var i = 0; i < buttonLabels.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal:6.0,vertical: 8.0),
                        child: ActionButton(
                          label: buttonLabels[i],
                          isSelected: i == selectedIndex,
                          onPressed: () {
                            setState(() {
                              selectedIndex = i;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: BodyContents(
                  selectedIndex: selectedIndex,
                  travelPlanId: travelPlanId,
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Increase padding
              child: TravelButton(travelPlanId: travelPlanId),
            ),
          ),
        ],
      ),
    );
  }
}

class TravelButton extends StatelessWidget {
  const TravelButton({
    super.key,
    required this.travelPlanId,
  });

  final String travelPlanId;

  @override
  Widget build(BuildContext context) {
    const String title = 'Travel Now';
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ScrollerTravelling(travelPlanId: travelPlanId),
          ),
        );
      },
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all(AppColors.accentDarkGreenColor),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        ), // Increase button padding
      ),
      child: const Text(
        title,
        style: TextStyle(
            color: Colors.white, fontSize: 18.0), // Increase font size
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        alignment: Alignment.center,
        side: MaterialStateProperty.all(const BorderSide(
          color: AppColors.accentDarkGreenColor,
          width: 2.0, 
        )),
        padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical:5.0, horizontal:15.0)),
        backgroundColor: isSelected
            ? MaterialStateProperty.all(AppColors.accentDarkGreenColor)
            : MaterialStateProperty.all(AppColors.accentWhiteColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.accentDarkGreenColor,
        ),
      ),
    );
  }
}

class BodyContents extends StatelessWidget {
  final int selectedIndex;
  final String travelPlanId;

  const BodyContents({
    super.key,
    required this.selectedIndex,
    required this.travelPlanId,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IndexedStack(
        index: selectedIndex,
        children: [
          // Travel Planner
          TimeToPlan(
            travelPlanId: travelPlanId,
          ),
          // Directions
          const MapScreen(),
          
          // Packing List
          BudgetListScreen(
            travelPlanId: travelPlanId,
          ),

          PackingListScreen(
            travelPlanId: travelPlanId,
          ),
          // Emergency
          const EmergencyScreen(),
          
        ],
      ),
    );
  }
}

class WebScroller extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}