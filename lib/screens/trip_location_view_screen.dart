// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/config.dart';

// Day location model
class DayLocation {
  final int day;
  final String title;
  final String description;
  final LatLng location;
  final List<String> activities;
  final String time;

  DayLocation({
    required this.day,
    required this.title,
    required this.description,
    required this.location,
    required this.activities,
    required this.time,
  });
}

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

  @override
  void initState() {
    super.initState();
    _loadItinerary();
  }

  void _loadItinerary() {
    final tripId = widget.trip['id'];
    
    if (tripId == '1') {
      // Bali itinerary
      _itinerary = [
        DayLocation(
          day: 1,
          title: 'Arrival in Seminyak',
          description: 'Check-in and beach relaxation',
          location: LatLng(-8.6919, 115.1724),
          activities: [
            'Airport pickup',
            'Hotel check-in',
            'Seminyak Beach sunset',
            'Dinner at La Plancha',
          ],
          time: 'Full Day',
        ),
        DayLocation(
          day: 2,
          title: 'Ubud Cultural Tour',
          description: 'Explore the heart of Bali',
          location: LatLng(-8.5069, 115.2625),
          activities: [
            'Tegalalang Rice Terraces',
            'Sacred Monkey Forest',
            'Ubud Palace',
            'Traditional Balinese lunch',
          ],
          time: '8:00 AM - 6:00 PM',
        ),
        DayLocation(
          day: 3,
          title: 'Tanah Lot Temple',
          description: 'Iconic sea temple visit',
          location: LatLng(-8.6211, 115.0868),
          activities: [
            'Morning temple tour',
            'Coastal photography',
            'Local market shopping',
            'Sunset viewing',
          ],
          time: '9:00 AM - 7:00 PM',
        ),
        DayLocation(
          day: 4,
          title: 'Water Sports & Beach',
          description: 'Adventure at Nusa Dua',
          location: LatLng(-8.8003, 115.2304),
          activities: [
            'Parasailing',
            'Jet skiing',
            'Beach club lunch',
            'Spa treatment',
          ],
          time: '10:00 AM - 5:00 PM',
        ),
        DayLocation(
          day: 5,
          title: 'Uluwatu Temple',
          description: 'Clifftop temple and Kecak dance',
          location: LatLng(-8.8290, 115.0849),
          activities: [
            'Temple exploration',
            'Kecak fire dance',
            'Jimbaran seafood dinner',
            'Beach bonfire',
          ],
          time: '3:00 PM - 9:00 PM',
        ),
      ];
    } else if (tripId == '2') {
      // Paris & Rome itinerary
      _itinerary = [
        DayLocation(
          day: 1,
          title: 'Paris - Eiffel Tower',
          description: 'Iconic landmarks',
          location: LatLng(48.8584, 2.2945),
          activities: [
            'Eiffel Tower visit',
            'Seine River cruise',
            'Trocadéro Gardens',
            'French dinner',
          ],
          time: 'Full Day',
        ),
        DayLocation(
          day: 2,
          title: 'Louvre & Champs-Élysées',
          description: 'Art and shopping',
          location: LatLng(48.8606, 2.3376),
          activities: [
            'Louvre Museum',
            'Mona Lisa viewing',
            'Champs-Élysées walk',
            'Arc de Triomphe',
          ],
          time: '9:00 AM - 7:00 PM',
        ),
        DayLocation(
          day: 3,
          title: 'Montmartre & Sacré-Cœur',
          description: 'Artistic quarter',
          location: LatLng(48.8867, 2.3431),
          activities: [
            'Sacré-Cœur Basilica',
            'Artist square',
            'Moulin Rouge',
            'French bistro dinner',
          ],
          time: '10:00 AM - 8:00 PM',
        ),
        DayLocation(
          day: 4,
          title: 'Travel to Rome',
          description: 'High-speed train journey',
          location: LatLng(41.9028, 12.4964),
          activities: [
            'Train to Rome',
            'Hotel check-in',
            'Spanish Steps',
            'Trevi Fountain',
          ],
          time: 'Full Day',
        ),
        DayLocation(
          day: 5,
          title: 'Ancient Rome',
          description: 'Colosseum and Forum',
          location: LatLng(41.8902, 12.4922),
          activities: [
            'Colosseum tour',
            'Roman Forum',
            'Palatine Hill',
            'Traditional Italian dinner',
          ],
          time: '8:00 AM - 6:00 PM',
        ),
        DayLocation(
          day: 6,
          title: 'Vatican City',
          description: 'Religious and art center',
          location: LatLng(41.9029, 12.4534),
          activities: [
            'St. Peter\'s Basilica',
            'Sistine Chapel',
            'Vatican Museums',
            'Papal audience (if available)',
          ],
          time: '7:00 AM - 4:00 PM',
        ),
      ];
    } else if (tripId == '3') {
      // Swiss Alps itinerary
      _itinerary = [
        DayLocation(
          day: 1,
          title: 'Zurich Arrival',
          description: 'Swiss welcome',
          location: LatLng(47.3769, 8.5417),
          activities: [
            'Airport arrival',
            'Lake Zurich walk',
            'Old Town exploration',
            'Swiss chocolate tasting',
          ],
          time: 'Full Day',
        ),
        DayLocation(
          day: 2,
          title: 'Interlaken Adventure',
          description: 'Gateway to the Alps',
          location: LatLng(46.6863, 7.8632),
          activities: [
            'Paragliding',
            'Lake Brienz cruise',
            'Höhematte Park',
            'Swiss fondue dinner',
          ],
          time: '9:00 AM - 8:00 PM',
        ),
        DayLocation(
          day: 3,
          title: 'Jungfraujoch',
          description: 'Top of Europe',
          location: LatLng(46.5475, 7.9851),
          activities: [
            'Cogwheel train ride',
            'Ice Palace',
            'Sphinx Observatory',
            'Alpine photography',
          ],
          time: '7:00 AM - 5:00 PM',
        ),
        DayLocation(
          day: 4,
          title: 'Zermatt & Matterhorn',
          description: 'Iconic mountain',
          location: LatLng(46.0207, 7.7491),
          activities: [
            'Cable car to Gornergrat',
            'Matterhorn viewing',
            'Alpine hiking',
            'Mountain restaurant',
          ],
          time: '8:00 AM - 6:00 PM',
        ),
        DayLocation(
          day: 5,
          title: 'Lucerne',
          description: 'Historic city',
          location: LatLng(47.0502, 8.3093),
          activities: [
            'Chapel Bridge',
            'Lion Monument',
            'Lake cruise',
            'Old Town shopping',
          ],
          time: '10:00 AM - 7:00 PM',
        ),
      ];
    } else if (tripId == '4') {
      // Tokyo itinerary
      _itinerary = [
        DayLocation(
          day: 1,
          title: 'Shibuya & Harajuku',
          description: 'Modern Tokyo culture',
          location: LatLng(35.6595, 139.7004),
          activities: [
            'Shibuya Crossing',
            'Hachiko statue',
            'Harajuku shopping',
            'Takeshita Street',
          ],
          time: 'Full Day',
        ),
        DayLocation(
          day: 2,
          title: 'Asakusa & Sensoji',
          description: 'Traditional Tokyo',
          location: LatLng(35.7148, 139.7967),
          activities: [
            'Sensoji Temple',
            'Nakamise Shopping Street',
            'Tokyo Skytree',
            'Traditional dinner',
          ],
          time: '9:00 AM - 8:00 PM',
        ),
        DayLocation(
          day: 3,
          title: 'Akihabara & Ueno',
          description: 'Tech and culture',
          location: LatLng(35.7020, 139.7744),
          activities: [
            'Electronics shopping',
            'Anime stores',
            'Ueno Park',
            'Tokyo National Museum',
          ],
          time: '10:00 AM - 7:00 PM',
        ),
        DayLocation(
          day: 4,
          title: 'Mount Fuji Day Trip',
          description: 'Iconic mountain',
          location: LatLng(35.3606, 138.7274),
          activities: [
            'Bus to Mt. Fuji',
            'Lake Kawaguchi',
            'Chureito Pagoda',
            'Hot spring onsen',
          ],
          time: '6:00 AM - 9:00 PM',
        ),
        DayLocation(
          day: 5,
          title: 'Shinjuku & Roppongi',
          description: 'Nightlife and views',
          location: LatLng(35.6938, 139.7034),
          activities: [
            'Tokyo Metropolitan Building',
            'Shinjuku Gyoen Garden',
            'Robot Restaurant',
            'Roppongi Hills',
          ],
          time: '11:00 AM - 11:00 PM',
        ),
      ];
    }
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
          onPressed: () => widget.navigateTo(AppPage.tripDetails, trip: widget.trip),
        ),
      ),
      body: LayoutBuilder(
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
        center: _itinerary.isNotEmpty 
            ? _itinerary[0].location 
            : LatLng(0, 0),
        zoom: 11.0,
        minZoom: 3.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.travelhub.app',
        ),
        
        // Route polyline
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
                          color: isSelected 
                              ? accentOrange 
                              : primaryBlue,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${dayLoc.day}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isSelected ? accentOrange : primaryBlue,
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              }).toList(),
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
        }).toList(),
      ],
    );
  }
}