// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/screens/SelectMeetingPointScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth/auth_modal.dart';
import 'config/config.dart';
import 'screens/home_screen.dart';
import 'screens/trips_screen.dart';
import 'screens/trip_details_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/map_overview_screen.dart';
import 'screens/trip_location_view_screen.dart';
import 'screens/saved_locations_screen.dart';

import 'screens/booking_summary_screen.dart';
import 'screens/explore_trips_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/search/trip_search_screen.dart';
import 'screens/search/filters_screen.dart';
import 'screens/search/search_results.dart';

class SmoothScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }

  // Initializing with your provided credentials
  await Supabase.initialize(
    url: 'https://jofcdkdoxhkjejgkdrbk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpvZmNka2RveGhramVqZ2tkcmJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5MzY1ODIsImV4cCI6MjA4MTUxMjU4Mn0.z3gUMnRDFNp3zvxaXd1jXyZa-CwINR43KIQOBJa66TQ',
  );

  runApp(const TravelHubApp());
}

// Global Supabase client for easy access across the app
final supabase = Supabase.instance.client;

class TravelHubApp extends StatefulWidget {
  const TravelHubApp({super.key});
  @override
  State<TravelHubApp> createState() => _TravelHubAppState();
}

class _TravelHubAppState extends State<TravelHubApp> {
  AppPage _currentPage = AppPage.home;
  bool _isLoggedIn = false;
  Map<String, String> _currentUser = {};
  Map<String, dynamic>? _selectedTrip;
  ThemeMode _themeMode = ThemeMode.light;
  int _tripsRefreshKey = 0;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  void _handleLogin(Map<String, String> userData) {
    setState(() {
      _isLoggedIn = true;
      _currentUser = userData;
      _currentPage = AppPage.profile;
    });
  }

  void _handleLogout() async {
    await supabase.auth.signOut();
    setState(() {
      _isLoggedIn = false;
      _currentUser = {};
      _currentPage = AppPage.home;
    });
  }

  void _navigateTo(AppPage page, {Map<String, dynamic>? trip}) {
    setState(() {
      _currentPage = page;
      if (trip != null) _selectedTrip = trip;
      // Force trips screen to reload when navigating to it
      if (page == AppPage.trips) {
        _tripsRefreshKey++;
      }
    });
  }

  void _showAuthModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AuthModal(onLoginSuccess: _handleLogin),
    );
  }

  Widget _getPage() {
    switch (_currentPage) {
      case AppPage.home:
        return TravelHubHomeScreen(
          navigateTo: _navigateTo,
          isLoggedIn: _isLoggedIn,
          showAuthModal: _showAuthModal,
          onThemeToggle: _toggleTheme,
        );
      case AppPage.trips:
        return TripsScreen(
          key: ValueKey(_tripsRefreshKey),
          navigateTo: _navigateTo,
          isLoggedIn: _isLoggedIn,
          showAuthModal: _showAuthModal,
          onThemeToggle: _toggleTheme,
        );
      case AppPage.map:
        return MapOverviewScreen(
          navigateTo: _navigateTo,
          isLoggedIn: _isLoggedIn,
          showAuthModal: _showAuthModal,
          onThemeToggle: _toggleTheme,
        );
      case AppPage.profile:
        return ProfileScreen(
          navigateTo: _navigateTo,
          onLogout: _handleLogout,
          initialUserData: _currentUser,
          isLoggedIn: _isLoggedIn,
          showAuthModal: _showAuthModal,
          onThemeToggle: _toggleTheme,
        );
      case AppPage.tripDetails:
        // Ensure we have trip data before loading the details screen
        if (_selectedTrip == null) {
          return const Center(child: Text("No trip selected. Return to Home."));
        }
        return TripDetailsScreen(trip: _selectedTrip!, navigateTo: _navigateTo);
      case AppPage.selectMeetingPoint:
        if (_selectedTrip == null) {
          return const Center(child: Text("No trip selected. Return to Home."));
        }
        return SelectMeetingPointScreen(
          trip: _selectedTrip!,
          navigateTo: _navigateTo,
        );
      case AppPage.tripLocationView:
        if (_selectedTrip == null) {
          return const Center(child: Text("No trip selected. Return to Home."));
        }
        return TripLocationViewScreen(
          trip: _selectedTrip!,
          navigateTo: _navigateTo,
        );
      case AppPage.savedLocations:
        return SavedLocationsScreen(
          navigateTo: _navigateTo,
          isLoggedIn: _isLoggedIn,
          showAuthModal: _showAuthModal,
          onThemeToggle: _toggleTheme,
        );

      case AppPage.booking:
        if (_selectedTrip == null) {
          return const Center(child: Text("No trip selected. Return to Home."));
        }
        return BookingSummaryScreen(
          trip: _selectedTrip!,
          navigateTo: _navigateTo,
        );
      case AppPage.explore:
        return ExploreTripsScreen(
          navigateTo: _navigateTo,
          isLoggedIn: _isLoggedIn,
          showAuthModal: _showAuthModal,
          onThemeToggle: _toggleTheme,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: SmoothScrollBehavior(),
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: lightBackground,
        cardColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: accentOrange,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/search': (context) => const TripSearchScreen(),
        '/filters': (context) => const FiltersScreen(),
        '/home': (context) => Scaffold(body: _getPage()),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/search-results') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => SearchResultsScreen(
              destination: args?['destination'] as String?,
              dateRange: args?['dateRange'] as DateTimeRange?,
              budget: args?['budget'] as double?,
            ),
          );
        }
        if (settings.name == '/trip-details') {
          final trip = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) =>
                TripDetailsScreen(trip: trip, navigateTo: _navigateTo),
          );
        }
        return MaterialPageRoute(
          builder: (context) => Scaffold(body: _getPage()),
        );
      },
    );
  }
}
