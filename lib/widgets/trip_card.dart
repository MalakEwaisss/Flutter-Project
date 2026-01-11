
import 'package:flutter/material.dart';
import '../config/config.dart';

// Main card used in the Grid on the Trips Screen
class TripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  final Function(Map<String, dynamic>) onViewDetails;

  const TripCard({super.key, required this.trip, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(trip['image'], height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(trip['location'], style: const TextStyle(color: subtitleColor, fontSize: 14)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${trip['price']}', style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 20)),
                    ElevatedButton(
                      onPressed: () => onViewDetails(trip),
                      style: ElevatedButton.styleFrom(backgroundColor: accentOrange),
                      child: const Text('Details', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
