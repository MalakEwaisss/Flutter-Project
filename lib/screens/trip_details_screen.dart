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
  String _selectedTab = 'overview';
  bool _isFavorited = false;
  bool _isCheckingFavorite = true;

  @override
  void initState() {
    super.initState();
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

  void _selectTab(String tab) {
    setState(() {
      _selectedTab = tab;
    });
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
        const SizedBox(height: 30),
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
                          widget.navigateTo(AppPage.booking, trip: widget.trip);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
