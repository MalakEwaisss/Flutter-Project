// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/map/SelectMeetingPointScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/auth_modal.dart';
import 'config/config.dart';
import 'providers/admin_provider.dart';
import 'providers/community_provider.dart';
import 'providers/map_state_provider.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/booking_summary_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/explore_trips_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map/saved_locations_screen.dart';
import 'screens/map/trip_location_view_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search/filters_screen.dart';
import 'screens/search/search_results.dart';
import 'screens/search/trip_search_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/trip_details_screen.dart';
import 'screens/trips_screen.dart';
import 'screens/map/map_overview_screen.dart';
// [Franco]: Custom scroll behavior 3ashan el app ykon "smooth" f-el mobile mesh zay el web
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

  // Loading env variables (zay el keys bta3et supabase law maktoba f-milaf kharigy)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env file: $e");
  }

  // Initializing Supabase - dah elly bey-rabat el app bel database
  await Supabase.initialize(
    url: 'https://jofcdkdoxhkjejgkdrbk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpvZmNka2RveGhramVqZ2tkcmJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU5MzY1ODIsImV4cCI6MjA4MTUxMjU4Mn0.z3gUMnRDFNp3zvxaXd1jXyZa-CwINR43KIQOBJa66TQ',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => MapStateProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const TravelHubApp(),
    ),
  );
}

// Global client 3ashan nesta3melo f-ay makan fel app mn gher re-init
final supabase = Supabase.instance.client;

class TravelHubApp extends StatefulWidget {
  const TravelHubApp({super.key});
  @override
  State<TravelHubApp> createState() => _TravelHubAppState();
}

class _TravelHubAppState extends State<TravelHubApp> {
  // --- Global App State ---
  AppPage _currentPage = AppPage.home;
  AppPage _previousPage = AppPage.home;
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  Map<String, String> _currentUser = {};
  Map<String, dynamic>? _selectedTrip;
  ThemeMode _themeMode = ThemeMode.light;
  int _tripsRefreshKey =
      0; // 3ashan n-force refresh lel trips screen lama trga3lha

  @override
  void initState() {
    super.initState();

    // [Franco]: 1. Check session awel ma el app yeftah (Persistence)
    // Dah bey-shof law fih token m-7foz fel phone 3ashan may-ollosh "login" tany
    _checkInitialSession();

    // [Franco]: 2. Auth Listener - dah el "Ear" bta3et el app
    // Bey-esma3 le supabase tol el wa2t, law el user 3amal login aw logout
    // el state btet-ghayar automatic f-kol el pages.
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final user = session?.user;

      if (mounted) {
        setState(() {
          if (user != null) {
            _isLoggedIn = true;
            // [Franco]: Ben-check el role mn el metadata elly f-supabase
            _isAdmin = user.userMetadata?['role'] == 'admin';

            _currentUser = {
              'name': user.userMetadata?['full_name'] ?? 'Traveler',
              'email': user.email ?? '',
            };
          } else {
            // Law el session kholset aw 3amal logout
            _isLoggedIn = false;
            _isAdmin = false;
            _currentUser = {};
          }
        });
      }
    });
  }

  // [Franco]: Function bte-check el session el-7alya mn supabase direct awel ma el app y-start
  void _checkInitialSession() {
    final session = supabase.auth.currentSession;
    if (session != null && session.user != null) {
      setState(() {
        _isLoggedIn = true;
        _isAdmin = session.user.userMetadata?['role'] == 'admin';
        _currentUser = {
          'name': session.user.userMetadata?['full_name'] ?? 'Traveler',
          'email': session.user.email ?? '',
        };
      });
    }
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  // [Franco]: Function de bttnada mn el AuthModal lama el login y-ngat7
  void _handleLogin(Map<String, String> userData) {
    setState(() {
      _isLoggedIn = true;
      _isAdmin = false;
      _currentUser = userData;
      _currentPage = AppPage.profile; // Weddih el profile 3alatool
    });
  }

  void _handleAdminLogin(Map<String, String> userData) {
    setState(() {
      _isLoggedIn = true;
      _isAdmin = true;
      _currentUser = userData;
      _currentPage = AppPage.adminDashboard;
    });
  }

  void _handleLogout() async {
    // [Franco]: Signout mn supabase lazim 3ashan el token yet-mesah mn el phone
    await supabase.auth.signOut();
    setState(() {
      _isLoggedIn = false;
      _isAdmin = false;
      _currentUser = {};
      _currentPage = AppPage.home;
    });
  }

  // [Franco]: El "Custom Router" bta3na 3ashan n-control el pages statefuly
  void _navigateTo(AppPage page, {Map<String, dynamic>? trip}) {
    setState(() {
      final mainPages = [
        AppPage.home,
        AppPage.trips,
        AppPage.explore,
        AppPage.savedLocations,
        AppPage.map,
        AppPage.profile,
        AppPage.community,
      ];

      // Save previous page 3ashan na3raf nerga3 feen (zay trip details -> home)
      if (page != _currentPage && mainPages.contains(_currentPage)) {
        _previousPage = _currentPage;
      }

      _currentPage = page;
      if (trip != null) _selectedTrip = trip;

      // Law rayeh el trips, zawed el key 3ashan ya3mel re-fetch lel data
      if (page == AppPage.trips) _tripsRefreshKey++;
    });
  }

  void _showAuthModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AuthModal(
        onLoginSuccess: _handleLogin,
        onAdminLogin: _handleAdminLogin,
      ),
    );
  }

  // [Franco]: El Logic bta3 el "Body" bta3 el app mmsok hna
  Widget _getPage() {
    // [Franco]: Extra Sync check 3ashan el profile mayshofsh data adima
    final user = supabase.auth.currentUser;
    if (user != null) {
      _isLoggedIn = true;
      _isAdmin = user.userMetadata?['role'] == 'admin';
    }

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
        if (_selectedTrip == null)
          return const Center(child: Text("No trip selected."));
        return TripDetailsScreen(
          trip: _selectedTrip!,
          navigateTo: _navigateTo,
          previousPage: _previousPage,
        );
      case AppPage.selectMeetingPoint:
        return SelectMeetingPointScreen(
          trip: _selectedTrip!,
          navigateTo: _navigateTo,
        );
        case AppPage.savedLocations:
        return SavedLocationsScreen(
          isLoggedIn: _isLoggedIn,
          showAuthModal: _showAuthModal,
          onThemeToggle: _toggleTheme,
          navigateTo: _navigateTo,
        );
      case AppPage.tripLocationView:
        return TripLocationViewScreen(
          trip: _selectedTrip!,
          navigateTo: _navigateTo,
        );
      case AppPage.booking:
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
      case AppPage.community:
        return CommunityScreen(
          navigateTo: _navigateTo,
          isLoggedIn: _isLoggedIn,
          showAuthModal: _showAuthModal,
          onThemeToggle: _toggleTheme,
        );
      case AppPage.adminDashboard:
        return AdminDashboardScreen(onLogout: _handleLogout);
      default:
        return TravelHubHomeScreen(
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
        // [Franco]: Dynamic routing lel search results ma3 pass el arguments
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
        return MaterialPageRoute(
          builder: (context) => Scaffold(body: _getPage()),
        );
      },
    );
  }
}
