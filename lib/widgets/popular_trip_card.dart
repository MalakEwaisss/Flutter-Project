// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../config/config.dart';

// Specialized card used in the horizontal list on the Home Screen
class PopularTripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  final Function(Map<String, dynamic>) onViewDetails;

  const PopularTripCard({super.key, required this.trip, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => onViewDetails(trip),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(trip['image'], width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: ratingColor, size: 16),
                      const SizedBox(width: 4),
                      Text(trip['rating'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(' (${trip['reviews']})', style: const TextStyle(color: subtitleColor, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${trip['price']}',
                    style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
