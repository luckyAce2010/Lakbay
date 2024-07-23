// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lakbay/To-Go-List/TravelPlans/AddToTravelPlanList.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';
import 'package:lakbay/PlaceLister/RatingStars.dart';

class DetailsScreen extends StatefulWidget {
  final Map<String, dynamic> cardData;

  const DetailsScreen({super.key, required this.cardData});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool isFavorite = false;
  String apiKey = dotenv.env['GOOGLE_PLACES_API_KEY']!;

  @override
  Widget build(BuildContext context) {
    String photoReference = widget.cardData["picture_url"]!;
    String price = widget.cardData["price_level"] ?? "No Price Available";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network('https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&photo_reference=$photoReference&key=$apiKey',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              // Place name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.cardData["name"],
                    style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentDarkGreenColor,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    widget.cardData["formatted_address"],
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: AppColors.accentDarkGreenColor,
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RatingStars(
                        rating: widget.cardData["ratings"].toDouble(),
                        starSize: 24.0, // Set the desired star size
                      ),
                      NormalText('(${widget.cardData["number_of_ratings"]})',
                          AppColors.accentBlackColor),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Description",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                widget.cardData["description"] is Map
                    ? (widget.cardData["description"]["text"]?.toString() ??
                        "No Address Found")
                    : ("No Desciption Found"),
                maxLines: 2,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentBlackColor,
                ),
              ),

              const SizedBox(height: 20),
              Text(
                'Price Level: ${price}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Reviews",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap:true, // Set to true to let the ListView take the height it needs
                itemCount: widget.cardData["reviews"].length,
                itemBuilder: (context, index) {
                  var review = widget.cardData["reviews"][index];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 15.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.accentLightGreenColor, width: 2.0),
                      color: AppColors.accentSmokeGreenColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review["authorAttribution"]["displayName"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        RatingStars(
                          rating: review["rating"].toDouble(),
                          starSize: 20.0, // Set the desired star size
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          review["relativePublishTimeDescription"] ?? "",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          review["text"]["text"] ?? "",
                          style: const TextStyle(
                            fontSize: 14.0,
                            height: 1.5,
                          ),
                        ),
                        // Add other review details you want to display
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: AppColors.accentLightGreenColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite
                ? AppColors.accentRedColor
                : AppColors.accentWhiteColor,
          ),
          onPressed: () {
            setState(() {
              isFavorite = !isFavorite;

              if (isFavorite) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => TravelPlanList(data: widget.cardData),
                  ),
                );
              }
            });
          },
        ),
      ),
    );
  }
}
