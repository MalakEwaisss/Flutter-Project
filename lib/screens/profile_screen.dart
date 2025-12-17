// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../config/config.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/max_width_section.dart';

// --- PROFILE SCREEN ---
class ProfileScreen extends StatelessWidget {
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;
  final VoidCallback onLogout;
  final Map<String, String> initialUserData;
  final bool isLoggedIn;
  final Function(BuildContext context) showAuthModal;
  final VoidCallback onThemeToggle;

  const ProfileScreen({
    super.key,
    required this.navigateTo,
    required this.onLogout,
    required this.initialUserData,
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
          currentPage: AppPage.profile,
          isLoggedIn: isLoggedIn,
          onAuthAction: () => showAuthModal(context),
          onThemeToggle: onThemeToggle,
        ),
        Expanded(
          child: Center(
            child: MaxWidthSection(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: primaryBlue,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(initialUserData['name'] ?? 'Explorer', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(initialUserData['email'] ?? '', style: const TextStyle(fontSize: 16, color: subtitleColor)),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
