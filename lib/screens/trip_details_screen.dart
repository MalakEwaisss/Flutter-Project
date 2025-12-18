// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'dart:math';
import '../config/config.dart';
import '../widgets/max_width_section.dart';
import '../main.dart'; // Access global 'supabase' client

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
  String? _meetingPoint;

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
                  
                  const SizedBox(height: 20),
                  // View Itinerary Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.navigateTo(AppPage.tripLocationView, trip: widget.trip);
                      },
                      icon: const Icon(Icons.route, color: primaryBlue),
                      label: const Text(
                        'View Full Itinerary & Map',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: primaryBlue, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
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

                  ListTile(
                    leading: const Icon(Icons.place, color: primaryBlue),
                    title: const Text('Meeting Point'),
                    subtitle: Text(_meetingPoint ?? 'Tap to select meeting location'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      widget.navigateTo(AppPage.selectMeetingPoint, trip: widget.trip);
                    },
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