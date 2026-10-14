import 'package:flutter/material.dart';

class AppRatingBadge extends StatelessWidget {
  final double rating;

  const AppRatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}