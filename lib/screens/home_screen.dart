// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../config/config.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/max_width_section.dart';
import '../widgets/popular_trip_card.dart';

typedef ShowAuthModal = void Function(BuildContext context);

class TravelHubHomeScreen extends StatelessWidget {
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;
  final bool isLoggedIn;
  final ShowAuthModal showAuthModal;
  final VoidCallback onThemeToggle;

  const TravelHubHomeScreen({
    super.key,
    required this.navigateTo,
    required this.isLoggedIn,
    required this.showAuthModal,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _HeroSection(
            navigateTo: navigateTo,
            isLoggedIn: isLoggedIn,
            onAuthAction: () => showAuthModal(context),
            onThemeToggle: onThemeToggle,
          ),
          MaxWidthSection(child: _PopularTripsSection(navigateTo: navigateTo)),
          const MaxWidthSection(child: _WhoWeAreSection()),
          const MaxWidthSection(child: _WhyChooseUsSection()),
          const AppFooter(),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;
  final bool isLoggedIn;
  final VoidCallback onAuthAction;
  final VoidCallback onThemeToggle;

  const _HeroSection({
    required this.navigateTo,
    required this.isLoggedIn,
    required this.onAuthAction,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 700;
        return Container(
          height: isMobile ? 550 : MediaQuery.of(context).size.height * 0.7,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.light
                  ? [const Color(0xFFE0E7FF), Colors.white]
                  : [const Color(0xFF1A1A1A), const Color(0xFF121212)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              CustomAppBar(
                navigateTo: (page) => navigateTo(page),
                isLoggedIn: isLoggedIn,
                onAuthAction: onAuthAction,
                onThemeToggle: onThemeToggle,
                currentPage: AppPage.home,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Discover Your Next Adventure',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: isMobile ? 36 : 64, fontWeight: FontWeight.w900, color: Theme.of(context).brightness == Brightness.light ? primaryBlue : Colors.white)),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => navigateTo(AppPage.explore),
                      style: ElevatedButton.styleFrom(backgroundColor: accentOrange, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      child: const Text('Start Exploring', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PopularTripsSection extends StatelessWidget {
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;
  const _PopularTripsSection({required this.navigateTo});

  @override
  Widget build(BuildContext context) {
    final trips = allTrips.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Popular Trips', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          height: 420,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: trips.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: SizedBox(
                  width: 300,
                  child: PopularTripCard(
                    trip: trips[index],
                    onViewDetails: (trip) => navigateTo(AppPage.tripDetails, trip: trip),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WhoWeAreSection extends StatelessWidget {
  const _WhoWeAreSection();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
          child: isMobile
              ? Column(children: [_buildImage(), const SizedBox(height: 20), _buildContent()])
              : Row(children: [Expanded(child: _buildImage()), const SizedBox(width: 40), Expanded(child: _buildContent())]),
        );
      },
    );
  }

  Widget _buildImage() => ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: Image.network(
      'https://images.unsplash.com/photo-1549897411-b06572cdf806?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      fit: BoxFit.cover,
      height: 300,
      width: double.infinity,
    ),
  );

  Widget _buildContent() => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Who We Are', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: accentOrange)),
      SizedBox(height: 12),
      Text('TravelHub connects travelers with expert-curated itineraries and a vibrant community.', style: TextStyle(fontSize: 16, height: 1.5)),
    ],
  );
}

class _WhyChooseUsSection extends StatelessWidget {
  const _WhyChooseUsSection();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Why Choose TravelHub?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Wrap(
          spacing: 20, runSpacing: 20, alignment: WrapAlignment.center,
          children: const [
            _FeatureCard(icon: Icons.verified_user, title: 'Secure Booking'),
            _FeatureCard(icon: Icons.support_agent, title: '24/7 Support'),
            _FeatureCard(icon: Icons.explore, title: 'Unique Destinations'),
          ],
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  const _FeatureCard({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
      child: Column(children: [Icon(icon, size: 40, color: accentOrange), const SizedBox(height: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }
}

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, color: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.location_on, color: Colors.white), SizedBox(width: 8), Text('TravelHub', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 20),
        Text('© 2024 TravelHub. All rights reserved.', style: TextStyle(color: Colors.white.withOpacity(0.7))),
      ]),
    );
  }
}
