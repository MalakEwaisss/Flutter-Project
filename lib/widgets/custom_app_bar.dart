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
        // [Franco]: Law el shasha soghayara (zay el mobile), esta3mel el compact menu
        final bool isCompact = constraints.maxWidth < 900;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Row(
            children: [
              const Text(
                'Travio',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isCompact) _buildCompactMenu(context) else _buildFullMenu(context),
            ],
          ),
        );
      },
    );
  }

  // [Franco]: Menu el Web aw el shashat el kebira
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
          onPressed: () => Navigator.of(context).pushNamed('/search'),
          tooltip: 'Search Trips',
          color: primaryBlue,
        ),
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
            color: primaryBlue,
          ),
          onPressed: onThemeToggle,
          tooltip: 'Toggle theme',
        ),
        const SizedBox(width: 8),
        
        // [Franco]: El zorar dah bey-ghayar shaklo (Sign In vs Profile)
        // 3ala 7asab el user logged in wala la2
        ElevatedButton(
          onPressed: isLoggedIn 
              ? () => navigateTo(AppPage.profile) // Law logged in, rooh el profile
              : onAuthAction,                   // Law la2, talle3 el auth modal
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

  // [Franco]: Menu el Mobile (Dropdown menu)
  Widget _buildCompactMenu(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => Navigator.of(context).pushNamed('/search'),
          tooltip: 'Search Trips',
          color: primaryBlue,
        ),
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
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
            // [Franco]: Hena law ekhtar "Profile/Sign In" men el menu el soghayara
            if (page == AppPage.profile) {
              if (isLoggedIn) {
                navigateTo(AppPage.profile);
              } else {
                onAuthAction();
              }
            } else {
              navigateTo(page);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<AppPage>>[
            _buildPopupItem(AppPage.home, Icons.home, 'Home'),
            _buildPopupItem(AppPage.trips, Icons.card_travel, 'My Trips'),
            _buildPopupItem(AppPage.map, Icons.map, 'Map'),
            _buildPopupItem(AppPage.savedLocations, Icons.bookmark, 'Saved'),
            _buildPopupItem(AppPage.community, Icons.groups, 'Community'),
            const PopupMenuDivider(),
            PopupMenuItem<AppPage>(
              value: AppPage.profile,
              child: Row(
                children: [
                  // [Franco]: Icon btet-ghayar 7asab el login state
                  Icon(isLoggedIn ? Icons.person : Icons.login, color: primaryBlue, size: 20),
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

  PopupMenuItem<AppPage> _buildPopupItem(AppPage page, IconData icon, String title) {
    final bool isActive = currentPage == page;
    return PopupMenuItem<AppPage>(
      value: page,
      child: Row(
        children: [
          // [Franco]: Law el saf7a de heyya elly maftoo7a, khalli el icon orange
          Icon(icon, color: isActive ? accentOrange : primaryBlue, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isActive ? accentOrange : null,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
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