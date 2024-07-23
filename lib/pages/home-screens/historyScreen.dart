// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Marker> markers = [];
  late BitmapDescriptor markerIcon;


  @override
  void initState() {
    super.initState();
    loadMarkerIcon();
    fetchTravelPlanDetails();
  }

  Future<void> fetchTravelPlanDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child("history/$userId/travelPlans");

      DatabaseEvent dataSnapshot = await ref.once();
      dynamic data = dataSnapshot.snapshot.value;

      if (data != null && data is Map) {
        Map<dynamic, dynamic> travelPlans = data;

        travelPlans.forEach((key, value) async {
          DatabaseReference planRef = FirebaseDatabase.instance
              .ref()
              .child("history/$userId/travelPlans/$key/0/data/places");

          DatabaseEvent planSnapshot = await planRef.once();
          dynamic planData = planSnapshot.snapshot.value; 

          if (planData != null) {
            List<Map<dynamic, dynamic>> placeDetails = List<Map<dynamic, dynamic>>.from(planData);

            for (Map<dynamic, dynamic> placeDetail in placeDetails) {

              // Access individual properties using placeDetail['propertyName']
              double latitude = double.parse(placeDetail['latitude'] ?? 0.0);
              double longitude = double.parse(placeDetail['longitude'] ?? 0.0); 
              String name = placeDetail['name'] ?? "Unnamed Marker";
              String date = placeDetail['travelledAt'] ?? "Date Unavailable";

              addMarker(name, latitude, longitude, date);
            }
          }
        });
      }
    }
  }

  Future<void> loadMarkerIcon() async {
    markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 5, size: Size(250, 250)),
      'assets/images/maps/icon-pin.png',
    );
  }

  Future<void> addMarker(String name, double latitude, double longitude, String date) async {
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId(name),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title:'$name, Visited at: $date'),
          icon: markerIcon,
        ),
      );
    });
  }

  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: GoogleMap(
        mapType: MapType.terrain,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(14.592646296612996, 120.99098403069165),
          zoom: 6,
        ),
        markers: Set<Marker>.from(markers),
      ),
    );
  }
}
