import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lakbay/location/locationProvider.dart';
import 'package:lakbay/pages/emergency-widgets/nearestEmeregencyPage.dart';
import 'package:lakbay/state-notifiers/nearbyPoliceNotifier.dart';
import 'package:lakbay/global-styling/colors.dart';

class EmergencyContainer extends ConsumerWidget {
  final String title;
  final IconData icon;
  final String emergencyType;

  const EmergencyContainer({
    super.key,
    required this.title,
    required this.icon,
    required this.emergencyType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        final locationData = ref.read(locationProvider);
        if (locationData != null) {
          await ref
              .read(policeStationProvider.notifier)
              .fetchNearbyPoliceStations(
                  locationData.latitude, locationData.longitude, emergencyType);

          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmergencyPage(
                emergencyType: emergencyType,
              ),
            ),
          );
        } else {
          // Handle the case when location data is null
          // You may show an error message or take appropriate action
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.accentDarkGreenColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
