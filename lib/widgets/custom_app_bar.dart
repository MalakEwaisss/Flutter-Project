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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we need a compact layout
        final bool isCompact = constraints.maxWidth < 900;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Row(
            children: [
              // Logo
              const Text(
                'Travio',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),

              if (isCompact)
                // Compact menu with dropdown
                _buildCompactMenu(context)
              else
                // Full menu
                _buildFullMenu(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullMenu(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNavButton('Home', AppPage.home, currentPage == AppPage.home),
        _buildNavButton('My Trips', AppPage.trips, currentPage == AppPage.trips),
        _buildNavButton('Map', AppPage.map, currentPage == AppPage.map),
        _buildNavButton('Saved', AppPage.savedLocations, currentPage == AppPage.savedLocations),
        _buildNavButton('Community', AppPage.community, currentPage == AppPage.community),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.of(context).pushNamed('/search');
          },
          tooltip: 'Search Trips',
          color: primaryBlue,
        ),
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode,
            color: primaryBlue,
          ),
          onPressed: onThemeToggle,
          tooltip: 'Toggle theme',
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onAuthAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(isLoggedIn ? 'Profile' : 'Sign In'),
        ),
      ],
    );
  }

  Widget _buildCompactMenu(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.of(context).pushNamed('/search');
          },
          tooltip: 'Search Trips',
          color: primaryBlue,
        ),
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode,
            color: primaryBlue,
          ),
          onPressed: onThemeToggle,
          tooltip: 'Toggle theme',
        ),
        const SizedBox(width: 4),
        PopupMenuButton<AppPage>(
          icon: const Icon(Icons.menu, color: primaryBlue),
          tooltip: 'Menu',
          onSelected: (AppPage page) {
            if (page == AppPage.profile) {
              onAuthAction();
            } else {
              navigateTo(page);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<AppPage>>[
            PopupMenuItem<AppPage>(
              value: AppPage.home,
              child: Row(
                children: [
                  Icon(
                    Icons.home,
                    color: currentPage == AppPage.home ? accentOrange : primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Home',
                    style: TextStyle(
                      color: currentPage == AppPage.home ? accentOrange : null,
                      fontWeight: currentPage == AppPage.home
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<AppPage>(
              value: AppPage.trips,
              child: Row(
                children: [
                  Icon(
                    Icons.card_travel,
                    color: currentPage == AppPage.trips ? accentOrange : primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'My Trips',
                    style: TextStyle(
                      color: currentPage == AppPage.trips ? accentOrange : null,
                      fontWeight: currentPage == AppPage.trips
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<AppPage>(
              value: AppPage.map,
              child: Row(
                children: [
                  Icon(
                    Icons.map,
                    color: currentPage == AppPage.map ? accentOrange : primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Map',
                    style: TextStyle(
                      color: currentPage == AppPage.map ? accentOrange : null,
                      fontWeight: currentPage == AppPage.map
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<AppPage>(
              value: AppPage.savedLocations,
              child: Row(
                children: [
                  Icon(
                    Icons.bookmark,
                    color: currentPage == AppPage.savedLocations ? accentOrange : primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Saved',
                    style: TextStyle(
                      color: currentPage == AppPage.savedLocations ? accentOrange : null,
                      fontWeight: currentPage == AppPage.savedLocations
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<AppPage>(
              value: AppPage.community,
              child: Row(
                children: [
                  Icon(
                    Icons.groups,
                    color: currentPage == AppPage.community ? accentOrange : primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Community',
                    style: TextStyle(
                      color: currentPage == AppPage.community ? accentOrange : null,
                      fontWeight: currentPage == AppPage.community
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<AppPage>(
              value: AppPage.profile,
              child: Row(
                children: [
                  Icon(
                    isLoggedIn ? Icons.person : Icons.login,
                    color: primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isLoggedIn ? 'Profile' : 'Sign In',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton(String label, AppPage page, bool isActive) {
    return TextButton(
      onPressed: () => navigateTo(page),
      style: TextButton.styleFrom(
        foregroundColor: isActive ? accentOrange : primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 15,
        ),
      ),
    );
  }
}