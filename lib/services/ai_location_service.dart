import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../main.dart'; 

class AILocationService {
  static final String _geminiApiKey = dotenv.env["GEMINI_API_KEY"] ?? '';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent';
  
  static final Map<String, List<Map<String, dynamic>>> _itineraryCache = {};
  static final Map<String, List<Map<String, dynamic>>> _meetingPointsCache = {};
  
  /// Generate itinerary for a trip (with Supabase persistence)
  static Future<List<Map<String, dynamic>>> generateItinerary(
    String tripTitle,
    String location,
    int days,
  ) async {
    try {
      final String tripId = tripTitle.replaceAll(' ', '_').toLowerCase();
      final cacheKey = '${tripTitle}_${location}_$days';
      if (_itineraryCache.containsKey(cacheKey)) {
        return _itineraryCache[cacheKey]!;
      }

      final existingData = await supabase
          .from('trip_itineraries')
          .select()
          .eq('trip_id', tripId)
          .order('day', ascending: true);

      if (existingData.isNotEmpty) {
        final result = (existingData as List).map((item) {
          return {
            'day': item['day'],
            'title': item['title'],
            'description': item['description'],
            'latitude': double.parse(item['latitude'].toString()),
            'longitude': double.parse(item['longitude'].toString()),
            'activities': List<String>.from(jsonDecode(item['activities'])),
            'time': item['time'],
          };
        }).toList();
        
        _itineraryCache[cacheKey] = result;
        return result;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''Create a detailed ${days}-day itinerary for "$tripTitle" in $location.

For each day, provide:
1. Day number
2. Main location/attraction title
3. Brief description
4. Specific latitude and longitude (be precise)
5. 4-5 activities for that day
6. Suggested time range

Return ONLY valid JSON array format with no extra text:
[
  {
    "day": 1,
    "title": "Day 1 Title",
    "description": "Description",
    "latitude": 0.0000,
    "longitude": 0.0000,
    "activities": ["Activity 1", "Activity 2", "Activity 3", "Activity 4"],
    "time": "9:00 AM - 6:00 PM"
  }
]

Make sure coordinates are accurate for the actual locations.'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 4000,
          }
        }),
      );
      
      List<Map<String, dynamic>> result = [];
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        String cleanContent = content.trim();
        cleanContent = cleanContent.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleanContent);
        if (jsonMatch != null) {
          try {
            final itinerary = jsonDecode(jsonMatch.group(0)!) as List;
            result = itinerary.cast<Map<String, dynamic>>();
          } catch (e) {
            result = _getFallbackItinerary(location, days);
          }
        } else {
          result = _getFallbackItinerary(location, days);
        }
      } else {
        result = _getFallbackItinerary(location, days);
      }

      for (final dayData in result) {
        try {
          await supabase.from('trip_itineraries').insert({
            'trip_id': tripId,
            'day': dayData['day'],
            'title': dayData['title'],
            'description': dayData['description'],
            'latitude': dayData['latitude'],
            'longitude': dayData['longitude'],
            'activities': jsonEncode(dayData['activities']),
            'time': dayData['time'],
          });
        } catch (e) {
          // Handle error silently or log it
        }
      }
      
      _itineraryCache[cacheKey] = result;
      
      return result;
    } catch (e, stackTrace) {
      return _getFallbackItinerary(location, days);
    }
  }

  /// Generate meeting points for a trip (with Supabase persistence)
  static Future<List<Map<String, dynamic>>> generateMeetingPoints(
    String location,
    String tripId,
  ) async {
    try {
      if (_meetingPointsCache.containsKey(tripId)) {
        return _meetingPointsCache[tripId]!;
      }

      final existingData = await supabase
          .from('meeting_points')
          .select()
          .eq('trip_id', tripId);

      if (existingData.isNotEmpty) {
        final result = (existingData as List).map((item) {
          return {
            'id': item['id'].toString(),
            'name': item['name'],
            'description': item['description'],
            'latitude': double.parse(item['latitude'].toString()),
            'longitude': double.parse(item['longitude'].toString()),
            'icon_type': item['icon_type'],
          };
        }).toList();
        
        _meetingPointsCache[tripId] = result;
        return result;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''Suggest 4-6 popular meeting points in $location for tourists.

Include:
- Airports
- Train stations
- Major landmarks
- Hotels/accommodation hubs

Return ONLY valid JSON array:
[
  {
    "name": "Point Name",
    "description": "Brief description",
    "latitude": 0.0000,
    "longitude": 0.0000,
    "icon_type": "airport"
  }
]

For icon_type use: airport, train, landmark, or hotel
Coordinates must be accurate.'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2000,
          }
        }),
      );
      
      List<Map<String, dynamic>> result = [];
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        String cleanContent = content.trim();
        cleanContent = cleanContent.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleanContent);
        if (jsonMatch != null) {
          try {
            final points = jsonDecode(jsonMatch.group(0)!) as List;
            result = points.cast<Map<String, dynamic>>();
          } catch (e) {
            result = _getFallbackMeetingPoints(location);
          }
        } else {
          result = _getFallbackMeetingPoints(location);
        }
      } else {
        result = _getFallbackMeetingPoints(location);
      }

      for (final point in result) {
        try {
          await supabase.from('meeting_points').insert({
            'trip_id': tripId,
            'name': point['name'],
            'description': point['description'],
            'latitude': point['latitude'],
            'longitude': point['longitude'],
            'icon_type': point['icon_type'],
          });
        } catch (e) {
          // Handle error silently or log it
        }
      }
      
      _meetingPointsCache[tripId] = result;
      
      return result;
    } catch (e, stackTrace) {
      return _getFallbackMeetingPoints(location);
    }
  }

  /// Search for locations with AI assistance (with Supabase caching)
  static Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    try {
      final cachedData = await supabase
          .from('location_suggestions')
          .select()
          .eq('query', query.toLowerCase())
          .gt('expires_at', DateTime.now().toIso8601String())
          .maybeSingle();

      if (cachedData != null) {
        final suggestions = List<Map<String, dynamic>>.from(
          jsonDecode(cachedData['suggestions'])
        );
        return suggestions;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''Find locations matching: "$query"

Provide 5-8 relevant results with accurate coordinates.

Return ONLY valid JSON array:
[
  {
    "name": "Location Name",
    "address": "Full Address",
    "category": "restaurant",
    "latitude": 0.0000,
    "longitude": 0.0000,
    "description": "Brief description"
  }
]

For category use: restaurant, attraction, hotel, nature, transport, or other'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1500,
          }
        }),
      );
      
      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body);
      final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
      
      String cleanContent = content.trim();
      cleanContent = cleanContent.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleanContent);
      if (jsonMatch != null) {
        final suggestions = jsonDecode(jsonMatch.group(0)!) as List;
        final result = suggestions.cast<Map<String, dynamic>>();
        
        try {
          await supabase.from('location_suggestions').insert({
            'query': query.toLowerCase(),
            'suggestions': jsonEncode(result),
          });
        } catch (e) {
        }
        
        return result;
      }
      
      return [];
    } catch (e, stackTrace) {
      return [];
    }
  }

  // Fallback itinerary when API fails
  static List<Map<String, dynamic>> _getFallbackItinerary(String location, int days) {
    final city = location.split(',').first.trim();
    final result = <Map<String, dynamic>>[];
    
    double baseLat = 0.0;
    double baseLng = 0.0;
    
    if (city.toLowerCase().contains('bali')) {
      baseLat = -8.4095;
      baseLng = 115.1889;
    } else if (city.toLowerCase().contains('paris')) {
      baseLat = 48.8566;
      baseLng = 2.3522;
    } else if (city.toLowerCase().contains('tokyo')) {
      baseLat = 35.6762;
      baseLng = 139.6503;
    } else if (city.toLowerCase().contains('new york')) {
      baseLat = 40.7128;
      baseLng = -74.0060;
    }
    
    for (int i = 1; i <= days; i++) {
      result.add({
        'day': i,
        'title': 'Day $i - Explore $city',
        'description': 'Discover the best of $city on day $i',
        'latitude': baseLat + (i * 0.01),
        'longitude': baseLng + (i * 0.01),
        'activities': [
          'Visit local attractions',
          'Try local cuisine',
          'Explore the city',
          'Shopping and leisure'
        ],
        'time': '9:00 AM - 6:00 PM'
      });
    }
    
    return result;
  }

  // Fallback meeting points when API fails
  static List<Map<String, dynamic>> _getFallbackMeetingPoints(String location) {
    final city = location.split(',').first.trim().toLowerCase();
    
    double lat = 0.0;
    double lng = 0.0;
    
    if (city.contains('bali')) {
      lat = -8.4095;
      lng = 115.1889;
    } else if (city.contains('paris')) {
      lat = 48.8566;
      lng = 2.3522;
    } else if (city.contains('tokyo')) {
      lat = 35.6762;
      lng = 139.6503;
    } else if (city.contains('new york')) {
      lat = 40.7128;
      lng = -74.0060;
    } else if (city.contains('dubai')) {
      lat = 25.2048;
      lng = 55.2708;
    }
    
    return [
      {
        'name': '$location International Airport',
        'description': 'Main international airport',
        'latitude': lat + 0.05,
        'longitude': lng + 0.05,
        'icon_type': 'airport'
      },
      {
        'name': '$location Central Station',
        'description': 'Main train station',
        'latitude': lat - 0.02,
        'longitude': lng + 0.02,
        'icon_type': 'train'
      },
      {
        'name': 'City Center',
        'description': 'Downtown area',
        'latitude': lat,
        'longitude': lng,
        'icon_type': 'landmark'
      },
      {
        'name': 'Main Hotel District',
        'description': 'Popular hotel area',
        'latitude': lat + 0.01,
        'longitude': lng - 0.01,
        'icon_type': 'hotel'
      },
    ];
  }
  
  /// Clear all caches (useful for testing or refreshing data)
  static Future<void> clearAllCaches() async {
    _itineraryCache.clear();
    _meetingPointsCache.clear();
  }
  
  /// Delete expired location suggestions (run periodically)
  static Future<void> cleanupExpiredSuggestions() async {
    try {
      await supabase
          .from('location_suggestions')
          .delete()
          .lt('expires_at', DateTime.now().toIso8601String());
    } catch (e) {
    }
  }
  
  /// Regenerate itinerary (force refresh)
  static Future<List<Map<String, dynamic>>> regenerateItinerary(
    String tripTitle,
    String location,
    int days,
  ) async {
    final String tripId = tripTitle.replaceAll(' ', '_').toLowerCase();
    
    try {
      await supabase
          .from('trip_itineraries')
          .delete()
          .eq('trip_id', tripId);
    } catch (e) {
    }
    
    final cacheKey = '${tripTitle}_${location}_$days';
    _itineraryCache.remove(cacheKey);
    
    return generateItinerary(tripTitle, location, days);
  }
  
  /// Regenerate meeting points (force refresh)
  static Future<List<Map<String, dynamic>>> regenerateMeetingPoints(
    String location,
    String tripId,
  ) async {
    try {
      await supabase
          .from('meeting_points')
          .delete()
          .eq('trip_id', tripId);
    } catch (e) {
    }
    
    _meetingPointsCache.remove(tripId);
    
    return generateMeetingPoints(location, tripId);
  }
}