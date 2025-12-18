// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../config/config.dart';

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
            child: Text('My Trips', style: TextStyle(color: currentPage == AppPage.trips ? accentOrange : primaryBlue)),
          ),
          TextButton(
            onPressed: () => navigateTo(AppPage.map),
            child: Text('Map', style: TextStyle(color: currentPage == AppPage.map ? accentOrange : primaryBlue)),
          ),
          TextButton(
            onPressed: () => navigateTo(AppPage.savedLocations),
            child: Text('Saved', style: TextStyle(color: currentPage == AppPage.savedLocations ? accentOrange : primaryBlue)),
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