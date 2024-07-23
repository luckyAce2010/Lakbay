// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:lakbay/to-go-list/Scroller.dart';

class TravelPlanCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const TravelPlanCard(
      {super.key,
      required this.travelPlanName,
      required this.travelPlanId,
      required this.onUpdateFolderName,
      required this.data});

  final String travelPlanName;
  final String travelPlanId;
  final Function(String) onUpdateFolderName;

  @override
  _TravelPlanCardState createState() => _TravelPlanCardState();
}

class _TravelPlanCardState extends State<TravelPlanCard> {
  late TextEditingController _controller;

  late String travelPlanId;

  @override
  void initState() {
    super.initState();
    // Ensure widget.travelPlanId is not null before assigning it
    travelPlanId = widget.travelPlanId;

    _controller = TextEditingController(text: widget.travelPlanName);
  }

  @override
  Widget build(BuildContext context) {
    travelPlanId = widget.travelPlanId;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.accentSmokeGreenColor,
        border: Border.all(
          width: 1.5,
          color: AppColors.accentLightGreenColor,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            _showRenameDialog(context);
          },
          child: const Icon(Icons.edit, color: AppColors.accentDarkGreenColor),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BoldNormalText(widget.travelPlanName, AppColors.accentBlackColor),
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: AppColors.accentBlackColor,),
              onPressed: () {
                print("Travel Plan ID: $travelPlanId");
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          Scroller(travelPlanId: widget.travelPlanId)),
                );
              },
            ),
          ],
        ),
        onTap: () {
          print("Travel Plan ID: $travelPlanId");
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    Scroller(travelPlanId: widget.travelPlanId)),
          );
        },
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Travel Plan'),
          content: TextField(
            controller: _controller,
            decoration:
                const InputDecoration(labelText: 'New Travel Plan Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newName = _controller.text;

                widget.onUpdateFolderName(newName);

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
