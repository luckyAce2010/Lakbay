import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lakbay/api/setters.dart';

class DateCard extends StatefulWidget {
  final String cardText;
  final List<String> selectedPlaces;
  final String travelPlanId;

  const DateCard({
    super.key,
    required this.cardText,
    required this.selectedPlaces,
    required this.travelPlanId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DateCardState createState() => _DateCardState();
}

class _DateCardState extends State<DateCard> {
  String? selectedDate;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: Container(
        width: screenWidth - 16,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.cardText,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontFamily: 'Poppins',
                  fontStyle: FontStyle.italic),
            ),
            if (selectedDate != null)
              Text(
                '$selectedDate',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (pickedDate != null) {
      setState(() {
        final formattedDate = pickedDate.toLocal().toString().split(' ')[0];
        selectedDate = formattedDate;
      });

      // ignore: use_build_context_synchronously
      _showSelectedPlacesModal(context, travelPlanId: widget.travelPlanId);
    }
  }

  Future<void> _showSelectedPlacesModal(BuildContext context,
      {required String travelPlanId}) async {
    // Create a copy of the original saved places to display in the modal
    List<String> selectedPlaces = List.from(widget.selectedPlaces);
    List<String> temporarilySelectedPlaces = List.from(widget.selectedPlaces);

    // Show the modal bottom sheet
    final result = await showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Choose Places for Selected Date',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  // Display the list of selected places with checkboxes
                  for (String place in temporarilySelectedPlaces)
                    CheckboxListTile(
                      title: Text(place),
                      value: temporarilySelectedPlaces.contains(place),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null) {
                            if (value) {
                              temporarilySelectedPlaces.add(place);
                            } else {
                              temporarilySelectedPlaces.remove(place);
                            }
                          }
                        });
                      },
                    ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            Setters databaseService = Setters();
                            await databaseService.travelDatetoDatabase(
                              travelPlanId: travelPlanId,
                              selectedPlaces: temporarilySelectedPlaces,
                              dateScheduleId: selectedDate ??
                                  'defaultId', // Use a default value or handle null
                            );
                            await databaseService.budgetPlaces(
                                travelPlanId: travelPlanId,
                                selectedPlaces: selectedPlaces);
                          } catch (e) {
                            if (kDebugMode) {
                              print('Error adding travel date to database: $e');
                            }
                          }

                          Navigator.pop(context); // Close the bottom sheet

                          if (kDebugMode) {
                            print(temporarilySelectedPlaces);
                          }
                        },
                        child: const Text('Save'),
                      )
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      if (kDebugMode) {
        print('Selected Places: $result');
      }
    }
  }
}

class NewTravelDateButton extends StatelessWidget {
  const NewTravelDateButton({
    super.key,
    required this.onAddCard,
    required travelPlanId,
  });

  final VoidCallback onAddCard;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ElevatedButton(
        onPressed: onAddCard,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Colors.blue,
            ),
            SizedBox(width: 8.0),
            Text(
              'Save Travel Date',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

class NewTravelDate extends StatefulWidget {
  const NewTravelDate({
    super.key,
    required this.dateCards,
    required this.selectedPlaces,
    required this.travelPlanId,
  });

  final List<String> dateCards;
  final List<String> selectedPlaces;
  final String travelPlanId;

  @override
  _NewTravelDateState createState() => _NewTravelDateState();
}

class _NewTravelDateState extends State<NewTravelDate> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.dateCards.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    DateCard(
                      cardText: widget.dateCards[index],
                      selectedPlaces: widget.selectedPlaces,
                      travelPlanId: widget.travelPlanId,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
