// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'config.dart'; // For colors, AppPage, allTrips

// --- REUSABLE WIDGETS ---

/// Ensures content is centered and constrained to a comfortable max width (1000px).
class MaxWidthSection extends StatelessWidget {
  final Widget child;
  final double verticalPadding;
  final double horizontalPadding;

  const MaxWidthSection({
    super.key,
    required this.child,
    this.verticalPadding = 40.0,
    this.horizontalPadding = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: child,
        ),
      ),
    );
  }
}

// Custom App Bar with Navigation
class CustomAppBar extends StatelessWidget {
  final Function(AppPage) navigateTo;
  final AppPage currentPage;
  // Login status and action (Show modal/Logout)
  final bool isLoggedIn;
  final VoidCallback onAuthAction;

  const CustomAppBar({
    super.key,
    required this.navigateTo,
    required this.isLoggedIn,
    required this.onAuthAction,
    this.currentPage = AppPage.home,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: 24,
        right: 24,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo/Home Button
          InkWell(
            onTap: () => navigateTo(AppPage.home),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: accentOrange, size: 28),
                const SizedBox(width: 8),
                Text(
                  'TravelHub',
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Links & Profile Icon
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => navigateTo(AppPage.home),
                  child: Text(
                    'Home',
                    style: TextStyle(
                      color: currentPage == AppPage.home
                          ? primaryBlue
                          : subtitleColor,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => navigateTo(AppPage.trips),
                  child: Text(
                    'Trips',
                    style: TextStyle(
                      color: currentPage == AppPage.trips
                          ? primaryBlue
                          : subtitleColor,
                    ),
                  ),
                ),

                // Check Weather Button
                ElevatedButton.icon(
                  onPressed: () => navigateTo(AppPage.weather),
                  icon: const Icon(
                    Icons.wb_sunny,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Check Weather',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),


                // Sign Up/Login Button
                if (!isLoggedIn) ...[
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: onAuthAction, // Show modal
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ] else ...[
                  // Notifications icon only when logged in
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: primaryBlue,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],

                const SizedBox(width: 8),

                // Profile Button (Navigates to ProfileScreen or shows modal)
                InkWell(
                  onTap: () {
                    if (isLoggedIn) {
                      navigateTo(AppPage.profile); // Navigate to profile
                    } else {
                      onAuthAction(); // Show modal
                    }
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: isLoggedIn
                        ? primaryBlue
                        : subtitleColor.withOpacity(0.5),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 18,
                    ),
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

// --- SEARCH BAR ---

class TripSearchBar extends StatefulWidget {
  final Function(AppPage) navigateTo;
  const TripSearchBar({super.key, required this.navigateTo});

  @override
  State<TripSearchBar> createState() => _TripSearchBarState();
}

class _TripSearchBarState extends State<TripSearchBar> {
  final List<String> _worldRegions = const [
    'Global',
    'Asia',
    'Europe',
    'North America',
    'South America',
    'Africa',
    'Oceania',
  ];

  String? _selectedWorldRegion = 'Asia';
  final TextEditingController _destinationController = TextEditingController(
    text: 'Bali, Indonesia',
  );
  final TextEditingController _dateController = TextEditingController(
    text: '01/10/2026',
  );
  final TextEditingController _travelersController = TextEditingController(
    text: '2',
  );
  DateTime? _selectedDate;

  // Function to show Date Picker (unchanged)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // Action for search: Navigate to the TripsScreen
  void _performSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Searching in World Region: $_selectedWorldRegion for Destination: ${_destinationController.text}...',
        ),
        backgroundColor: successGreen,
        duration: const Duration(seconds: 1),
      ),
    );
    // Navigate to the Trip List Screen
    widget.navigateTo(AppPage.trips);
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _dateController.dispose();
    _travelersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.15),
              spreadRadius: 5,
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: _SearchDropdownField(
                icon: Icons.public,
                label: 'World List',
                value: _selectedWorldRegion,
                items: _worldRegions,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWorldRegion = newValue;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _SearchInputField(
                controller: _destinationController,
                icon: Icons.location_city,
                label: 'Region & City',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _SearchInputField(
                controller: _dateController,
                icon: Icons.calendar_today,
                label: 'Start Date',
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _SearchInputField(
                controller: _travelersController,
                icon: Icons.people_outline,
                label: 'Travelers',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 25,
                ),
                elevation: 0,
              ),
              child: const Icon(Icons.search, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Search Input Field
class _SearchInputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputType keyboardType;

  const _SearchInputField({
    required this.controller,
    required this.icon,
    required this.label,
    this.onTap,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: subtitleColor, size: 20),
        labelText: label,
        labelStyle: const TextStyle(color: subtitleColor, fontSize: 14),
      ),
    );
  }
}

// Reusable Search Dropdown Field
class _SearchDropdownField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _SearchDropdownField({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, color: subtitleColor, size: 20),
        labelText: label,
        labelStyle: const TextStyle(color: subtitleColor, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: lightBackground.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      icon: const Icon(Icons.arrow_drop_down, color: primaryBlue),
      dropdownColor: cardColor,
      style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
      isExpanded: true,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
    );
  }
}

// --- POPULAR TRIP CARD WIDGET (Reusable) ---

class PopularTripCard extends StatelessWidget {
  final Map<String, dynamic> trip;
  final Function(AppPage) navigateTo;

  const PopularTripCard({
    super.key,
    required this.trip,
    required this.navigateTo,
  });

  // Helper to show dummy suggestions
  List<Map<String, String>> _getSuggestions(String location) {
    if (location.contains('Indonesia') || location.contains('Japan')) {
      return [
        {
          'location': 'Bangkok, Thailand',
          'note': 'Vibrant street life and markets',
        },
        {
          'location': 'Hanoi, Vietnam',
          'note': 'Historical capital with rich culture',
        },
      ];
    } else {
      return [
        {
          'location': 'Prague, Czechia',
          'note': 'Fairy-tale architecture and history',
        },
        {
          'location': 'Barcelona, Spain',
          'note': 'Gaudí\'s art and sunny beaches',
        },
      ];
    }
  }

  void _showSuggestedCountries(BuildContext context) {
    final suggestions = _getSuggestions(trip['location']);

    showDialog(
      context: context,
      builder: (context) => SuggestedCountriesDialog(
        tappedTrip: trip['title'],
        suggestions: suggestions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: InkWell(
        onTap: () => _showSuggestedCountries(context),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Badges/Icons
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      trip['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // FEATURED Badge
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Heart Icon (Save)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.favorite_border,
                          color: subtitleColor,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Title & Location
            Text(
              trip['title'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Location/Subtitle
            Row(
              children: [
                const Icon(Icons.pin_drop, color: subtitleColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  trip['location'],
                  style: const TextStyle(fontSize: 14, color: subtitleColor),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating and Share
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: ratingColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${trip['rating']} (${trip['reviews']} reviews)',
                      style: const TextStyle(
                        color: subtitleColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                // Share Icon
                IconButton(
                  icon: const Icon(Icons.share, color: subtitleColor, size: 18),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price and View Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${trip['date']}',
                      style: TextStyle(
                        color: subtitleColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${trip['price']}',
                          style: const TextStyle(
                            color: primaryBlue,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${trip['going']} going',
                          style: TextStyle(
                            color: accentOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // View Button (Blue background)
                ElevatedButton(
                  onPressed: () => navigateTo(AppPage.trips),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'View Trip',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- DIALOG FOR SUGGESTED COUNTRIES ---

class SuggestedCountriesDialog extends StatelessWidget {
  final String tappedTrip;
  final List<Map<String, String>> suggestions;

  const SuggestedCountriesDialog({
    super.key,
    required this.tappedTrip,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: cardColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'More Trips like "$tappedTrip"',
              style: const TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: subtitleColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Here are other top destinations in the region that might interest you:',
              style: TextStyle(color: subtitleColor, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.flight_takeoff,
                      color: accentOrange,
                    ),
                    title: Text(
                      suggestion['location']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    subtitle: Text(
                      suggestion['note']!,
                      style: const TextStyle(color: subtitleColor),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: subtitleColor,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Simulated navigation to ${suggestion['location']}!',
                          ),
                          backgroundColor: primaryBlue,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
