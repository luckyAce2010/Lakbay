import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:lakbay/pages/emergency-widgets/callWidget.dart';

//Pages
import 'package:lakbay/pages/emergency-widgets/weatherWidget.dart';
import 'package:lakbay/pages/emergency-widgets/nearestEmergency.dart';
import 'package:lakbay/pages/emergency-widgets/contactsWidget.dart';

//For state management
import 'package:lakbay/location/locationProvider.dart';
import 'package:lakbay/location/getLocation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  LocationData? locationData = ref.watch(locationProvider);

  String locationCity = '${locationData?.city}';
  
    return Scaffold(
      backgroundColor: AppColors.accentWhiteColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
        child: ListView(
          children: [
            Column(
              children: [
                WeatherInfoWidget(location: '$locationCity, Philippines'), // Replace 'Manila' with the desired city name
                const SizedBox(height: 10),
              ],
            ),
            
            const SizedBox(height:15.0),
            const HeaderText('Nearest Stations'),
            const SizedBox(height:15.0),
            const Row(
              children: [
                Expanded(
                  child: EmergencyContainer(
                    title: 'Medical Station',
                    icon: Icons.local_hospital,
                    emergencyType: 'hospital',
                  ),
                ),
                SizedBox(width: 10.0,),
                Expanded(
                  child: EmergencyContainer(
                    title: 'Police Station',
                    icon: Icons.local_police,
                    emergencyType: 'police',
                  ),
                ),
              ]
            ),

            const SizedBox(height:25.0),
            const HeaderText('Hotlines'),
            const SizedBox(height:15.0),
            CallRow(contactName: 'National Emergency Hotline', contactNumber: '911'),
            const SizedBox(height:10),
            CallRow(contactName: 'Philippine Red Cross', contactNumber: '143'),
            const SizedBox(height:10),
            CallRow(contactName: 'Philippine National Police', contactNumber: '117'),
            const SizedBox(height:10),
            CallRow(contactName: 'NDRRMC', contactNumber: '911-1406 '),

            
            const SizedBox(height:25.0),
            const HeaderText('Emeregency Contacts'),
            const SizedBox(height:15.0),
            DynamicDataWidget(latitude: '${locationData?.latitude}', longitude: '${locationData?.longitude}', formattedAddress: '${locationData?.formattedAddress}'),
            const SizedBox(height:75.0),
          ],
        ),
      ),
    );
  }
}


class DynamicDataWidget extends ConsumerStatefulWidget {

  final String latitude;
  final String longitude;
  final String formattedAddress;

  const DynamicDataWidget({super.key, required this.latitude, required this.longitude, required this.formattedAddress});

  @override
  ConsumerState<DynamicDataWidget> createState() => _DynamicDataWidgetState(latitude: latitude, longitude: longitude, formattedAddress: formattedAddress);
}

class _DynamicDataWidgetState extends ConsumerState<DynamicDataWidget> {
  final CollectionReference userDetailsCollection =
      FirebaseFirestore.instance.collection('user-details');

  List<Map<String, dynamic>> contactList = [];

  
  final String latitude;
  final String longitude;
  final String formattedAddress;

  _DynamicDataWidgetState({required this.formattedAddress,required this.latitude, required this.longitude});

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        DocumentSnapshot snapshot =
          await userDetailsCollection.doc(userId).get();

        var fetchedContactList =
            snapshot['contact_list'] as List<dynamic>? ?? [];

        setState(() {
          contactList = List<Map<String, dynamic>>.from(fetchedContactList);
        });
     }
    } catch (error) {
      print('Error fetching data: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return contactList.isEmpty
        ? const Center(child: Text('No data available'))
        : Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: contactList.length,
                itemBuilder: (context, index) {
                  var contact = contactList[index];

                  return Column(
                    children: [
                      ContactRow(
                        contactName: '${contact['contact_name']}',
                        contactNumber: '${contact['contact_number']}',
                        latitude: latitude,
                        longitude: longitude,
                        locationData: formattedAddress,
                      ),
                      const SizedBox(height: 10.0), // Adjust the height as needed
                    ],
                  );
                },
              ),
            ],
          );
  }
}
