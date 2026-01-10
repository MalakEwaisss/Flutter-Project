// lib/providers/map_state_provider.dart
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../services/trips_service.dart';
import '../services/ai_location_service.dart';

enum MapLoadingState {
  idle,
  loadingTrips,
  loadingCoordinates,
  loaded,
  error,
}

class MapStateProvider with ChangeNotifier {
  // State
  List<Map<String, dynamic>> _trips = [];
  Map<String, Map<String, double>> _tripCoordinates = {};
  String? _selectedTripId;
  MapLoadingState _loadingState = MapLoadingState.idle;
  String? _errorMessage;
  LatLng _mapCenter = LatLng(20.0, 0.0);
  double _mapZoom = 2.0;

  // Getters
  List<Map<String, dynamic>> get trips => _trips;
  Map<String, Map<String, double>> get tripCoordinates => _tripCoordinates;
  String? get selectedTripId => _selectedTripId;
  MapLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  LatLng get mapCenter => _mapCenter;
  double get mapZoom => _mapZoom;
  
  bool get isLoading => 
      _loadingState == MapLoadingState.loadingTrips || 
      _loadingState == MapLoadingState.loadingCoordinates;
  
  bool get hasError => _loadingState == MapLoadingState.error;
  
  int get loadedCoordinatesCount => _tripCoordinates.length;

  // Load trips and their coordinates
  Future<void> loadTripsAndCoordinates() async {
    _loadingState = MapLoadingState.loadingTrips;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load trips first
      _trips = await TripsService.getAllTrips();
      _loadingState = MapLoadingState.loadingCoordinates;
      notifyListeners();

      // Load coordinates in batches for better UX
      _tripCoordinates = await AILocationService.getBatchTripCoordinates(_trips);
      
      // Set initial map center to first trip if available
      if (_tripCoordinates.isNotEmpty) {
        final firstCoords = _tripCoordinates.values.first;
        _mapCenter = LatLng(firstCoords['latitude']!, firstCoords['longitude']!);
      }

      _loadingState = MapLoadingState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _loadingState = MapLoadingState.error;
    }
    
    notifyListeners();
  }

  // Select a trip and update map position
  void selectTrip(String tripId) {
    _selectedTripId = _selectedTripId == tripId ? null : tripId;
    
    if (_selectedTripId != null && _tripCoordinates.containsKey(tripId)) {
      final coords = _tripCoordinates[tripId]!;
      _mapCenter = LatLng(coords['latitude']!, coords['longitude']!);
      _mapZoom = 8.0;
    }
    
    notifyListeners();
  }

  // Update map position manually
  void updateMapPosition(LatLng center, double zoom) {
    _mapCenter = center;
    _mapZoom = zoom;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    _tripCoordinates.clear();
    _selectedTripId = null;
    await loadTripsAndCoordinates();
  }

  // Clear selection
  void clearSelection() {
    _selectedTripId = null;
    notifyListeners();
  }

  // Get trip by ID
  Map<String, dynamic>? getTripById(String id) {
    try {
      return _trips.firstWhere((trip) => trip['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get trips with loaded coordinates
  List<Map<String, dynamic>> get tripsWithCoordinates {
    return _trips.where((trip) => _tripCoordinates.containsKey(trip['id'])).toList();
  }

  // Clear all data
  void clear() {
    _trips.clear();
    _tripCoordinates.clear();
    _selectedTripId = null;
    _loadingState = MapLoadingState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}