import 'package:flutter/material.dart';

import 'auth_modal.dart';
// Import local files
import 'config.dart';
import 'home_screen.dart';
import 'screens.dart';

// --- 0. CUSTOM SCROLL BEHAVIOR FOR SMOOTHNESS ---

class SmoothScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

// --- MAIN APPLICATION SETUP (Stateful for Navigation and State) ---

void main() {
  runApp(const TravelHubApp());
}

class TravelHubApp extends StatefulWidget {
  const TravelHubApp({super.key});

  @override
  State<TravelHubApp> createState() => _TravelHubAppState();
}

class _TravelHubAppState extends State<TravelHubApp> {
  AppPage _currentPage = AppPage.home;
  // State for login status
  bool _isLoggedIn = false;
  // NEW: State for current user data (stores name, email, etc.)
  Map<String, String> _currentUser = {};

  // NEW: Function to handle login/signup success and store profile data
  void _handleLogin(Map<String, String> userData) {
    setState(() {
      _isLoggedIn = true;
      _currentUser = userData;
      _currentPage = AppPage.profile; // Navigate to profile after login/signup
    });
  }

  // Updated: Function to handle logout
  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _currentUser = {};
      _currentPage = AppPage.home; // Navigate to home on logout
    });
  }

  // Navigation function to change the current screen
  void _navigateTo(AppPage page) {
    setState(() {
      // Only allow navigating to profile if logged in
      if (page == AppPage.profile && !_isLoggedIn) {
        _showAuthModal(context);
      } else {
        _currentPage = page;
      }
    });
  }

  // Function to show Auth Modal - Made public to be passed to child widgets
  void _showAuthModal(BuildContext context) {
    showDialog(
      context: context,
      // Pass the new _handleLogin function
      builder: (context) => AuthModal(onLoginSuccess: _handleLogin),
    );
  }

  // Helper to return the correct screen widget
  Widget _getPage() {
    switch (_currentPage) {
      case AppPage.home:
        return TravelHubHomeScreen(
          navigateTo: _navigateTo,
          isLoggedIn: _isLoggedIn,
          showAuthModal: _showAuthModal,
        );
      case AppPage.trips:
        return TripsScreen(
          navigateTo: _navigateTo,
          isLoggedIn: _isLoggedIn,
          showAuthModal: _showAuthModal,
        );
      case AppPage.profile:
        // Pass current user data and logout function
        return ProfileScreen(
          navigateTo: _navigateTo,
          onLogout: _handleLogout,
          initialUserData: _currentUser,
          isLoggedIn: _isLoggedIn,
          showAuthModal: _showAuthModal,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelHub',
      debugShowCheckedModeBanner: false,
      scrollBehavior: SmoothScrollBehavior(),
      theme: ThemeData(
        fontFamily: 'Inter',
        primaryColor: primaryBlue,
        colorScheme: const ColorScheme.light(
          primary: primaryBlue,
          secondary: accentOrange,
        ),
        scaffoldBackgroundColor: lightBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: cardColor,
          elevation: 0,
          iconTheme: IconThemeData(color: primaryBlue),
          titleTextStyle: TextStyle(
            color: primaryBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: lightBackground.withOpacity(0.5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      home: Scaffold(
        body: _getPage(), // Display the current screen
      ),
    );
  }
}
