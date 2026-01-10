// lib/screens/map/map_overview_screen_refactored.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../config/config.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/map_state_provider.dart';

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
  final MapController _mapController = MapController();
  bool _showList = true;

  @override
  void initState() {
    super.initState();
    // Load data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapStateProvider>().loadTripsAndCoordinates();
    });
  }

  void _onTripSelected(String tripId) {
    final provider = context.read<MapStateProvider>();
    provider.selectTrip(tripId);
    
    // Animate map to new position
    if (provider.selectedTripId != null) {
      _mapController.move(provider.mapCenter, provider.mapZoom);
    }
  }

  Future<void> _refreshData() async {
    await context.read<MapStateProvider>().refresh();
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
          child: Consumer<MapStateProvider>(
            builder: (context, mapProvider, child) {
              // Loading state
              if (mapProvider.loadingState == MapLoadingState.loadingTrips) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading trips...'),
                    ],
                  ),
                );
              }

              // Error state
              if (mapProvider.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${mapProvider.errorMessage}'),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => mapProvider.loadTripsAndCoordinates(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Main layout
              return LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 900;
                  
                  if (isMobile) {
                    return _buildMobileLayout(mapProvider);
                  } else {
                    return _buildDesktopLayout(mapProvider);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(MapStateProvider mapProvider) {
    return Stack(
      children: [
        _RealMapView(
          mapController: _mapController,
          mapProvider: mapProvider,
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
                        mapProvider: mapProvider,
                        onTripTap: _onTripSelected,
                        onViewDetails: (trip) {
                          widget.navigateTo(AppPage.tripDetails, trip: trip);
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
  }

  Widget _buildDesktopLayout(MapStateProvider mapProvider) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _RealMapView(
            mapController: _mapController,
            mapProvider: mapProvider,
            onMarkerTap: _onTripSelected,
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
            mapProvider: mapProvider,
            onTripTap: _onTripSelected,
            onViewDetails: (trip) {
              widget.navigateTo(AppPage.tripDetails, trip: trip);
            },
            onRefresh: _refreshData,
          ),
        ),
      ],
    );
  }
}

class _RealMapView extends StatelessWidget {
  final MapController mapController;
  final MapStateProvider mapProvider;
  final Function(String) onMarkerTap;

  const _RealMapView({
    required this.mapController,
    required this.mapProvider,
    required this.onMarkerTap,
  });

  @override
  Widget build(BuildContext context) {
    final markers = mapProvider.tripsWithCoordinates.map((trip) {
      final coords = mapProvider.tripCoordinates[trip['id']]!;
      final location = LatLng(coords['latitude']!, coords['longitude']!);
      final isSelected = mapProvider.selectedTripId == trip['id'];
      
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

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: mapProvider.mapCenter,
            initialZoom: mapProvider.mapZoom,
            minZoom: 1.5,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all, // All interactions enabled
              ),          
              ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.travelhub.app',
            ),
            MarkerLayer(markers: markers),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors', onTap: () {}),
              ],
            ),
          ],
        ),
        if (mapProvider.loadingState == MapLoadingState.loadingCoordinates)
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
                  Text(
                    'Loading ${mapProvider.loadedCoordinatesCount}/${mapProvider.trips.length} locations...',
                    style: const TextStyle(
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
  final MapStateProvider mapProvider;
  final Function(String) onTripTap;
  final Function(Map<String, dynamic>) onViewDetails;
  final ScrollController? scrollController;
  final Future<void> Function() onRefresh;

  const _TripsList({
    required this.mapProvider,
    required this.onTripTap,
    required this.onViewDetails,
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
                    '${mapProvider.trips.length} destinations',
                    style: const TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
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
          ...mapProvider.trips.map((trip) {
            final isSelected = mapProvider.selectedTripId == trip['id'];
            final hasCoordinates = mapProvider.tripCoordinates.containsKey(trip['id']);
            
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