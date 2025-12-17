import 'package:flutter/material.dart';

// --- CONFIGURATION & COLORS ---
const Color primaryBlue = Color(0xFF1E3A8A);
const Color accentOrange = Color(0xFFF96839);
const Color lightBackground = Color(0xFFF4F7FB);
const Color cardColor = Colors.white;
const Color subtitleColor = Color(0xFF6B7280);
const Color ratingColor = Color(0xFFFFC107);
const Color successGreen = Color(0xFF059669);

enum AppPage { home, trips, profile, tripDetails }

// Enhanced Trip Data with your requested Unsplash Images
const List<Map<String, dynamic>> allTrips = [
  {
    'id': '1',
    'title': 'Bali Beach Paradise',
    'location': 'Bali, Indonesia',
    'rating': 4.9,
    'reviews': 328,
    'price': 1299,
    'date': 'Mar 15 - Mar 22',
    'image': 'https://images.unsplash.com/photo-1577717903315-1691ae25ab3f?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'airline': 'Garuda Indonesia',
    'aircraft': 'Boeing 787 Dreamliner',
    'class': 'Business Class',
    'description': 'Experience the ultimate tropical getaway with pristine beaches and vibrant culture.',
  },
  {
    'id': '2',
    'title': 'European Escapade',
    'location': 'Paris & Rome',
    'rating': 4.8,
    'reviews': 436,
    'price': 1899,
    'date': 'Apr 10 - Apr 20',
    'image': 'https://images.unsplash.com/photo-1473951574080-01fe45ec8643?q=80&w=2104&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'airline': 'Air France',
    'aircraft': 'Airbus A350-900',
    'class': 'Economy Plus',
    'description': 'A journey through the heart of Europe’s most romantic and historic cities.',
  },
  {
    'id': '3',
    'title': 'Mountain Adventure',
    'location': 'Swiss Alps',
    'rating': 4.7,
    'reviews': 234,
    'price': 1599,
    'date': 'May 5 - May 12',
    'image': 'https://images.unsplash.com/photo-1586752488885-6ce47fdfd874?q=80&w=2113&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'airline': 'Swiss Air',
    'aircraft': 'Airbus A330',
    'class': 'Normal Chair',
    'description': 'Breathtaking views and world-class skiing in the heart of the Alps.',
  },
  {
    'id': '4',
    'title': 'Tokyo Modern',
    'location': 'Tokyo, Japan',
    'rating': 4.9,
    'reviews': 512,
    'price': 1799,
    'date': 'Jun 1 - Jun 10',
    'image': 'https://images.unsplash.com/photo-1617869884925-f8f0a51b2374?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'airline': 'Japan Airlines',
    'aircraft': 'Boeing 777',
    'class': 'First Class',
    'description': 'Explore the neon lights and ancient temples of Japan’s bustling capital.',
  },
];