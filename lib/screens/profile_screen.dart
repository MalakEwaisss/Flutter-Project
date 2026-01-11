// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../config/config.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/max_width_section.dart';

// --- PROFILE SCREEN ---
class ProfileScreen extends StatelessWidget {
  // El functions de gaya mel main.dart 3ashan ne-control el tana2ol wel logout
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;
  final VoidCallback onLogout;
  
  // initialUserData: di elly kan fih el moshkela, delwa2ti gaya mel "Listener" f-main
  final Map<String, String> initialUserData;
  
  // isLoggedIn: de elly be-t2ol lel screen "warre el data" wala "talle3 login button"
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
    // Law el user mosh logged in (zay ma kan bey-7sal ma3ak), momken n-talle3lo kalam y-fakkaro
    if (!isLoggedIn) {
      return Column(
        children: [
          CustomAppBar(
            navigateTo: (page) => navigateTo(page),
            currentPage: AppPage.profile,
            isLoggedIn: isLoggedIn,
            onAuthAction: () => showAuthModal(context),
            onThemeToggle: onThemeToggle,
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Please login to view your profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    // Law el user logged in sa7, warrelo el data bta3to
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
                  // Soret el profile el sbeta
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: primaryBlue,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  
                  // Hena el kalam elly hay-etghayar awel ma t-create account
                  // initialUserData['name'] bey-akhod el 'full_name' mel metadata
                  Text(
                    initialUserData['name'] ?? 'Explorer', 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                  ),
                  
                  Text(
                    initialUserData['email'] ?? '', 
                    style: const TextStyle(fontSize: 16, color: subtitleColor)
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Zorrar el Logout
                  ElevatedButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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