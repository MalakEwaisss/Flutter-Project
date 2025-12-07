import 'package:flutter/material.dart';

// --- CONFIGURATION & DATA STUBS ---

const Color primaryBlue = Color(0xFF1E3A8A);
const Color accentOrange = Color(0xFFF96839);
const Color lightBackground = Color(0xFFF4F7FB);
const Color cardColor = Colors.white;
const Color subtitleColor = Color(0xFF6B7280);
const Color ratingColor = Color(0xFFFFC107);
const Color successGreen = Color(0xFF059669);

enum AppPage { home, trips, profile, weather }

// Dummy Trip Data (Used for Home and Trips Screen) - This is a global constant
const List<Map<String, dynamic>> allTrips = [
  {
    'title': 'Bali Beach Paradise',
    'location': 'Bali, Indonesia',
    'rating': 4.9,
    'reviews': 328,
    'price': 1299,
    'going': 12,
    'date': 'Mar 15 - Mar 22',
    'image': 'https://picsum.photos/400/300?random=11',
  },
  {
    'title': 'European Escapade',
    'location': 'Paris & Rome',
    'rating': 4.8,
    'reviews': 436,
    'price': 1899,
    'going': 8,
    'date': 'Apr 10 - Apr 20',
    'image': 'https://picsum.photos/400/300?random=12',
  },
  {
    'title': 'Mountain Adventure',
    'location': 'Swiss Alps',
    'rating': 4.7,
    'reviews': 234,
    'price': 1599,
    'going': 6,
    'date': 'May 5 - May 12',
    'image': 'https://picsum.photos/400/300?random=13',
  },
  {
    'title': 'Tokyo Modern',
    'location': 'Tokyo, Japan',
    'rating': 4.9,
    'reviews': 512,
    'price': 1799,
    'going': 10,
    'date': 'Jun 1 - Jun 10',
    'image': 'https://picsum.photos/400/300?random=14',
  },
  // Additional trips for the list screen
  {
    'title': 'Grand Canyon Trek',
    'location': 'Arizona, USA',
    'rating': 4.6,
    'reviews': 188,
    'price': 950,
    'going': 15,
    'date': 'Jul 1 - Jul 7',
    'image': 'https://picsum.photos/400/300?random=15',
  },
  {
    'title': 'Thailand Islands Hop',
    'location': 'Phuket & Krabi',
    'rating': 5.0,
    'reviews': 701,
    'price': 1450,
    'going': 20,
    'date': 'Aug 1 - Aug 14',
    'image': 'https://picsum.photos/400/300?random=16',
  },
  {
    'title': 'Iceland Ring Road',
    'location': 'Reykjavik, Iceland',
    'rating': 4.7,
    'reviews': 310,
    'price': 2200,
    'going': 5,
    'date': 'Sep 1 - Sep 10',
    'image': 'https://picsum.photos/400/300?random=17',
  },
];
