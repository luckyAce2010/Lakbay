// ignore: file_names
import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double starSize;

  const RatingStars({
    super.key,
    required this.rating,
    this.starSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    int numberOfStars = rating.floor();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < numberOfStars ? Icons.star : Icons.star_border,
          size: starSize,
          color: Colors.amber,
        ),
      ),
    );
  }
}
