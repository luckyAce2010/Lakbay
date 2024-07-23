import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/api/setters.dart';
import 'package:lakbay/to-go-list/TravelPlans/TravelPlanCardList.dart';

class TravelPlanList extends StatefulWidget {
  final Map<String, dynamic> data;

  const TravelPlanList({super.key, required this.data});

  @override
  // ignore: library_private_types_in_public_api
  _TravelPlanListState createState() => _TravelPlanListState();
}

class _TravelPlanListState extends State<TravelPlanList> {
  List<String> travelPlans = [];
  List<String> travelPlansId = [];
  Setters databaseService = Setters();
  final TextEditingController travelPlanNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTravelPlans();
  }

  Future<void> _loadTravelPlans() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      Map<String, List<String>> loadedData = {
        'travelPlanNames': [],
        'travelPlanIds': [],
      };

      try {
        User? currentUser = auth.currentUser;
        if (currentUser == null) {
          return;
        }

        String userId = currentUser.uid;
        Query travelPlansReference = FirebaseDatabase.instance
            .ref()
            .child("favorites/$userId/travelPlans");

        DatabaseEvent dataSnapshot = await travelPlansReference.once();

        dynamic data = dataSnapshot.snapshot.value;

        if (data.isNotEmpty) {
          data.forEach((key, value) async {
            loadedData['travelPlanNames']?.addAll([value['travelPlanName']]);
            loadedData['travelPlanIds']?.addAll([value['travelPlanId']]);
          });
        }
      } catch (error) {
        if (kDebugMode) {
          print("Error in loadTravelPlanFromDatabase: $error");
        }
      }

      if (loadedData.isNotEmpty) {
        List<String> newTravelPlans =
            loadedData['travelPlanNames'] ?? ['no data'];
        List<String> newTravelPlanIds =
            loadedData['travelPlanIds'] ?? ['no data'];

        setState(() {
          travelPlans = newTravelPlans;
          travelPlansId = newTravelPlanIds;
        });
      }
    } catch (e) {
      // Handle error (e.g., log or show an error message)
      if (kDebugMode) {
        print('Error loading travel plans: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Plans'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:15.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: travelPlans.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      TravelPlanCard(
                        travelPlanName: travelPlans[index],
                        travelPlanId: travelPlansId[index],
                        onUpdateFolderName: (newName) {
                          _updateFolderName(index, newName);
                        },
                        data: widget.data,
                      ),
                      const SizedBox(height: 10.0,),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFolderDialog();
        },
        tooltip: 'Add Travel Plan',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddFolderDialog() {
    travelPlanNameController.text = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Travel Plan'),
          content: TextField(
            controller: travelPlanNameController,
            decoration: const InputDecoration(labelText: 'Travel Plan Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _addTravelPlan();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addTravelPlan() async {
    try {
      String newFolderId = DateTime.now().millisecondsSinceEpoch.toString();
      String newFolderName = travelPlanNameController.text.isNotEmpty
          ? travelPlanNameController.text
          : 'New Travel Plan';

      Navigator.of(context).pop();

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return;
      }

      String userId = currentUser.uid;

      await databaseService.saveFolderToDatabase(
          userId, newFolderId, newFolderName);

      setState(() {
        travelPlans.add(newFolderName);
        travelPlansId.add(newFolderId);
      });
    } catch (e) {
      // Handle error (e.g., log or show an error message)
    }
  }

  void _updateFolderName(int index, String newName) async {
    try {
      setState(() {
        travelPlans[index] = newName;
      });

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return;
      }

      String userId = currentUser.uid;
      String folderId = travelPlansId[index];

      await databaseService.saveFolderToDatabase(userId, folderId, newName);
    } catch (e) {
      // Handle error (e.g., log or show an error message)
      if (kDebugMode) {
        print('Error updating travel plan name: $e');
      }
    }
  }
}
