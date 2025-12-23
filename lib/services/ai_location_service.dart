// lib/services/ai_location_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

class AILocationService {
  // Get your free API key from: https://makersuite.google.com/app/apikey
 static const String _geminiApiKey = 'AIzaSyDCn7RWZpe1pJvtEuo7Emtj8axM2SeHcyw';
   static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  
  // In-memory cache for generated data (no database needed!)
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
      
      // Generate with AI
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
        print('✅ Found JSON in response');
        final itinerary = jsonDecode(jsonMatch.group(0)!) as List;
        final result = itinerary.cast<Map<String, dynamic>>();
        
        print('📊 Generated ${result.length} days');
        
        // Store in cache
        _itineraryCache[cacheKey] = result;
        
        print('✅ Successfully cached itinerary');
        return result;
      } else {
        print('❌ No JSON found in response');
        print('Response: $cleanContent');
        throw Exception('No valid JSON found in AI response');
      }
    } catch (e, stackTrace) {
      print('❌ Error generating itinerary: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
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
      
      // Generate with AI
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
      
      String cleanContent = content.trim();
      cleanContent = cleanContent.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleanContent);
      if (jsonMatch != null) {
        print('✅ Found JSON in response');
        final points = jsonDecode(jsonMatch.group(0)!) as List;
        final result = points.cast<Map<String, dynamic>>();
        
        print('📊 Generated ${result.length} meeting points');
        
        // Store in cache
        _meetingPointsCache[tripId] = result;
        
        print('✅ Successfully cached meeting points');
        return result;
      }
      
      throw Exception('No valid JSON found in response');
    } catch (e, stackTrace) {
      print('❌ Error generating meeting points: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
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
      
      // Search with AI
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