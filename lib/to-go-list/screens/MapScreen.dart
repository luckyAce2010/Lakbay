import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

enum MyAppTravelMode { driving, walking, bicycling, transit }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  List<LatLng> polylineCoordinates = [];

  final TextEditingController _searchController = TextEditingController();
  LocationData? currentLocation;
  MyAppTravelMode selectedMode =
      MyAppTravelMode.driving; // Default mode is driving

  List<Widget> buildTravelModeWidgets() {
    return MyAppTravelMode.values.map((mode) {
      IconData iconData;
      double iconSize = 24.0;

      switch (mode) {
        case MyAppTravelMode.driving:
          iconData = Icons.directions_car;
          break;
        case MyAppTravelMode.walking:
          iconData = Icons.directions_walk;
          break;
        case MyAppTravelMode.bicycling:
          iconData = Icons.directions_bike;
          break;
        case MyAppTravelMode.transit:
          iconData = Icons.directions_transit;
          break;
      }

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedMode = mode;
          });
          getPolyPoints(
            LocationData.fromMap({'latitude': 0.0, 'longitude': 0.0}),
            mode,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: mode == selectedMode ? Colors.blueAccent : null,
          child: Icon(
            iconData,
            size: iconSize,
            color: mode == selectedMode ? Colors.white : Colors.black,
          ),
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    initMap();
  }

  Future<void> initMap() async {
    Location location = Location();
    currentLocation = await location.getLocation();
    getLocationAndPolyPoints();
  }

  Future<void> getLocationAndPolyPoints() async {
    if (currentLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('CurrentLocation'),
          position: LatLng(
            currentLocation!.latitude ?? 0.0,
            currentLocation!.longitude ?? 0.0,
          ),
        ),
      );
      // Move the camera to focus on the current location
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              currentLocation!.latitude ?? 0.0,
              currentLocation!.longitude ?? 0.0,
            ),
            zoom: 12.0,
          ),
        ),
      );

      // Fetch polyline points
      await getPolyPoints(currentLocation!, selectedMode);
    }
  }

  Future<void> getPolyPoints(
      LocationData currentLocation, MyAppTravelMode mode) async {
    String apiKey = "AIzaSyCGDDtECiqfZkN4_1EYuLDa_QhsQiFmvEs";
    String input = _searchController.text;

    if (input.isEmpty) {
      return; // Don't perform search if the input is empty
    }

    String apiUrl =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$input&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final location = data['results'][0]['geometry']['location'];
          double lat = location['lat'];
          double lng = location['lng'];

          // Clear previous markers and polylines
          polylineCoordinates.clear();

          // Add marker for the searched location
          _markers.add(
            Marker(
              markerId: const MarkerId('SearchedLocation'),
              position: LatLng(lat, lng),
            ),
          );

          // Add polyline towards the searched location with the specified mode
          await updatePolyline(currentLocation, lat, lng, mode);

          // Update the map camera to focus on the searched location
          _controller?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(lat, lng),
                zoom: 12.0,
              ),
            ),
          );
        } else {
          // Handle error status from the Places API
        }
      } else {
        // Handle HTTP error
        if (kDebugMode) {
          print("HTTP error: ${response.statusCode}");
        }
      }
    } catch (e) {
      // Handle any other errors
    }
  }

  Future<void> updatePolyline(LocationData currentLocation, double lat,
      double lng, MyAppTravelMode mode) async {
    String apiKey = "AIzaSyCGDDtECiqfZkN4_1EYuLDa_QhsQiFmvEs";

    PolylinePoints polylinePoints = PolylinePoints();
    MyAppTravelMode travelMode = mode;

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      apiKey,
      PointLatLng(
          currentLocation.latitude ?? 0.0, currentLocation.longitude ?? 0.0),
      PointLatLng(lat, lng),
      travelMode: convertMyAppTravelModeToPolylineTravelMode(travelMode),
    );

    if (result.points.isNotEmpty) {
      setState(() {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      });
    }
  }

  TravelMode convertMyAppTravelModeToPolylineTravelMode(MyAppTravelMode mode) {
    switch (mode) {
      case MyAppTravelMode.driving:
        return TravelMode.driving;
      case MyAppTravelMode.walking:
        return TravelMode.walking;
      case MyAppTravelMode.bicycling:
        return TravelMode.bicycling;
      case MyAppTravelMode.transit:
        return TravelMode.transit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentLocation?.latitude ?? 14.5995,
                  currentLocation?.longitude ?? 120.984222,
                ),
                zoom: 12.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              markers: _markers,
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: polylineCoordinates,
                  color: const Color(0xFF7B61FF),
                  width: 6,
                ),
              },
            ),
          ),
          Positioned(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search location',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                      onSubmitted: (value) {
                        getPolyPoints(
                          LocationData.fromMap(
                              {'latitude': 0.0, 'longitude': 0.0}),
                          selectedMode,
                        );
                      },
                    ),
                  ),
                  // List of travel mode widgets
                  Row(
                    children: buildTravelModeWidgets(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 77.0),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              initMap();
            });
          },
          backgroundColor: const Color(0xFF7B61FF),
          child: const Icon(Icons.location_searching_rounded,
              color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
