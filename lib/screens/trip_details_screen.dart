// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../config/config.dart';
import '../widgets/max_width_section.dart';
import '../widgets/flight_info_card.dart';
import '../widgets/weather_widget.dart';
import '../main.dart';

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

  String _selectedTab = 'overview';
  bool _isFavorited = false;
  bool _isCheckingFavorite = true;

  @override
  void initState() {
    super.initState();
    _selectedClass = widget.trip['class'] ?? 'Economy';
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _isCheckingFavorite = false;
        _isFavorited = false;
      });
      return;
    }

    try {
      final response = await supabase
          .from('favorites')
          .select()
          .eq('user_id', user.id)
          .eq('trip_id', widget.trip['id'])
          .maybeSingle();

      setState(() {
        _isFavorited = response != null;
        _isCheckingFavorite = false;
      });
    } catch (e) {
      setState(() {
        _isCheckingFavorite = false;
        _isFavorited = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to favorite trips'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isFavorited = !_isFavorited;
    });

    try {
      if (_isFavorited) {
        await supabase.from('favorites').insert({
          'user_id': user.id,
          'trip_id': widget.trip['id'],
          'trip_name': widget.trip['title'],
          'trip_location': widget.trip['location'],
          'trip_price': widget.trip['price'],
          'trip_image': widget.trip['image'],
          'favorited_at': DateTime.now().toIso8601String(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to favorites'),
            backgroundColor: successGreen,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await supabase
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('trip_id', widget.trip['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isFavorited = !_isFavorited;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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

  void _selectTab(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  bool get _isBookedView => widget.trip['_isBookedView'] == true;

  Future<void> _showBookingDetailsDialog() async {
    final bookingDate = widget.trip['_bookingDate'] != null 
        ? DateTime.parse(widget.trip['_bookingDate']).toLocal()
        : DateTime.now();
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.receipt_long, color: primaryBlue),
              const SizedBox(width: 10),
              const Text('Booking Details'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogDetailRow('Trip', widget.trip['title']),
                const Divider(height: 20),
                _buildDialogDetailRow('Location', widget.trip['location']),
                const Divider(height: 20),
                _buildDialogDetailRow('Number of Guests', widget.trip['_numberOfGuests']?.toString() ?? 'N/A'),
                const Divider(height: 20),
                _buildDialogDetailRow('Total Price', '\$${widget.trip['_totalPrice']?.toString() ?? 'N/A'}'),
                const Divider(height: 20),
                _buildDialogDetailRow('Booking Date', 
                    '${bookingDate.year}-${bookingDate.month.toString().padLeft(2, '0')}-${bookingDate.day.toString().padLeft(2, '0')}'),
                if (widget.trip['_specialRequests'] != null && widget.trip['_specialRequests'].toString().isNotEmpty) ...[
                  const Divider(height: 20),
                  const Text(
                    'Special Requests:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.trip['_specialRequests'],
                    style: TextStyle(color: subtitleColor),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await _cancelBooking();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.cancel, size: 18),
              label: const Text('Cancel Booking'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: subtitleColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _cancelBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Cancel Booking?'),
          content: const Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No, Keep It'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final bookingId = widget.trip['_bookingId'];
      
      if (bookingId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Booking ID not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      try {
        await supabase
            .from('bookings')
            .delete()
            .eq('id', bookingId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully'),
              backgroundColor: successGreen,
            ),
          );
          widget.navigateTo(AppPage.trips);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Widget _buildTabButton(String tabName, String label, IconData icon) {
    final isSelected = _selectedTab == tabName;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectTab(tabName),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : subtitleColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : subtitleColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.trip['title'],
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: subtitleColor, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        widget.trip['location'],
                        style: const TextStyle(
                          fontSize: 18,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: ratingColor, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        '${widget.trip['rating']} (${widget.trip['reviews']} reviews)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '\$${widget.trip['price']}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          'About this trip',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.trip['description'] ?? 'Explore this amazing destination.',
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),
        
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
        const Text(
          'Trip Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDetailRow(Icons.calendar_today, 'Date', widget.trip['date'] ?? 'TBD'),
              const Divider(height: 30),
              _buildDetailRow(Icons.airplane_ticket, 'Class', widget.trip['class'] ?? 'Economy'),
              const Divider(height: 30),
              _buildDetailRow(Icons.flight, 'Aircraft', widget.trip['aircraft'] ?? 'N/A'),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        const Text(
          'Booking Preferences',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        
        ListTile(
          leading: const Icon(Icons.calendar_today, color: primaryBlue),
          title: const Text('Travel Date'),
          subtitle: Text(_selectedDate == null 
              ? 'Tap to choose date' 
              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
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
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: primaryBlue, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlightContent() {
    return FlightInfoCard(trip: widget.trip);
  }

  Widget _buildWeatherContent() {
    return WeatherWidget(location: widget.trip['location']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => widget.navigateTo(AppPage.trips),
            ),
            actions: [
              if (!_isCheckingFavorite)
                IconButton(
                  icon: Icon(
                    _isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorited ? Colors.red : Colors.white,
                    size: 28,
                  ),
                  onPressed: _toggleFavorite,
                ),
              const SizedBox(width: 10),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.trip['image'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidthSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton('overview', 'Overview', Icons.info_outline),
                        _buildTabButton('flight', 'Flight', Icons.flight),
                        _buildTabButton('weather', 'Weather', Icons.wb_sunny),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_selectedTab == 'overview')
                    _buildOverviewContent()
                  else if (_selectedTab == 'flight')
                    _buildFlightContent()
                  else if (_selectedTab == 'weather')
                    _buildWeatherContent(),
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_isBookedView) {
                            _showBookingDetailsDialog();
                          } else {
                            widget.navigateTo(AppPage.booking, trip: widget.trip);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isBookedView ? primaryBlue : accentOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isBookedView ? Icons.receipt_long : Icons.book_online,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isBookedView ? 'View Booking Details' : 'Book Now',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}