// lib/widgets_reusable.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'config.dart';

class MaxWidthSection extends StatelessWidget {
  final Widget child;
  const MaxWidthSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: child,
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final Function(AppPage) navigateTo;
  final AppPage currentPage;
  final bool isLoggedIn;
  final VoidCallback onAuthAction;
  final VoidCallback onThemeToggle;

  const CustomAppBar({
    super.key,
    required this.navigateTo,
    required this.isLoggedIn,
    required this.onAuthAction,
    required this.onThemeToggle,
    this.currentPage = AppPage.home,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          const Text(
            'TravelHub',
            style: TextStyle(color: primaryBlue, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => navigateTo(AppPage.home),
            child: Text('Home', style: TextStyle(color: currentPage == AppPage.home ? accentOrange : primaryBlue)),
          ),
          TextButton(
            onPressed: () => navigateTo(AppPage.trips),
            child: Text('Trips', style: TextStyle(color: currentPage == AppPage.trips ? accentOrange : primaryBlue)),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: onThemeToggle,
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onAuthAction,
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: Text(isLoggedIn ? 'Profile' : 'Sign In', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

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