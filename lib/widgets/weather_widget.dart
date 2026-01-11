// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/config.dart';

class WeatherWidget extends StatefulWidget {
  final String location;

  const WeatherWidget({super.key, required this.location});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  late Future<Map<String, dynamic>> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = fetchWeather();
  }

  Future<Map<String, dynamic>> fetchWeather() async {
    String key = '';
    try {
      key = dotenv.env["WEATHER_API_KEY"] ?? '';
    } catch (e) {
      if (e.toString().contains('NotInitializedError')) {
        throw Exception('Environment not initialized. Please restart the app.');
      }
      rethrow;
    }
    
    if (key.isEmpty) {
      throw Exception('Weather API Key is missing in .env');
    }

    final city = Uri.encodeComponent(
      widget.location.split(',').first.split('&').first.trim(),
    );
    
    // Use OpenWeatherMap API
    try {
      final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$key&units=metric');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temperature': data['main']['temp'].round().toString(),
          'condition': data['weather'][0]['main'],
          'description': data['weather'][0]['description'],
          'humidity': data['main']['humidity'].toString(),
          'city': data['name'],
        };
      } else if (response.statusCode == 401) {
        final errorData = json.decode(response.body);
        final errorMsg = errorData['message'] ?? 'Invalid API Key';
        throw Exception('Invalid API Key: $errorMsg. Please check your OpenWeatherMap API key in assets/.env');
      } else if (response.statusCode == 404) {
        throw Exception('City not found. Please check the location name.');
      } else {
        final errorData = json.decode(response.body);
        final errorMsg = errorData['message'] ?? 'Unknown Error';
        throw Exception('Weather API Error: $errorMsg');
      }
    } catch (e) {
      debugPrint('OpenWeather error: $e');
      if (e.toString().contains('Invalid API Key') || e.toString().contains('City not found')) {
        rethrow;
      }
      throw Exception('Failed to fetch weather data. Please check your internet connection and API key.');
    }
  }

  IconData _getWeatherIcon(String condition) {
    final desc = condition.toLowerCase();
    if (desc.contains('sunny') || desc.contains('clear')) {
      return Icons.wb_sunny;
    } else if (desc.contains('cloud') || desc.contains('overcast')) {
      return Icons.cloud;
    } else if (desc.contains('rain') || desc.contains('drizzle') || desc.contains('patchy rain')) {
      return Icons.grain;
    } else if (desc.contains('thunder') || desc.contains('storm')) {
      return Icons.flash_on;
    } else if (desc.contains('snow') || desc.contains('ice') || desc.contains('sleet') || desc.contains('blizzard')) {
      return Icons.ac_unit;
    } else if (desc.contains('mist') || desc.contains('fog')) {
      return Icons.cloud_queue;
    }
    return Icons.wb_cloudy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, color: accentOrange, size: 28),
              const SizedBox(width: 10),
              const Text(
                'Weather Forecast',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<Map<String, dynamic>>(
            future: _weatherFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 15),
                        Text('Loading weather data...'),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        snapshot.error.toString().replaceAll('Exception: ', ''),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Please check your API key\nor internet connection',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: subtitleColor, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _weatherFuture = fetchWeather();
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasData) {
                final weather = snapshot.data!;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(
                              _getWeatherIcon(weather['condition'] ?? ''),
                              size: 60,
                              color: accentOrange,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${weather['temperature']}°C',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weather['condition'] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              weather['description'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: primaryBlue),
                                const SizedBox(width: 5),
                                Text(
                                  weather['city'] ?? widget.location,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.opacity, color: primaryBlue),
                        const SizedBox(width: 8),
                        Text(
                          'Humidity: ${weather['humidity']}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return const Text('No data available');
            },
          ),
        ],
      ),
    );
  }
}
