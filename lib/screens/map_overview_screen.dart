// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/config.dart';
import '../widgets/custom_app_bar.dart';
import '../services/trips_service.dart';
import '../services/ai_location_service.dart';

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
  List<Map<String, dynamic>> _trips = [];
  Map<String, Map<String, double>> _tripCoordinates = {};
  bool _isLoading = true;
  bool _isLoadingCoordinates = true;

  @override
  void initState() {
    super.initState();
    _loadTripsAndCoordinates();
  }

  Future<void> _loadTripsAndCoordinates() async {
    setState(() {
      _isLoading = true;
      _isLoadingCoordinates = true;
    });

    try {
      // Load trips first
      final trips = await TripsService.getAllTrips();
      setState(() {
        _trips = trips;
        _isLoading = false;
      });

      // Load coordinates dynamically using Gemini AI
      final coordinates = await AILocationService.getBatchTripCoordinates(trips);
      
      setState(() {
        _tripCoordinates = coordinates;
        _isLoadingCoordinates = false;
      });
    } catch (e) {
      setState(() {
        _trips = fallbackTrips;
        _isLoading = false;
        _isLoadingCoordinates = false;
      });
      
      // Load coordinates for fallback trips too
      try {
        final coordinates = await AILocationService.getBatchTripCoordinates(fallbackTrips);
        setState(() {
          _tripCoordinates = coordinates;
        });
      } catch (e) {
        // If all fails, use empty map
        setState(() {
          _tripCoordinates = {};
        });
      }
    }
  }

  void _onTripSelected(String tripId) {
    setState(() {
      _selectedTripId = tripId;
    });
    
    final location = _tripCoordinates[tripId];
    if (location != null) {
      _mapController.move(
        LatLng(location['latitude']!, location['longitude']!),
        8.0,
      );
    }
  }

  Future<void> _refreshData() async {
    await _loadTripsAndCoordinates();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Map refreshed successfully'),
          backgroundColor: successGreen,
          duration: Duration(seconds: 2),
        ),
      );
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
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading trips...'),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 900;
                    
                    if (isMobile) {
                      return Stack(
                        children: [
                          _RealMapView(
                            mapController: _mapController,
                            selectedTripId: _selectedTripId,
                            onMarkerTap: _onTripSelected,
                            trips: _trips,
                            tripCoordinates: _tripCoordinates,
                            isLoadingCoordinates: _isLoadingCoordinates,
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
                                          trips: _trips,
                                          tripCoordinates: _tripCoordinates,
                                          isLoadingCoordinates: _isLoadingCoordinates,
                                          onViewDetails: (trip) {
                                            widget.navigateTo(
                                              AppPage.tripDetails,
                                              trip: trip,
                                            );
                                          },
                                          onRefresh: _refreshData,
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
                            child: Column(
                              children: [
                                FloatingActionButton(
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
                                const SizedBox(height: 8),
                                FloatingActionButton(
                                  mini: true,
                                  backgroundColor: Theme.of(context).cardColor,
                                  onPressed: _refreshData,
                                  child: const Icon(
                                    Icons.refresh,
                                    color: primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _RealMapView(
                              mapController: _mapController,
                              selectedTripId: _selectedTripId,
                              onMarkerTap: _onTripSelected,
                              trips: _trips,
                              tripCoordinates: _tripCoordinates,
                              isLoadingCoordinates: _isLoadingCoordinates,
                            ),
                          ),
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
                              trips: _trips,
                              tripCoordinates: _tripCoordinates,
                              isLoadingCoordinates: _isLoadingCoordinates,
                              onViewDetails: (trip) {
                                widget.navigateTo(AppPage.tripDetails, trip: trip);
                              },
                              onRefresh: _refreshData,
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

class _RealMapView extends StatelessWidget {
  final MapController mapController;
  final String? selectedTripId;
  final Function(String) onMarkerTap;
  final List<Map<String, dynamic>> trips;
  final Map<String, Map<String, double>> tripCoordinates;
  final bool isLoadingCoordinates;

  const _RealMapView({
    required this.mapController,
    required this.selectedTripId,
    required this.onMarkerTap,
    required this.trips,
    required this.tripCoordinates,
    required this.isLoadingCoordinates,
  });

  @override
  Widget build(BuildContext context) {
    final markers = trips.where((trip) {
      // Only show trips with loaded coordinates
      return tripCoordinates.containsKey(trip['id']);
    }).map((trip) {
      final coords = tripCoordinates[trip['id']]!;
      final location = LatLng(coords['latitude']!, coords['longitude']!);
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
                    trip['location'].split(',').first,
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

    // Calculate initial center based on available coordinates
    LatLng initialCenter = LatLng(20.0, 0.0);
    if (tripCoordinates.isNotEmpty) {
      final firstCoords = tripCoordinates.values.first;
      initialCenter = LatLng(firstCoords['latitude']!, firstCoords['longitude']!);
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 2.0,
            minZoom: 1.5,
            maxZoom: 18.0,
            interactiveFlags: InteractiveFlag.all,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.travelhub.app',
              tileProvider: NetworkTileProvider(),
            ),
            MarkerLayer(markers: markers),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors', onTap: () {}),
              ],
            ),
          ],
        ),
        if (isLoadingCoordinates)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Loading locations...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TripsList extends StatelessWidget {
  final String? selectedTripId;
  final Function(String) onTripTap;
  final Function(Map<String, dynamic>) onViewDetails;
  final ScrollController? scrollController;
  final List<Map<String, dynamic>> trips;
  final Map<String, Map<String, double>> tripCoordinates;
  final bool isLoadingCoordinates;
  final Future<void> Function() onRefresh;

  const _TripsList({
    required this.selectedTripId,
    required this.onTripTap,
    required this.onViewDetails,
    required this.trips,
    required this.tripCoordinates,
    required this.isLoadingCoordinates,
    required this.onRefresh,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trip Locations',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${trips.length} destinations available',
                    style: const TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                  if (isLoadingCoordinates) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Loading coordinates...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.map,
                  color: accentOrange,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...trips.map((trip) {
            final isSelected = selectedTripId == trip['id'];
            final hasCoordinates = tripCoordinates.containsKey(trip['id']);
            
            return GestureDetector(
              onTap: hasCoordinates ? () => onTripTap(trip['id']) : null,
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
                                Icon(
                                  hasCoordinates ? Icons.location_on : Icons.location_off,
                                  size: 14,
                                  color: hasCoordinates ? subtitleColor : Colors.grey,
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
      ),
    );
  }
}