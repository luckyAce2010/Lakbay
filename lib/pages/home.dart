import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lakbay/To-Go-List/TravelPlans/TravelPlanList.dart';
import 'package:lakbay/global-styling/colors.dart';

//Screens for bottom navbar
import 'package:lakbay/pages/home-screens/accountScreen.dart';
import 'package:lakbay/pages/home-screens/emergencyScreen.dart';
import 'package:lakbay/pages/home-screens/historyScreen.dart';
import 'package:lakbay/pages/home-screens/recommendationScreen.dart';

//For state management
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lakbay/state-notifiers/navbarNotifier.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navbarStateNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.accentWhiteColor,
      body: _widgetOptions.elementAt(selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.accentWhiteColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: AppColors.accentWhiteColor,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: AppColors.accentDarkGreenColor,
            color: AppColors.accentDarkGreenColor,
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.calendar_month,
                text: 'Planner',
              ),
              GButton(
                icon: Icons.history,
                text: 'History',
              ),
              GButton(
                icon: Icons.emergency,
                text: 'Emergency',
              ),
              GButton(
                icon: Icons.people,
                text: 'Account',
              )
            ],
            selectedIndex: selectedIndex,
            onTabChange: (index) {
              ref.read(navbarStateNotifierProvider.notifier).setIndex(index);
            },
          ),
        ),
      ),
    );
  }

  List<Widget> get _widgetOptions => <Widget>[
        const RecommendationScreen(),
        const TravelPlanList(data: {}),
        const HistoryScreen(),
        const EmergencyScreen(),
        const AccountSettingsScreen(),
      ];
}
