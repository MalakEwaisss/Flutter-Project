import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/trip_model.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  // State variables
  List<UserProfile> _users = [];
  List<TripModel> _trips = [];
  bool _isLoadingUsers = false;
  bool _isLoadingTrips = false;
  String? _errorMessage;

  // Getters
  List<UserProfile> get users => _users;
  List<TripModel> get trips => _trips;
  bool get isLoadingUsers => _isLoadingUsers;
  bool get isLoadingTrips => _isLoadingTrips;
  String? get errorMessage => _errorMessage;

  // ============================================================================
  // USER MANAGEMENT
  // ============================================================================

  /// Fetch all users
  Future<void> fetchUsers() async {
    _isLoadingUsers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _adminService.fetchAllUsers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  /// Create a new user
  Future<bool> createUser({
    required String email,
    required String password,
    required String name,
    String? bio,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final newUser = await _adminService.createUser(
        email: email,
        password: password,
        name: name,
        bio: bio,
      );
      _users.insert(0, newUser);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update an existing user
  Future<bool> updateUser({
    required String userId,
    String? name,
    String? email,
    String? bio,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminService.updateUser(
        userId: userId,
        name: name,
        email: email,
        bio: bio,
      );

      // Update local state
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          name: name,
          email: email,
          bio: bio,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a user
  Future<bool> deleteUser(String userId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminService.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // TRIP MANAGEMENT
  // ============================================================================

  /// Fetch all trips
  Future<void> fetchTrips() async {
    _isLoadingTrips = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trips = await _adminService.fetchAllTrips();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingTrips = false;
      notifyListeners();
    }
  }

  /// Create a new trip
  Future<bool> createTrip(TripModel trip) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final newTrip = await _adminService.createTrip(trip);
      _trips.insert(0, newTrip);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update an existing trip
  Future<bool> updateTrip(String tripId, TripModel trip) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminService.updateTrip(tripId, trip);

      // Update local state
      final index = _trips.indexWhere((t) => t.id == tripId);
      if (index != -1) {
        _trips[index] = trip;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a trip
  Future<bool> deleteTrip(String tripId) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminService.deleteTrip(tripId);
      _trips.removeWhere((t) => t.id == tripId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([fetchUsers(), fetchTrips()]);
  }
}
