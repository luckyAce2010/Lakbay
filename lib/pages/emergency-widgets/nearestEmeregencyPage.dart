// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lakbay/state-notifiers/nearbyPoliceNotifier.dart';

class EmergencyPage extends ConsumerWidget {
  final String emergencyType;

  const EmergencyPage({super.key, required this.emergencyType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Page'),
      ),
      body: const MapWidget(),
    );
  }
}

class MapWidget extends ConsumerWidget {
  const MapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PoliceStation> policeStations = ref.read(policeStationProvider);

    return Scaffold(
      body: policeStations.isNotEmpty
          ? _buildMapWithMarkers(policeStations, context)
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMapWithMarkers(
      List<PoliceStation> policeStations, BuildContext context) {
    // Initial camera position (you can adjust this according to your needs)
    CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(
        policeStations.first.latitude,
        policeStations.first.longitude,
      ),
      zoom: 15.0,
    );

    return GoogleMap(
      initialCameraPosition: initialCameraPosition,
      markers: _buildMarkers(policeStations, context),
    );
  }

  Set<Marker> _buildMarkers(
      List<PoliceStation> policeStations, BuildContext context) {
    return policeStations.map((policeStation) {
      return Marker(
        markerId: MarkerId(policeStation.name.toString()),
        position: LatLng(policeStation.latitude, policeStation.longitude),
        infoWindow: InfoWindow(
          title: policeStation.name,
          snippet: 'Vicinity: ${policeStation.vicinity}',
        ),
        onTap: () {
          _showDirectionsDialog(context, policeStation);
        },
      );
    }).toSet();
  }

  void _showDirectionsDialog(
      BuildContext context, PoliceStation policeStation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Start Directions?'),
          content:
              Text('Do you want to start directions to ${policeStation.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _launchDirections(
                    policeStation.latitude, policeStation.longitude);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _launchDirections(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
