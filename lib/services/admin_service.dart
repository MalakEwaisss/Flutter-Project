import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/trip_model.dart';
import '../main.dart';

class AdminService {
  final SupabaseClient _supabase = supabase;

  // ============================================================================
  // USER CRUD OPERATIONS
  // ============================================================================

  /// Fetch all users from auth.users and profiles
  Future<List<UserProfile>> fetchAllUsers() async {
    try {
      // Fetch from profiles table
      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserProfile.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Create a new user with email and password
  Future<UserProfile> createUser({
    required String email,
    required String password,
    required String name,
    String? bio,
    String? avatar,
  }) async {
    try {
      // Create user in Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }

      final userId = authResponse.user!.id;

      // Create profile in profiles table
      final profileData = {
        'id': userId,
        'name': name,
        'email': email,
        'bio': bio,
        'avatar': avatar,
      };

      await _supabase.from('profiles').insert(profileData);

      return UserProfile(
        id: userId,
        name: name,
        email: email,
        bio: bio,
        avatar: avatar,
        createdAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      // Handle specific auth errors
      if (e.message.contains('already registered') ||
          e.message.contains('user_already_exists')) {
        throw Exception(
          'A user with this email already exists. Please use a different email address.',
        );
      }
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Update user profile information
  Future<void> updateUser({
    required String userId,
    String? name,
    String? email,
    String? bio,
    String? avatar,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (bio != null) updates['bio'] = bio;
      if (avatar != null) updates['avatar'] = avatar;

      if (updates.isEmpty) return;

      await _supabase.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Delete a user (from auth and profile)
  Future<void> deleteUser(String userId) async {
    try {
      // Delete from profiles (cascade will handle this if FK is set)
      await _supabase.from('profiles').delete().eq('id', userId);

      // Note: Deleting from auth.users requires service role key
      // For now, we only delete the profile. To fully delete auth user,
      // you'd need to use Supabase Admin API with service role key
      // or implement a backend endpoint
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // ============================================================================
  // TRIP CRUD OPERATIONS
  // ============================================================================

  /// Fetch all trips from the database
  Future<List<TripModel>> fetchAllTrips() async {
    try {
      final response = await _supabase
          .from('trips')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TripModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch trips: $e');
    }
  }

  /// Create a new trip
  Future<TripModel> createTrip(TripModel trip) async {
    try {
      // Validate trip data
      final validationError = trip.validate();
      if (validationError != null) {
        throw Exception(validationError);
      }

      final response = await _supabase
          .from('trips')
          .insert(trip.toJson())
          .select()
          .single();

      return TripModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create trip: $e');
    }
  }

  /// Update an existing trip
  Future<void> updateTrip(String tripId, TripModel trip) async {
    try {
      // Validate trip data
      final validationError = trip.validate();
      if (validationError != null) {
        throw Exception(validationError);
      }

      await _supabase.from('trips').update(trip.toJson()).eq('id', tripId);
    } catch (e) {
      throw Exception('Failed to update trip: $e');
    }
  }

  /// Delete a trip
  Future<void> deleteTrip(String tripId) async {
    try {
      await _supabase.from('trips').delete().eq('id', tripId);
    } catch (e) {
      throw Exception('Failed to delete trip: $e');
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if current user is admin
  bool isAdmin(String email) {
    return email.toLowerCase() == 'admin@travilo.app';
  }

  /// Get current authenticated user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}
