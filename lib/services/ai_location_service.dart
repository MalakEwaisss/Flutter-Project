// lib/services/ai_location_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AILocationService {
  // FIXED: Using gemini-2.5-flash which is available and stable
  static const String _geminiApiKey = 'AIzaSyDCn7RWZpe1pJvtEuo7Emtj8axM2SeHcyw';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent';
  
  // In-memory cache for generated data
  static final Map<String, List<Map<String, dynamic>>> _itineraryCache = {};
  static final Map<String, List<Map<String, dynamic>>> _meetingPointsCache = {};
  static final Map<String, List<Map<String, dynamic>>> _locationCache = {};
  
  // Generate itinerary for a trip
  static Future<List<Map<String, dynamic>>> generateItinerary(
    String tripTitle,
    String location,
    int days,
  ) async {
    try {
      final cacheKey = '${tripTitle}_${location}_$days';
      print('🔍 Generating itinerary for: $tripTitle in $location ($days days)');
      
      // Check cache first
      if (_itineraryCache.containsKey(cacheKey)) {
        print('✅ Found itinerary in cache');
        return _itineraryCache[cacheKey]!;
      }

      print('📡 Making API call to Gemini...');
      
      // FIXED: Removed the v1beta from URL and using correct endpoint
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_geminiApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
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

      print('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('❌ API Error: ${response.body}');
        throw Exception('API returned status ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
      print('📝 Content received (${content.length} chars)');
      
      // Parse JSON from response
      String cleanContent = content.trim();
      cleanContent = cleanContent.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleanContent);
      if (jsonMatch != null) {
        try {
          print('✅ Found JSON in response');
          final itinerary = jsonDecode(jsonMatch.group(0)!) as List;
          final result = itinerary.cast<Map<String, dynamic>>();
          
          print('📊 Generated ${result.length} days');
          
          // Store in cache
          _itineraryCache[cacheKey] = result;
          
          print('✅ Successfully cached itinerary');
          return result;
        } catch (e) {
          print('❌ JSON parse error: $e');
          print('Problematic JSON: ${jsonMatch.group(0)}');
        }
      }
      
      print('⚠️ No valid JSON found, returning fallback itinerary');
      final fallbackData = _getFallbackItinerary(location, days);
      _itineraryCache[cacheKey] = fallbackData;
      return fallbackData;
    } catch (e, stackTrace) {
      print('❌ Error generating itinerary: $e');
      print('Stack trace: $stackTrace');
      
      // Return fallback itinerary instead of empty array
      return _getFallbackItinerary(location, days);
    }
  }

  // Fallback itinerary when API fails
  static List<Map<String, dynamic>> _getFallbackItinerary(String location, int days) {
    final city = location.split(',').first.trim();
    final result = <Map<String, dynamic>>[];
    
    // Base coordinates for the location
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

  // Generate meeting points for a trip
  static Future<List<Map<String, dynamic>>> generateMeetingPoints(
    String location,
    String tripId,
  ) async {
    try {
      print('🔍 Generating meeting points for: $location');
      
      // Check cache first
      if (_meetingPointsCache.containsKey(tripId)) {
        print('✅ Found meeting points in cache');
        return _meetingPointsCache[tripId]!;
      }

      print('📡 Making API call to Gemini...');
      
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_geminiApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
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

      print('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('❌ API Error: ${response.body}');
        throw Exception('API returned status ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
      print('📝 Raw content: $content');
      
      String cleanContent = content.trim();
      cleanContent = cleanContent.replaceAll('```json', '').replaceAll('```', '').trim();
      
      // Try multiple JSON extraction patterns
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleanContent);
      if (jsonMatch != null) {
        try {
          print('✅ Found JSON in response');
          final points = jsonDecode(jsonMatch.group(0)!) as List;
          final result = points.cast<Map<String, dynamic>>();
          
          print('📊 Generated ${result.length} meeting points');
          
          // Add IDs to each point
          for (int i = 0; i < result.length; i++) {
            result[i]['id'] = '${tripId}_mp_$i';
          }
          
          // Store in cache
          _meetingPointsCache[tripId] = result;
          
          print('✅ Successfully cached meeting points');
          return result;
        } catch (e) {
          print('❌ JSON parse error: $e');
          print('Problematic JSON: ${jsonMatch.group(0)}');
        }
      }
      
      // If no JSON found, return default fallback data
      print('⚠️ No valid JSON found, returning fallback data');
      final fallbackData = _getFallbackMeetingPoints(location);
      _meetingPointsCache[tripId] = fallbackData;
      return fallbackData;
    } catch (e, stackTrace) {
      print('❌ Error generating meeting points: $e');
      print('Stack trace: $stackTrace');
      
      // Return fallback data instead of empty array
      return _getFallbackMeetingPoints(location);
    }
  }

  // Fallback meeting points when API fails
  static List<Map<String, dynamic>> _getFallbackMeetingPoints(String location) {
    // Extract city name from location
    final city = location.split(',').first.trim().toLowerCase();
    
    // Default coordinates (will be overridden for known cities)
    double lat = 0.0;
    double lng = 0.0;
    
    // Known city coordinates
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
    } else if (city.contains('london')) {
      lat = 51.5074;
      lng = -0.1278;
    } else if (city.contains('dubai')) {
      lat = 25.2048;
      lng = 55.2708;
    }
    
    return [
      {
        'id': 'mp_1',
        'name': '$location International Airport',
        'description': 'Main international airport',
        'latitude': lat + 0.05,
        'longitude': lng + 0.05,
        'icon_type': 'airport'
      },
      {
        'id': 'mp_2',
        'name': '$location Central Station',
        'description': 'Main train station',
        'latitude': lat - 0.02,
        'longitude': lng + 0.02,
        'icon_type': 'train'
      },
      {
        'id': 'mp_3',
        'name': 'City Center',
        'description': 'Downtown area',
        'latitude': lat,
        'longitude': lng,
        'icon_type': 'landmark'
      },
      {
        'id': 'mp_4',
        'name': 'Main Hotel District',
        'description': 'Popular hotel area',
        'latitude': lat + 0.01,
        'longitude': lng - 0.01,
        'icon_type': 'hotel'
      },
    ];
  }

  // Search for locations with AI assistance
  static Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    try {
      print('🔍 Searching for: $query');
      
      // Check cache first
      if (_locationCache.containsKey(query.toLowerCase())) {
        print('✅ Found cached results');
        return _locationCache[query.toLowerCase()]!;
      }

      print('📡 Making API call to Gemini...');
      
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_geminiApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
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

      print('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('❌ API Error: ${response.body}');
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
        
        print('✅ Found ${result.length} locations');
        
        // Cache the results
        _locationCache[query.toLowerCase()] = result;
        
        return result;
      }
      
      return [];
    } catch (e, stackTrace) {
      print('❌ Error searching locations: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
  
  // Clear all caches (useful for testing)
  static void clearCache() {
    _itineraryCache.clear();
    _meetingPointsCache.clear();
    _locationCache.clear();
    print('🗑️ All caches cleared');
  }
}