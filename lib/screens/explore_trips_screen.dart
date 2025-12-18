// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../config/config.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/max_width_section.dart';
import '../widgets/trip_card.dart';

class ExploreTripsScreen extends StatelessWidget {
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;
  final bool isLoggedIn;
  final Function(BuildContext context) showAuthModal;
  final VoidCallback onThemeToggle;

  const ExploreTripsScreen({
    super.key,
    required this.navigateTo,
    required this.isLoggedIn,
    required this.showAuthModal,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          navigateTo: (page) => navigateTo(page),
          currentPage: AppPage.explore,
          isLoggedIn: isLoggedIn,
          onAuthAction: () => showAuthModal(context),
          onThemeToggle: onThemeToggle,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: MaxWidthSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Explore All Trips',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${allTrips.length} destinations available',
                        style: TextStyle(fontSize: 16, color: subtitleColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: allTrips.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemBuilder: (context, index) {
                      return TripCard(
                        trip: allTrips[index],
                        onViewDetails: (trip) => navigateTo(AppPage.tripDetails, trip: trip),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
