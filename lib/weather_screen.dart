import 'package:flutter/material.dart';
import 'config.dart';
import 'widgets_reusable.dart';

// -----------------------------------------------------------------
// --- WEATHER SCREEN ---
// -----------------------------------------------------------------

class WeatherScreen extends StatelessWidget {
  final Function(AppPage) navigateTo;
  final bool isLoggedIn;
  final Function(BuildContext context) showAuthModal;

  const WeatherScreen({
    super.key,
    required this.navigateTo,
    required this.isLoggedIn,
    required this.showAuthModal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Bar
        CustomAppBar(
          navigateTo: navigateTo,
          currentPage: AppPage.weather,
          isLoggedIn: isLoggedIn,
          onAuthAction: () => showAuthModal(context),
        ),

        // Main Content Area
        Expanded(
          child: SingleChildScrollView(
            child: MaxWidthSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title
                  const Text(
                    'Weather Forecast',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check the weather for your upcoming destinations',
                    style: TextStyle(fontSize: 18, color: subtitleColor),
                  ),
                  const SizedBox(height: 30),

                  // Current Weather Card
                  _CurrentWeatherCard(),
                  const SizedBox(height: 30),

                  // 7-Day Forecast
                  const Text(
                    '7-Day Forecast',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SevenDayForecast(),
                  const SizedBox(height: 30),

                  // Weather Details
                  const Text(
                    'Weather Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _WeatherDetailsGrid(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- CURRENT WEATHER CARD ---

class _CurrentWeatherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Side - Location and Temperature
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.location_on, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Bali, Indonesia',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '28°C',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Partly Cloudy',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(Icons.arrow_upward, color: Colors.white70, size: 16),
                    Text(
                      '32°',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.arrow_downward, color: Colors.white70, size: 16),
                    Text(
                      '24°',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Side - Weather Icon
          Expanded(
            flex: 1,
            child: Column(
              children: const [
                Icon(
                  Icons.wb_cloudy,
                  color: Colors.white,
                  size: 120,
                ),
                SizedBox(height: 8),
                Text(
                  'Updated 10 min ago',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 7-DAY FORECAST ---

class _SevenDayForecast extends StatelessWidget {
  final List<Map<String, dynamic>> _forecast = const [
    {'day': 'Mon', 'icon': Icons.wb_sunny, 'high': 32, 'low': 24},
    {'day': 'Tue', 'icon': Icons.wb_cloudy, 'high': 30, 'low': 23},
    {'day': 'Wed', 'icon': Icons.cloud, 'high': 28, 'low': 22},
    {'day': 'Thu', 'icon': Icons.wb_sunny, 'high': 31, 'low': 25},
    {'day': 'Fri', 'icon': Icons.grain, 'high': 27, 'low': 21},
    {'day': 'Sat', 'icon': Icons.wb_cloudy, 'high': 29, 'low': 23},
    {'day': 'Sun', 'icon': Icons.wb_sunny, 'high': 33, 'low': 26},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _forecast.length,
        itemBuilder: (context, index) {
          final day = _forecast[index];
          return Container(
            width: 100,
            margin: EdgeInsets.only(right: index < _forecast.length - 1 ? 16 : 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: lightBackground, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  day['day'],
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  day['icon'],
                  color: accentOrange,
                  size: 40,
                ),
                Text(
                  '${day['high']}°',
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${day['low']}°',
                  style: const TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- WEATHER DETAILS GRID ---

class _WeatherDetailsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _WeatherDetailCard(
          icon: Icons.water_drop,
          label: 'Humidity',
          value: '65%',
          color: Color(0xFF4A90E2),
        ),
        _WeatherDetailCard(
          icon: Icons.air,
          label: 'Wind Speed',
          value: '12 km/h',
          color: Color(0xFF059669),
        ),
        _WeatherDetailCard(
          icon: Icons.visibility,
          label: 'Visibility',
          value: '10 km',
          color: accentOrange,
        ),
        _WeatherDetailCard(
          icon: Icons.compress,
          label: 'Pressure',
          value: '1013 mb',
          color: primaryBlue,
        ),
        _WeatherDetailCard(
          icon: Icons.wb_twilight,
          label: 'UV Index',
          value: '8 (High)',
          color: Color(0xFFFFC107),
        ),
        _WeatherDetailCard(
          icon: Icons.thermostat,
          label: 'Feels Like',
          value: '30°C',
          color: Color(0xFFE91E63),
        ),
      ],
    );
  }
}

// --- WEATHER DETAIL CARD ---

class _WeatherDetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WeatherDetailCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: lightBackground, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: subtitleColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: primaryBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
