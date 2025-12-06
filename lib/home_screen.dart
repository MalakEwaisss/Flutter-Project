// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'config.dart';
import 'widgets_reusable.dart';

// Define the signature needed for auth action
typedef ShowAuthModal = void Function(BuildContext context);

// --- 1. HOME SCREEN WIDGET ---

class TravelHubHomeScreen extends StatelessWidget {
  final Function(AppPage) navigateTo;
  final bool isLoggedIn;
  final ShowAuthModal showAuthModal; // Function to trigger modal

  const TravelHubHomeScreen({
    super.key,
    required this.navigateTo,
    required this.isLoggedIn,
    required this.showAuthModal,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Hero and Search Section
          _HeroSection(
            navigateTo: navigateTo,
            isLoggedIn: isLoggedIn,
            onAuthAction: () => showAuthModal(context),
          ),

          // 2. Popular Trips Section
          MaxWidthSection(child: _PopularTripsSection(navigateTo: navigateTo)),

          // 3. Who We Are / About Us Section
          const MaxWidthSection(child: _WhoWeAreSection()),

          // 4. Why Choose Us Section
          const MaxWidthSection(child: _WhyChooseUsSection()),

          // 5. Footer Section
          const AppFooter(),
        ],
      ),
    );
  }
}

// --- HERO SECTION ---

class _HeroSection extends StatelessWidget {
  final Function(AppPage) navigateTo;
  final bool isLoggedIn;
  final VoidCallback onAuthAction;

  const _HeroSection({
    required this.navigateTo,
    required this.isLoggedIn,
    required this.onAuthAction,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.65;

    return Container(
      height: heroHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0E7FF), Colors.white, Color(0xFFF4F7FB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomAppBar(
              navigateTo: navigateTo,
              isLoggedIn: isLoggedIn,
              onAuthAction: onAuthAction,
            ),
          ),

          // Main Hero Content
          Positioned(
            top: heroHeight * 0.25,
            left: 0,
            right: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text.rich(
                        TextSpan(
                          text: 'Discover Your Next ',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: primaryBlue,
                            height: 1.1,
                          ),
                          children: [
                            TextSpan(
                              text: 'Adventure',
                              style: TextStyle(color: accentOrange),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        'Explore curated trips, connect with fellow travelers, and create unforgettable memories together',
                        style: TextStyle(fontSize: 16, color: subtitleColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => navigateTo(AppPage.trips),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                        elevation: 10,
                      ),
                      child: const Text(
                        'Explore Trips',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Search Bar
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: TripSearchBar(navigateTo: navigateTo),
          ),
        ],
      ),
    );
  }
}

// --- POPULAR TRIPS SECTION ---

class _PopularTripsSection extends StatelessWidget {
  final Function(AppPage) navigateTo;
  const _PopularTripsSection({required this.navigateTo});

  static final List<Map<String, dynamic>> _popularTrips = allTrips
      .take(4)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Popular Trips',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trending destinations loved by our community',
                  style: TextStyle(fontSize: 18, color: subtitleColor),
                ),
                TextButton.icon(
                  onPressed: () => navigateTo(AppPage.trips),
                  icon: const Icon(Icons.arrow_forward, color: primaryBlue),
                  label: const Text(
                    'View All',
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 30),

        // Horizontal Card List
        SizedBox(
          height: 420,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularTrips.length,
            padding: const EdgeInsets.only(left: 4.0),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < _popularTrips.length - 1 ? 24 : 4,
                ),
                child: PopularTripCard(
                  trip: _popularTrips[index],
                  navigateTo: navigateTo, // Pass navigate function
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- WHO WE ARE SECTION ---
class _WhoWeAreSection extends StatelessWidget {
  const _WhoWeAreSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              'https://picsum.photos/300/300?random=21',
              width: 300,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 300,
                height: 300,
                color: primaryBlue.withOpacity(0.1),
                child: const Center(
                  child: Icon(Icons.groups, color: primaryBlue, size: 80),
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Who We Are',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: accentOrange,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'TravelHub was founded by a passionate group of globetrotters who believe travel should be accessible, seamless, and deeply enriching. We connect travelers with expert-curated itineraries and a vibrant community to share experiences.',
                  style: TextStyle(
                    fontSize: 18,
                    color: subtitleColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Our Mission:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: successGreen),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'To simplify group travel planning and maximize adventure.',
                        style: TextStyle(color: subtitleColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: successGreen),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'To foster a global community of curious and respectful explorers.',
                        style: TextStyle(color: subtitleColor),
                      ),
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

// --- WHY CHOOSE US SECTION ---
class _WhyChooseUsSection extends StatelessWidget {
  const _WhyChooseUsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Why Choose TravelHub?',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We make sure your next trip is the easiest one yet.',
          style: TextStyle(fontSize: 18, color: subtitleColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        // Feature Grid
        Wrap(
          spacing: 24,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: const [
            _FeatureCard(
              icon: Icons.security,
              title: 'Secure Booking',
              description:
                  'Your payments and data are protected with industry-leading encryption.',
              color: primaryBlue,
            ),
            _FeatureCard(
              icon: Icons.support_agent,
              title: '24/7 Support',
              description:
                  'Our dedicated team is always ready to assist you, no matter the time zone.',
              color: accentOrange,
            ),
            _FeatureCard(
              icon: Icons.star_rate,
              title: 'Curated Trips',
              description:
                  'Hand-picked destinations and itineraries rated highly by real travelers.',
              color: successGreen,
            ),
          ],
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}

// Reusable Feature Card
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 16, color: subtitleColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- FOOTER WIDGET ---
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryBlue,
      child: MaxWidthSection(
        verticalPadding: 50.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Footer Content (Logo + Links)
            Wrap(
              spacing: 60,
              runSpacing: 40,
              alignment: WrapAlignment.spaceBetween,
              children: [
                // 1. Logo and Description
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: accentOrange,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'TravelHub',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your premium gateway to the world\'s most exciting destinations. Join our community of explorers.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Links (Using Wrap for responsiveness)
                Wrap(
                  spacing: 60,
                  runSpacing: 20,
                  children: const [
                    _FooterLinkColumn(
                      title: 'Company',
                      links: ['About Us', 'Careers', 'Press', 'Blog'],
                    ),
                    _FooterLinkColumn(
                      title: 'Support',
                      links: ['Help Center', 'Contact Us', 'Safety', 'FAQs'],
                    ),
                    _FooterLinkColumn(
                      title: 'Legal',
                      links: [
                        'Terms of Use',
                        'Privacy Policy',
                        'Sitemap',
                        'Cookie Settings',
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 50, color: Colors.white24),

            // Copyright
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2024 TravelHub, Inc. All rights reserved.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.facebook, color: Colors.white70),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white70),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for link columns
class _FooterLinkColumn extends StatelessWidget {
  final String title;
  final List<String> links;

  const _FooterLinkColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: accentOrange,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...links
            .map(
              (link) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {}, // Simulated link navigation
                  child: Text(
                    link,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}
