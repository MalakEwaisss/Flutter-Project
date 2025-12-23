// lib/services/ai_location_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

class AILocationService {
  // Get your free API key from: https://makersuite.google.com/app/apikey
  static const String _geminiApiKey = 'AIzaSyDCn7RWZpe1pJvtEuo7Emtj8axM2SeHcyw';
  static const String _geminiApiUrl = 
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  
  // Generate itinerary for a trip
  static Future<List<Map<String, dynamic>>> generateItinerary(
    String tripTitle,
    String location,
    int days,
  ) async {
    try {
      // Check if already exists in database
      final existing = await supabase
          .from('trip_itineraries')
          .select()
          .eq('trip_id', tripTitle.replaceAll(' ', '_').toLowerCase())
          .order('day');
      
      if (existing.isNotEmpty) {
        return List<Map<String, dynamic>>.from(existing);
      }

      // Generate with AI if not exists
      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_geminiApiKey'),
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

Return ONLY valid JSON array format with no markdown formatting or code blocks:
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        // Parse JSON from response (remove markdown code blocks if present)
        String cleanContent = content.trim();
        cleanContent = cleanContent.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleanContent);
        if (jsonMatch != null) {
          final itinerary = jsonDecode(jsonMatch.group(0)!) as List;
          
          // Store in database
          final tripId = tripTitle.replaceAll(' ', '_').toLowerCase();
          for (var item in itinerary) {
            await supabase.from('trip_itineraries').insert({
              'trip_id': tripId,
              'day': item['day'],
              'title': item['title'],
              'description': item['description'],
              'latitude': item['latitude'],
              'longitude': item['longitude'],
              'activities': item['activities'],
              'time': item['time'],
            });
          }
          
          return itinerary.cast<Map<String, dynamic>>();
        }
      }
      
      throw Exception('Failed to generate itinerary');
    } catch (e) {
      print('Error generating itinerary: $e');
      return [];
    }
  }

  // Generate meeting points for a trip
  static Future<List<Map<String, dynamic>>> generateMeetingPoints(
    String location,
    String tripId,
  ) async {
    try {
      // Check if already exists
      final existing = await supabase
          .from('meeting_points')
          .select()
          .eq('trip_id', tripId);
      
      if (existing.isNotEmpty) {
        return List<Map<String, dynamic>>.from(existing);
      }

      // Generate with AI
      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_geminiApiKey'),
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

Return ONLY valid JSON array with no markdown formatting:
[
  {
    "name": "Point Name",
    "description": "Brief description",
    "latitude": 0.0000,
    "longitude": 0.0000,
    "icon_type": "airport|train|landmark|hotel"
  }
]

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        String cleanContent = content.trim();
        cleanContent = cleanContent.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleanContent);
        if (jsonMatch != null) {
          final points = jsonDecode(jsonMatch.group(0)!) as List;
          
          // Store in database
          for (var point in points) {
            await supabase.from('meeting_points').insert({
              'trip_id': tripId,
              'name': point['name'],
              'description': point['description'],
              'latitude': point['latitude'],
              'longitude': point['longitude'],
              'icon_type': point['icon_type'],
            });
          }
          
          return points.cast<Map<String, dynamic>>();
        }
      }
      
      throw Exception('Failed to generate meeting points');
    } catch (e) {
      print('Error generating meeting points: $e');
      return [];
    }
  }

  // Search for locations with AI assistance
  static Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    try {
      // Check cache first
      final cached = await supabase
          .from('location_suggestions')
          .select()
          .eq('query', query.toLowerCase())
          .gt('expires_at', DateTime.now().toIso8601String())
          .maybeSingle();
      
      if (cached != null) {
        return List<Map<String, dynamic>>.from(cached['suggestions']);
      }

      // Search with AI
      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_geminiApiKey'),
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

Return ONLY valid JSON array with no markdown formatting:
[
  {
    "name": "Location Name",
    "address": "Full Address",
    "category": "restaurant|attraction|hotel|nature|transport|other",
    "latitude": 0.0000,
    "longitude": 0.0000,
    "description": "Brief description"
  }
]'''
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        String cleanContent = content.trim();
        cleanContent = cleanContent.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(cleanContent);
        if (jsonMatch != null) {
          final suggestions = jsonDecode(jsonMatch.group(0)!) as List;
          
          // Cache the results
          await supabase.from('location_suggestions').insert({
            'query': query.toLowerCase(),
            'suggestions': suggestions,
          });
          
          return suggestions.cast<Map<String, dynamic>>();
        }
      }
      
      return [];
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }
}