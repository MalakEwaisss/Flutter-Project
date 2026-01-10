// lib/screens/SelectMeetingPointScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/meeting_point.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/config.dart';
import '../../services/ai_location_service.dart';


class SelectMeetingPointScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;

  const SelectMeetingPointScreen({
    super.key,
    required this.trip,
    required this.navigateTo,
  });

  @override
  State<SelectMeetingPointScreen> createState() =>
      _SelectMeetingPointScreenState();
}

class _SelectMeetingPointScreenState extends State<SelectMeetingPointScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _selectedLocation;
  String? _selectedLocationName;
  bool _isCustomLocation = false;

  List<MeetingPoint> _popularMeetingPoints = [];
  List<MeetingPoint> _filteredPoints = [];
  bool _isLoading = true;

  bool get _isFromBooking => widget.trip['_fromBooking'] == true;

  @override
  void initState() {
    super.initState();
    _loadMeetingPoints();
  }

  Future<void> _loadMeetingPoints() async {
    setState(() => _isLoading = true);

    try {
      final points = await AILocationService.generateMeetingPoints(
        widget.trip['location'],
        widget.trip['id'],
      );

      setState(() {
        _popularMeetingPoints = points
            .map((p) => MeetingPoint.fromJson(p))
            .toList();
        _filteredPoints = _popularMeetingPoints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading meeting points: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng location) {
    setState(() {
      _selectedLocation = location;
      _selectedLocationName = 'Custom Location';
      _isCustomLocation = true;
    });
    _mapController.move(location, _mapController.camera.zoom);
  }

  void _selectPredefinedPoint(MeetingPoint point) {
    setState(() {
      _selectedLocation = point.location;
      _selectedLocationName = point.name;
      _isCustomLocation = false;
    });
    _mapController.move(point.location, 14.0);
  }

  void _searchMeetingPoints(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPoints = _popularMeetingPoints;
      } else {
        _filteredPoints = _popularMeetingPoints
            .where((point) =>
                point.name.toLowerCase().contains(query.toLowerCase()) ||
                point.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _confirmMeetingPoint() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a meeting point'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meeting point set: $_selectedLocationName'),
        backgroundColor: successGreen,
      ),
    );

    if (_isFromBooking) {
      final tripWithMeetingPoint = Map<String, dynamic>.from(widget.trip);
      tripWithMeetingPoint['_selectedMeetingPoint'] = _selectedLocationName;
      tripWithMeetingPoint.remove('_fromBooking');
      widget.navigateTo(AppPage.booking, trip: tripWithMeetingPoint);
    } else {
      widget.navigateTo(AppPage.tripDetails, trip: widget.trip);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Meeting Point'),
        backgroundColor: primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_isFromBooking) {
              widget.navigateTo(AppPage.booking, trip: widget.trip);
            } else {
              widget.navigateTo(AppPage.tripDetails, trip: widget.trip);
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 900;
                return isMobile
                    ? _buildMobileLayout()
                    : _buildDesktopLayout();
              },
            ),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        _buildMap(),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildSearchBar(),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.35,
          minChildSize: 0.2,
          maxChildSize: 0.7,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
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
                  Expanded(child: _buildMeetingPointsList(scrollController)),
                  _buildConfirmButton(),
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
        Expanded(flex: 2, child: _buildMap()),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildSearchBar(),
              ),
              Expanded(child: _buildMeetingPointsList(null)),
              _buildConfirmButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    final center = _popularMeetingPoints.isNotEmpty
        ? _popularMeetingPoints.first.location
        : LatLng(0, 0);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 12.0,
        minZoom: 3.0,
        maxZoom: 18.0,
        onTap: _onMapTap,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.travelhub.app',
        ),
        MarkerLayer(
          markers: [
            ..._popularMeetingPoints.map((point) {
              final isSelected = _selectedLocation == point.location;
              return Marker(
                point: point.location,
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () => _selectPredefinedPoint(point),
                  child: Column(
                    children: [
                      Container(
                        width: isSelected ? 44 : 36,
                        height: isSelected ? 44 : 36,
                        decoration: BoxDecoration(
                          color: isSelected ? accentOrange : primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          point.icon,
                          color: Colors.white,
                          size: isSelected ? 24 : 20,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (_selectedLocation != null && _isCustomLocation)
              Marker(
                point: _selectedLocation!,
                width: 60,
                height: 60,
                child: const Icon(Icons.place, color: accentOrange, size: 50),
              ),
          ],
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors', onTap: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _searchMeetingPoints,
        decoration: InputDecoration(
          hintText: 'Search meeting points...',
          prefixIcon: const Icon(Icons.search, color: primaryBlue),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchMeetingPoints('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildMeetingPointsList(ScrollController? scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Popular Meeting Points',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap a location or tap anywhere on the map',
          style: TextStyle(fontSize: 14, color: subtitleColor),
        ),
        const SizedBox(height: 16),
        if (_filteredPoints.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No meeting points found',
                style: TextStyle(color: subtitleColor),
              ),
            ),
          )
        else
          ..._filteredPoints.map((point) {
            final isSelected = _selectedLocation == point.location;

            return GestureDetector(
              onTap: () => _selectPredefinedPoint(point),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentOrange.withOpacity(0.1)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? accentOrange : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? accentOrange : primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(point.icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            point.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? accentOrange : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            point.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: accentOrange,
                        size: 28,
                      ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 16),
        if (_selectedLocation != null && _isCustomLocation)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentOrange, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.place, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Custom Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: accentOrange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, '
                        'Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: accentOrange, size: 28),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_selectedLocation != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: successGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Selected: $_selectedLocationName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: successGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _confirmMeetingPoint,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _selectedLocation != null ? accentOrange : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirm Meeting Point',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}