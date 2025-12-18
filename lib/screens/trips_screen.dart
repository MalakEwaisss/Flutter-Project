// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../config/config.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/max_width_section.dart';
import '../widgets/trip_card.dart';
import '../main.dart';

class TripsScreen extends StatefulWidget {
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;
  final bool isLoggedIn;
  final Function(BuildContext context) showAuthModal;
  final VoidCallback onThemeToggle;

  const TripsScreen({
    super.key,
    required this.navigateTo,
    required this.isLoggedIn,
    required this.showAuthModal,
    required this.onThemeToggle,
  });

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String _currentView = 'bookings';
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      _loadData();
    }
  }

  @override
  void didUpdateWidget(TripsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data when returning to this screen (e.g., after cancelling a booking)
    if (widget.isLoggedIn && !_isLoading) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    if (_currentView == 'bookings') {
      await _fetchBookings();
    } else {
      await _fetchFavorites();
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _fetchBookings() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('booking_date', ascending: false);

      setState(() {
        _bookings = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bookings: $e')),
        );
      }
    }
  }

  Future<void> _fetchFavorites() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .order('favorited_at', ascending: false);

      setState(() {
        _favorites = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading favorites: $e')),
        );
      }
    }
  }

  void _switchView(String view) {
    setState(() {
      _currentView = view;
    });
    _loadData();
  }

  Widget _buildViewToggle() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _switchView('bookings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentView == 'bookings' ? primaryBlue : Colors.grey[300],
              foregroundColor: _currentView == 'bookings' ? Colors.white : Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_currentView == 'bookings' ? Icons.bookmark : Icons.bookmark_border),
                const SizedBox(width: 8),
                const Text('My Bookings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _switchView('favorites'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentView == 'favorites' ? accentOrange : Colors.grey[300],
              foregroundColor: _currentView == 'favorites' ? Colors.white : Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_currentView == 'favorites' ? Icons.favorite : Icons.favorite_border),
                const SizedBox(width: 8),
                const Text('My Favorites', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isBookings = _currentView == 'bookings';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isBookings ? Icons.luggage_outlined : Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              isBookings ? 'No bookings yet' : 'No favorites yet',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              isBookings 
                  ? 'Start planning your next adventure!'
                  : 'Browse trips and save your favorites!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: subtitleColor),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => widget.navigateTo(AppPage.home),
              icon: const Icon(Icons.explore),
              label: const Text('Explore Trips'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsList() {
    final trips = _currentView == 'bookings' ? _bookings : _favorites;
    
    if (trips.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: trips.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 0.85,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemBuilder: (context, index) {
        final item = trips[index];
        
        final tripData = {
          'id': item['trip_id'] ?? '',
          'title': item['trip_name'] ?? 'Unknown Trip',
          'location': item['location'] ?? item['trip_location'] ?? 'Unknown Location',
          'price': item['total_price'] ?? item['trip_price'] ?? 0,
          'image': item['trip_image'] ?? 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=400',
          'rating': 4.5,
          // Add booking metadata if viewing from My Bookings
          if (_currentView == 'bookings') ...{
            '_isBookedView': true,
            '_bookingId': item['id'],
            '_numberOfGuests': item['number_of_guests'],
            '_specialRequests': item['special_requests'],
            '_bookingDate': item['booking_date'],
            '_totalPrice': item['total_price'],
          },
        };

        return TripCard(
          trip: tripData,
          onViewDetails: (trip) => widget.navigateTo(AppPage.tripDetails, trip: trip),
        );
      },
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text(
              'Login Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Please log in to view your bookings and favorites',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: subtitleColor),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => widget.showAuthModal(context),
              icon: const Icon(Icons.login),
              label: const Text('Log In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          navigateTo: (page) => widget.navigateTo(page),
          currentPage: AppPage.trips,
          isLoggedIn: widget.isLoggedIn,
          onAuthAction: () => widget.showAuthModal(context),
          onThemeToggle: widget.onThemeToggle,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: MaxWidthSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isLoggedIn 
                        ? (_currentView == 'bookings' ? 'My Bookings' : 'My Favorites')
                        : 'My Trips',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  if (widget.isLoggedIn) ...[
                    _buildViewToggle(),
                    const SizedBox(height: 30),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(60),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      _buildTripsList(),
                  ] else
                    _buildNotLoggedIn(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
