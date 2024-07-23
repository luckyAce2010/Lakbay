// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LatLng> polylineCoordinates = [];

  Future<LatLng> getPolyPoints(LocationData currentLocation) async {
    String apiKey = "AIzaSyCGDDtECiqfZkN4_1EYuLDa_QhsQiFmvEs";
    String input = _searchController.text;

    if (input.isEmpty) {
      throw Exception('Input is empty. Please enter a location.');
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

          return LatLng(lat, lng);
        } else {
          throw Exception('Error status from the Places API');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter location',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Location location = Location();
                  LocationData currentLocation = await location.getLocation();

                  try {
                    LatLng destinationLatLng =
                        await getPolyPoints(currentLocation);

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NavigationScreen(
                        destinationLatLng.latitude,
                        destinationLatLng.longitude,
                      ),
                    ));
                  } catch (e) {
                    // Handle the error, show a message, etc.
                  }
                },
                child: const Text('Get Directions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationScreen extends StatefulWidget {
  final double lat;
  final double lng;
  const NavigationScreen(this.lat, this.lng, {super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final Completer<GoogleMapController?> _controller = Completer();
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  Location location = Location();
  Marker? sourcePosition, destinationPosition;
  loc.LocationData? _currentPosition;
  LatLng curLocation = const LatLng(23.0525, 72.5667);
  StreamSubscription<loc.LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    getNavigation();
    addMarker();
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: sourcePosition == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: launchNavigation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  // Return to the original MapScreen
                  return const MapScreen();
                }
              },
            ),
    );
  }

  Future<void> launchNavigation() async {
    await launchUrl(Uri.parse(
        'google.navigation:q=${widget.lat},${widget.lng}&key=AIzaSyC8KhMfL0uOnxmyfagABb9tm-CRphTEydI'));
    Navigator.of(context).pop(); // Trigger pop when navigation is done
  }

  getNavigation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    final GoogleMapController? controller = await _controller.future;
    location.changeSettings(accuracy: loc.LocationAccuracy.high);
    serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    if (permissionGranted == loc.PermissionStatus.granted) {
      _currentPosition = await location.getLocation();
      curLocation =
          LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
      locationSubscription =
          location.onLocationChanged.listen((LocationData currentLocation) {
        controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 16,
        )));
        if (mounted) {
          controller
              ?.showMarkerInfoWindow(MarkerId(sourcePosition!.markerId.value));
          setState(() {
            curLocation =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
            sourcePosition = Marker(
              markerId: MarkerId(currentLocation.toString()),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              position:
                  LatLng(currentLocation.latitude!, currentLocation.longitude!),
              infoWindow: InfoWindow(
                  title:
                      '${double.parse((getDistance(LatLng(widget.lat, widget.lng)).toStringAsFixed(2)))} km'),
              onTap: () {},
            );
          });
          getDirections(LatLng(widget.lat, widget.lng));
        }
      });
    }
  }

  getDirections(LatLng dst) async {
    List<LatLng> polylineCoordinates = [];
    List<dynamic> points = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyC8KhMfL0uOnxmyfagABb9tm-CRphTEydI',
        PointLatLng(curLocation.latitude, curLocation.longitude),
        PointLatLng(dst.latitude, dst.longitude),
        travelMode: TravelMode.driving);
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        points.add({'lat': point.latitude, 'lng': point.longitude});
      }
    } else {}
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double getDistance(LatLng destposition) {
    return calculateDistance(curLocation.latitude, curLocation.longitude,
        destposition.latitude, destposition.longitude);
  }

  addMarker() {
    setState(() {
      sourcePosition = Marker(
        markerId: const MarkerId('source'),
        position: curLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      destinationPosition = Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.lat, widget.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      );
    });
  }
}
