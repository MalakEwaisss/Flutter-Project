// lib/screens.dart
import 'package:flutter/material.dart';
import 'dart:math'; // For unique seat number generation
import 'config.dart';
import 'widgets_reusable.dart';
import 'main.dart'; // Access global 'supabase' client

// --- TRIP LIST SCREEN ---
class TripsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          navigateTo: (page) => navigateTo(page),
          currentPage: AppPage.trips,
          isLoggedIn: isLoggedIn,
          onAuthAction: () => showAuthModal(context),
          onThemeToggle: onThemeToggle,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: MaxWidthSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended Trips',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: allTrips.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemBuilder: (context, index) {
                      return TripCard(
                        trip: allTrips[index],
                        onViewDetails: (trip) => navigateTo(AppPage.tripDetails, trip: trip),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- TRIP DETAILS SCREEN (Supabase Integration) ---
class TripDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;

  const TripDetailsScreen({super.key, required this.trip, required this.navigateTo});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  DateTime? _selectedDate;
  String? _selectedClass;
  bool _isLoading = false;

  final List<String> _seatCategories = ['Economy', 'Economy Plus', 'Business Class', 'First Class'];

  @override
  void initState() {
    super.initState();
    _selectedClass = widget.trip['class'] ?? 'Economy';
  }

  // Helper to generate a unique seat number (e.g., 24B)
  String _generateUniqueSeat() {
    final random = Random();
    final row = random.nextInt(40) + 1; // Rows 1-40
    final letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    final seatLetter = letters[random.nextInt(letters.length)];
    return '$row$seatLetter';
  }

  

  Future<void> _handleBooking() async {
    // 1. Check Login Status
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to book this trip'), backgroundColor: Colors.red),
      );
      return;
    }

    // 2. Validate Date
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a travel date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String seatNum = _generateUniqueSeat();

      // 3. Insert into Supabase 'bookings' table
      await supabase.from('bookings').insert({
        'user_id': user.id,
        'trip_name': widget.trip['title'],
        'travel_date': _selectedDate!.toIso8601String(),
        'seat_category': _selectedClass,
        'seat_number': seatNum,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Success! Seat $seatNum reserved for ${widget.trip['title']}'),
            backgroundColor: successGreen,
          ),
        );
        widget.navigateTo(AppPage.trips);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip['title']),
        backgroundColor: primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => widget.navigateTo(AppPage.trips),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(widget.trip['image'], width: double.infinity, height: 350, fit: BoxFit.cover),
            MaxWidthSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.trip['title'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                          Text(widget.trip['location'], style: const TextStyle(fontSize: 20, color: subtitleColor)),
                        ],
                      ),
                      Text('\$${widget.trip['price']}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryBlue)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text('About this trip', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(widget.trip['description'] ?? 'Explore this amazing destination.', style: const TextStyle(fontSize: 16, height: 1.6)),
                  const SizedBox(height: 30),
                  const Text('Booking Preferences', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Divider(),
                  
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: primaryBlue),
                    title: const Text('Travel Date'),
                    subtitle: Text(_selectedDate == null ? 'Tap to choose date' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                    onTap: () => _selectDate(context),
                  ),

                  ListTile(
                    leading: const Icon(Icons.airline_seat_recline_extra, color: primaryBlue),
                    title: const Text('Seat Category'),
                    subtitle: DropdownButton<String>(
                      value: _selectedClass,
                      isExpanded: true,
                      onChanged: (val) => setState(() => _selectedClass = val),
                      items: _seatCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    ),
                  ),

                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: 300,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text('Confirm & Book Now', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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