// lib/services/ai_location_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart'; // To access supabase client

class AILocationService {
  static const String _geminiApiKey = 'AIzaSyA7tD-K3aikHiit3CBZ7Tmip5fGK2Cv5KM';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent';
  
    static final Map<String, List<Map<String, dynamic>>> _itineraryCache = {};
  static final Map<String, List<Map<String, dynamic>>> _meetingPointsCache = {};
  
  /// Validate and clean JSON string
  static String? _extractAndValidateJson(String content) {
    try {
      // Remove markdown code blocks
      String cleaned = content.trim()
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
      
      // Find JSON array
      final jsonMatch = RegExp(r'\[[\s\S]*\]', multiLine: true).firstMatch(cleaned);
      if (jsonMatch == null) return null;
      
      String jsonStr = jsonMatch.group(0)!;
      
      // Validate by attempting to parse
      try {
        final parsed = jsonDecode(jsonStr);
        if (parsed is List) {
          return jsonStr;
        }
      } catch (e) {
        // Try to fix common JSON issues
        // Remove trailing commas
        jsonStr = jsonStr.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');
        
        // Attempt parse again
        try {
          final parsed = jsonDecode(jsonStr);
          if (parsed is List) {
            return jsonStr;
          }
        } catch (e) {
          return null;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
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

      // Make API request with increased token limit
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''Create a ${days}-day itinerary for "$tripTitle" in $location.

CRITICAL: Return ONLY a valid JSON array with NO additional text, explanations, or markdown.

Format (copy exactly):
[
  {
    "day": 1,
    "title": "Short Title",
    "description": "Brief description",
    "latitude": 0.0000,
    "longitude": 0.0000,
    "activities": ["Activity 1", "Activity 2", "Activity 3", "Activity 4"],
    "time": "9:00 AM - 6:00 PM"
  }
]

Requirements:
- Exactly $days entries
- Accurate coordinates for actual locations
- No trailing commas
- Valid JSON only'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'maxOutputTokens': 8000,
            'topP': 0.8,
            'topK': 10
          }
        }),
      );
      
      List<Map<String, dynamic>> result = [];
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          print('No candidates in response');
          return _getFallbackItinerary(location, days);
        }
        
        final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
        print('Content received (${content.length} chars)');
        
        // Extract and validate JSON
        final jsonStr = _extractAndValidateJson(content);
        
        if (jsonStr != null) {
          try {
            print('Found valid JSON');
            final itinerary = jsonDecode(jsonStr) as List;
            result = itinerary.cast<Map<String, dynamic>>();
            
            // Validate structure
            if (result.isEmpty || result.length != days) {
              print('Invalid itinerary length: ${result.length}, expected: $days');
              return _getFallbackItinerary(location, days);
            }
            
            // Validate each entry
            for (final entry in result) {
              if (!entry.containsKey('day') || 
                  !entry.containsKey('title') ||
                  !entry.containsKey('latitude') ||
                  !entry.containsKey('longitude') ||
                  !entry.containsKey('activities')) {
                print('Invalid entry structure');
                return _getFallbackItinerary(location, days);
              }
            }
            
            print('Itinerary validated successfully');
          } catch (e) {
            print('Parse error: $e');
            return _getFallbackItinerary(location, days);
          }
        } else {
          print('Could not extract valid JSON');
          return _getFallbackItinerary(location, days);
        }
      } else {
        print('API error: ${response.statusCode}');
        return _getFallbackItinerary(location, days);
      }

      // Save to Supabase
      if (result.isNotEmpty) {
        print('Saving itinerary to Supabase...');
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
            print('Error saving day ${dayData['day']}: $e');
          }
        }
        print('Itinerary saved to database');
      }
      
      _itineraryCache[cacheKey] = result;
      
      return result;
    } catch (e, stackTrace) {
      print('Fatal error in generateItinerary: $e');
      print('Stack trace: $stackTrace');
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
                  'text': '''Suggest 5 meeting points in $location for tourists.

Return ONLY valid JSON array with NO additional text:
[
  {
    "name": "Point Name",
    "description": "Brief description",
    "latitude": 0.0000,
    "longitude": 0.0000,
    "icon_type": "airport"
  }
]

icon_type options: airport, train, landmark, hotel
Accurate coordinates required.'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'maxOutputTokens': 4000,
          }
        }),
      );
      
      List<Map<String, dynamic>> result = [];
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        final jsonStr = _extractAndValidateJson(content);
        
        if (jsonStr != null) {
          try {
            final points = jsonDecode(jsonStr) as List;
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

      // Save to Supabase
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
          // Silent fail
        }
      }
      
      _meetingPointsCache[tripId] = result;
      
      return result;
    } catch (e) {
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
                  'text': '''Find 6 locations matching: "$query"

Return ONLY valid JSON array:
[
  {
    "name": "Location Name",
    "address": "Address",
    "category": "restaurant",
    "latitude": 0.0000,
    "longitude": 0.0000,
    "description": "Brief description"
  }
]

category options: restaurant, attraction, hotel, nature, transport, other'''
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'maxOutputTokens': 3000,
          }
        }),
      );
      
      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body);
      final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
      
      final jsonStr = _extractAndValidateJson(content);
      
      if (jsonStr != null) {
        final suggestions = jsonDecode(jsonStr) as List;
        final result = suggestions.cast<Map<String, dynamic>>();
        
        try {
          await supabase.from('location_suggestions').insert({
            'query': query.toLowerCase(),
            'suggestions': jsonEncode(result),
          });
        } catch (e) {
          // Silent fail
        }
        
        return result;
      }
      
      return [];
    } catch (e) {
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
    } else if (city.toLowerCase().contains('rome')) {
      baseLat = 41.9028;
      baseLng = 12.4964;
    } else if (city.toLowerCase().contains('swiss')) {
      baseLat = 46.8182;
      baseLng = 8.2275;
    }
    
    for (int i = 1; i <= days; i++) {
      result.add({
        'day': i,
        'title': 'Day $i - Explore $city',
        'description': 'Discover the highlights of $city on day $i',
        'latitude': baseLat + (i * 0.01),
        'longitude': baseLng + (i * 0.01),
        'activities': [
          'Visit main attractions',
          'Experience local cuisine',
          'Explore cultural sites',
          'Leisure and shopping'
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
  
  // Utility methods
  static Future<void> clearAllCaches() async {
    _itineraryCache.clear();
    _meetingPointsCache.clear();
  }
  
  static Future<void> cleanupExpiredSuggestions() async {
    try {
      await supabase
          .from('location_suggestions')
          .delete()
          .lt('expires_at', DateTime.now().toIso8601String());
    } catch (e) {
      // Silent fail
    }
  }
  
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
      // Silent fail
    }
    
    final cacheKey = '${tripTitle}_${location}_$days';
    _itineraryCache.remove(cacheKey);
    
    return generateItinerary(tripTitle, location, days);
  }
  
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
      // Silent fail
    }
    
    _meetingPointsCache.remove(tripId);
    
    return generateMeetingPoints(location, tripId);
  }
}