import '../main.dart';

class TripsService {
  // Cache for trips data
  static List<Map<String, dynamic>>? _cachedTrips;
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Fetch all trips from Supabase
  static Future<List<Map<String, dynamic>>> getAllTrips() async {
    try {
      // Check cache first
      if (_cachedTrips != null && _lastFetchTime != null) {
        final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
        if (timeSinceLastFetch < _cacheDuration) {
          return _cachedTrips!;
        }
      }

      final response = await supabase
          .from('trips')
          .select()
          .order('created_at', ascending: false);

      final trips = List<Map<String, dynamic>>.from(response);
      
      // Update cache
      _cachedTrips = trips;
      _lastFetchTime = DateTime.now();
      
      return trips;
    } catch (e) {
      // Return cached data if available, otherwise empty list
      if (_cachedTrips != null) {
        return _cachedTrips!;
      }
      throw Exception('Failed to load trips: $e');
    }
  }

  /// Get a single trip by ID
  static Future<Map<String, dynamic>?> getTripById(String id) async {
    try {
      final response = await supabase
          .from('trips')
          .select()
          .eq('id', id)
          .maybeSingle();

      return response;
    } catch (e) {
      // Try to find in cache
      if (_cachedTrips != null) {
        try {
          return _cachedTrips!.firstWhere((trip) => trip['id'] == id);
        } catch (_) {
          return null;
        }
      }
      return null;
    }
  }

  /// Search trips by title or location
  static Future<List<Map<String, dynamic>>> searchTrips(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllTrips();
      }

      final response = await supabase
          .from('trips')
          .select()
          .or('title.ilike.%$query%,location.ilike.%$query%')
          .order('rating', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback to cached data with local filtering
      if (_cachedTrips != null) {
        final lowerQuery = query.toLowerCase();
        return _cachedTrips!.where((trip) {
          final title = trip['title']?.toString().toLowerCase() ?? '';
          final location = trip['location']?.toString().toLowerCase() ?? '';
          return title.contains(lowerQuery) || location.contains(lowerQuery);
        }).toList();
      }
      throw Exception('Failed to search trips: $e');
    }
  }

  /// Filter trips by price range
  static Future<List<Map<String, dynamic>>> filterTripsByPrice({
    required double minPrice,
    required double maxPrice,
  }) async {
    try {
      final response = await supabase
          .from('trips')
          .select()
          .gte('price', minPrice.toInt())
          .lte('price', maxPrice.toInt())
          .order('price', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback to cached data with local filtering
      if (_cachedTrips != null) {
        return _cachedTrips!.where((trip) {
          final price = trip['price'] as int?;
          return price != null && price >= minPrice && price <= maxPrice;
        }).toList();
      }
      throw Exception('Failed to filter trips: $e');
    }
  }

  /// Get featured/popular trips (top rated)
  static Future<List<Map<String, dynamic>>> getFeaturedTrips({int limit = 4}) async {
    try {
      final response = await supabase
          .from('trips')
          .select()
          .order('rating', ascending: false)
          .order('reviews', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback to cached data
      if (_cachedTrips != null) {
        final sorted = List<Map<String, dynamic>>.from(_cachedTrips!);
        sorted.sort((a, b) {
          final ratingCompare = (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0);
          if (ratingCompare != 0) return ratingCompare;
          return (b['reviews'] ?? 0).compareTo(a['reviews'] ?? 0);
        });
        return sorted.take(limit).toList();
      }
      throw Exception('Failed to load featured trips: $e');
    }
  }

  /// Clear the cache (useful for testing or force refresh)
  static void clearCache() {
    _cachedTrips = null;
    _lastFetchTime = null;
  }

  /// Force refresh trips from database
  static Future<List<Map<String, dynamic>>> refreshTrips() async {
    clearCache();
    return await getAllTrips();
  }
}