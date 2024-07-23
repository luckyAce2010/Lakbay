// ignore_for_file: library_private_types_in_public_api, unused_local_variable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lakbay/PlaceLister/DetailsScreen.dart';
import 'package:lakbay/PlaceLister/RatingStars.dart';

class PlaceCard extends StatefulWidget {
  final Map<String, dynamic> cardData;
  final int index;

  const PlaceCard({
    super.key, // Change super.key to key
    required this.cardData,
    required this.index,
    required BuildContext context,
  }); // Use key here

  @override
  _PlaceCardState createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  bool isFavorite = false;
  String apiKey = dotenv.env['GOOGLE_PLACES_API_KEY']!;

  @override
  Widget build(BuildContext context) {
    String photoReference = widget.cardData["picture_url"]!;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(3),
      child: ListTile(
        contentPadding: const EdgeInsets.all(7),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(cardData: widget.cardData),
            ),
          );
          if (kDebugMode) {
            print('Clicked on ${widget.cardData["name"]}');
          }
        },
        title: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 20 / 9,
                        child: Image.network(
                          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photo_reference=$photoReference&key=$apiKey',
                          // '',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Text content
                      Text(
                        widget.cardData["name"],
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RatingStars(
                        rating: widget.cardData["ratings"].toDouble(),
                        starSize: 16.0, // Set the desired star size
                      ),
                      const SizedBox(height: 7.3),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
