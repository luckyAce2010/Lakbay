// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class SavedTravelPlanCards extends StatefulWidget {
  const SavedTravelPlanCards({
    super.key,
    required this.placeCards,
  });

  final List<String> placeCards;

  @override
  _SavedTravelPlanCardsState createState() => _SavedTravelPlanCardsState();
}

class _SavedTravelPlanCardsState extends State<SavedTravelPlanCards> {
  List<bool> selectedItems =
      List.generate(100, (index) => false); // Assuming 10 items initially

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.builder(
        itemCount: widget.placeCards.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: CheckboxListTile(
              title: Text(widget.placeCards[index]),
              value: selectedItems[index],
              onChanged: (value) {
                setState(() {
                  selectedItems[index] = value!;
                });
              },
            ),
          );
        },
      ),
    );
  }
}
