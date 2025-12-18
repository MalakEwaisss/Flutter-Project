// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/config.dart';
import '../widgets/custom_app_bar.dart';

// Real location data for trips
final Map<String, LatLng> tripLocations = {
  '1': LatLng(-8.4095, 115.1889), // Bali, Indonesia
  '2': LatLng(48.8566, 2.3522),   // Paris, France
  '3': LatLng(46.8182, 8.2275),   // Swiss Alps
  '4': LatLng(35.6762, 139.6503), // Tokyo, Japan
};

class MapOverviewScreen extends StatefulWidget {
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;
  final bool isLoggedIn;
  final Function(BuildContext context) showAuthModal;
  final VoidCallback onThemeToggle;

  const MapOverviewScreen({
    super.key,
    required this.navigateTo,
    required this.isLoggedIn,
    required this.showAuthModal,
    required this.onThemeToggle,
  });

  @override
  State<MapOverviewScreen> createState() => _MapOverviewScreenState();
}

class _MapOverviewScreenState extends State<MapOverviewScreen> {
  String? _selectedTripId;
  bool _showList = true;
  final MapController _mapController = MapController();

  void _onTripSelected(String tripId) {
    setState(() {
      _selectedTripId = tripId;
    });
    
    // Animate to the selected trip location
    final location = tripLocations[tripId];
    if (location != null) {
      _mapController.move(location, 8.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          navigateTo: (page) => widget.navigateTo(page),
          currentPage: AppPage.map,
          isLoggedIn: widget.isLoggedIn,
          onAuthAction: () => widget.showAuthModal(context),
          onThemeToggle: widget.onThemeToggle,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 900;
              
              if (isMobile) {
                // Mobile: Stack map with bottom sheet
                return Stack(
                  children: [
                    _RealMapView(
                      mapController: _mapController,
                      selectedTripId: _selectedTripId,
                      onMarkerTap: _onTripSelected,
                    ),
                    if (_showList)
                      DraggableScrollableSheet(
                        initialChildSize: 0.4,
                        minChildSize: 0.2,
                        maxChildSize: 0.8,
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
                                  child: _TripsList(
                                    scrollController: scrollController,
                                    selectedTripId: _selectedTripId,
                                    onTripTap: _onTripSelected,
                                    onViewDetails: (trip) {
                                      widget.navigateTo(
                                        AppPage.tripDetails,
                                        trip: trip,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Theme.of(context).cardColor,
                        onPressed: () {
                          setState(() => _showList = !_showList);
                        },
                        child: Icon(
                          _showList ? Icons.map : Icons.list,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Desktop: Side by side
                return Row(
                  children: [
                    // Map on the left
                    Expanded(
                      flex: 2,
                      child: _RealMapView(
                        mapController: _mapController,
                        selectedTripId: _selectedTripId,
                        onMarkerTap: _onTripSelected,
                      ),
                    ),
                    // List on the right
                    Container(
                      width: 400,
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
                      child: _TripsList(
                        selectedTripId: _selectedTripId,
                        onTripTap: _onTripSelected,
                        onViewDetails: (trip) {
                          widget.navigateTo(AppPage.tripDetails, trip: trip);
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

// --- REAL MAP VIEW with OpenStreetMap ---
class _RealMapView extends StatelessWidget {
  final MapController mapController;
  final String? selectedTripId;
  final Function(String) onMarkerTap;

  const _RealMapView({
    required this.mapController,
    required this.selectedTripId,
    required this.onMarkerTap,
  });

  @override
  Widget build(BuildContext context) {
    // Create markers for all trips
    final markers = allTrips.map((trip) {
      final location = tripLocations[trip['id']];
      if (location == null) return null;
      
      final isSelected = selectedTripId == trip['id'];
      
     return Marker(
  point: location,
  width: isSelected ? 80 : 60,
  height: isSelected ? 80 : 60,
  alignment: Alignment.topCenter,
  child: GestureDetector(
    onTap: () => onMarkerTap(trip['id']),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isSelected ? 48 : 40,
          height: isSelected ? 48 : 40,
          decoration: BoxDecoration(
            color: isSelected ? accentOrange : primaryBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isSelected ? accentOrange : primaryBlue)
                    .withOpacity(0.5),
                blurRadius: isSelected ? 12 : 8,
                spreadRadius: isSelected ? 4 : 2,
              ),
            ],
          ),
          child: Icon(
            Icons.location_on,
            color: Colors.white,
            size: isSelected ? 32 : 24,
          ),
        ),

        if (isSelected) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              trip['location'],
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
    }).whereType<Marker>().toList();

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: LatLng(25.0, 50.0), // Center of the world view
        zoom: 2.5,
        minZoom: 2.0,
        maxZoom: 18.0,
        interactiveFlags: InteractiveFlag.all,
      ),
      children: [
        // OpenStreetMap tile layer (free, no API key needed!)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.travelhub.app',
          tileProvider: NetworkTileProvider(),
        ),
        
        // Markers layer
        MarkerLayer(
          markers: markers,
        ),
        
        // Map attribution (required by OpenStreetMap)
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () {}, // Can open OSM website
            ),
          ],
        ),
      ],
    );
  }
}

// --- TRIPS LIST ---
class _TripsList extends StatelessWidget {
  final String? selectedTripId;
  final Function(String) onTripTap;
  final Function(Map<String, dynamic>) onViewDetails;
  final ScrollController? scrollController;

  const _TripsList({
    required this.selectedTripId,
    required this.onTripTap,
    required this.onViewDetails,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Trip Locations',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${allTrips.length} destinations available',
          style: const TextStyle(
            fontSize: 14,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 20),
        ...allTrips.map((trip) {
          final isSelected = selectedTripId == trip['id'];
          
          return GestureDetector(
            onTap: () => onTripTap(trip['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentOrange.withOpacity(0.1)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? accentOrange : Colors.transparent,
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
              child: Row(
                children: [
                  // Trip image
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12),
                    ),
                    child: Image.network(
                      trip['image'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  // Trip info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? accentOrange : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: subtitleColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  trip['location'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: subtitleColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${trip['price']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                              TextButton(
                                onPressed: () => onViewDetails(trip),
                                style: TextButton.styleFrom(
                                  backgroundColor: accentOrange,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text(
                                  'View',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}