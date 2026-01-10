// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/day_location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/config.dart';
import '../../services/ai_location_service.dart'; // Add this import


class TripLocationViewScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;

  const TripLocationViewScreen({
    super.key,
    required this.trip,
    required this.navigateTo,
  });

  @override
  State<TripLocationViewScreen> createState() => _TripLocationViewScreenState();
}

class _TripLocationViewScreenState extends State<TripLocationViewScreen> {
  final MapController _mapController = MapController();
  int? _selectedDay;
  List<DayLocation> _itinerary = [];
  bool _isLoading = true; // Add this variable

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  Future<void> _loadItinerary() async {
    setState(() => _isLoading = true);

    try {
      // Extract number of days from trip date string
      final dateString = widget.trip['date'] ?? '';
      final days = _calculateDays(dateString);

      final itineraryData = await AILocationService.generateItinerary(
        widget.trip['title'],
        widget.trip['location'],
        days,
      );

      setState(() {
        _itinerary = itineraryData.map((item) => DayLocation(
          day: item['day'],
          title: item['title'],
          description: item['description'],
          location: LatLng(
            double.parse(item['latitude'].toString()),
            double.parse(item['longitude'].toString()),
          ),
          activities: List<String>.from(item['activities']),
          time: item['time'],
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading itinerary: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to calculate days from date range
  int _calculateDays(String dateRange) {
    try {
      // Parse date range like "Mar 15 - Mar 22"
      final parts = dateRange.split('-');
      if (parts.length == 2) {
        // Simple calculation: assume 7-8 days for most trips
        return 7;
      }
    } catch (e) {
      // Default fallback
    }
    return 5; // Default to 5 days
  }

  void _selectDay(int day) {
    setState(() {
      _selectedDay = _selectedDay == day ? null : day;
    });

    if (_selectedDay != null) {
      final dayLocation = _itinerary.firstWhere((loc) => loc.day == day);
      _mapController.move(dayLocation.location, 13.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.trip['title']} - Itinerary'),
        backgroundColor: primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              widget.navigateTo(AppPage.tripDetails, trip: widget.trip),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Generating itinerary...',
                    style: TextStyle(fontSize: 16, color: subtitleColor),
                  ),
                ],
              ),
            )
          : _itinerary.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No itinerary available',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Unable to load trip itinerary',
                        style: TextStyle(fontSize: 14, color: subtitleColor),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadItinerary,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 900;

                    if (isMobile) {
                      return _buildMobileLayout();
                    } else {
                      return _buildDesktopLayout();
                    }
                  },
                ),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Map
        _buildMap(),

        // Itinerary bottom sheet
        DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.15,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _buildItineraryList(scrollController),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Map on the left
        Expanded(
          flex: 2,
          child: _buildMap(),
        ),

        // Itinerary on the right
        Container(
          width: 450,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
          child: _buildItineraryList(null),
        ),
      ],
    );
  }

  Widget _buildMap() {
    // Create markers for all stops
    final markers = _itinerary.map((dayLoc) {
      final isSelected = _selectedDay == dayLoc.day;

      return Marker(
        point: dayLoc.location,
        width: 70,
        height: 70,
        child: GestureDetector(
          onTap: () => _selectDay(dayLoc.day),
          child: Column(
            children: [
              Container(
                width: isSelected ? 50 : 40,
                height: isSelected ? 50 : 40,
                decoration: BoxDecoration(
                  color: isSelected ? accentOrange : primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${dayLoc.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSelected ? 20 : 16,
                    ),
                  ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    'Day ${dayLoc.day}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();

    // Create polyline connecting all locations
    final routePoints = _itinerary.map((loc) => loc.location).toList();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _itinerary.isNotEmpty ? _itinerary[0].location : LatLng(0, 0),
        initialZoom: 11.0,
        minZoom: 3.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.travelhub.app',
        ),

        // Route polyline
        if (routePoints.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 4.0,
                color: accentOrange,
                borderStrokeWidth: 2.0,
                borderColor: Colors.white,
              ),
            ],
          ),

        // Location markers
        MarkerLayer(markers: markers),

        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItineraryList(ScrollController? scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trip Itinerary',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_itinerary.length} days planned',
                  style: const TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentOrange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.route, size: 16, color: accentOrange),
                  const SizedBox(width: 6),
                  Text(
                    '${_itinerary.length} Stops',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentOrange,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Day cards
        ..._itinerary.asMap().entries.map((entry) {
          final index = entry.key;
          final dayLoc = entry.value;
          final isSelected = _selectedDay == dayLoc.day;
          final isLast = index == _itinerary.length - 1;

          return Column(
            children: [
              GestureDetector(
                onTap: () => _selectDay(dayLoc.day),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentOrange.withOpacity(0.1)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? accentOrange : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: [
                      if (!isSelected)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? accentOrange : primaryBlue,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${dayLoc.day}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color:
                                        isSelected ? accentOrange : primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Day ${dayLoc.day}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    dayLoc.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),

                      // Day content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: subtitleColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dayLoc.time,
                                  style: const TextStyle(
                                    color: subtitleColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              dayLoc.description,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            // Show activities if selected
                            if (isSelected) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Activities:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...dayLoc.activities.map((activity) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: accentOrange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          activity,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Connector line (except for last item)
              if (!isLast)
                Row(
                  children: [
                    const SizedBox(width: 20),
                    Container(
                      width: 2,
                      height: 20,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
            ],
          );
        }),
      ],
    );
  }
}