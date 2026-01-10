import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../config/config.dart';
import 'admin_trip_form_screen.dart';

class AdminTripsScreen extends StatelessWidget {
  const AdminTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: adminProvider.isLoadingTrips
          ? const Center(child: CircularProgressIndicator(color: accentOrange))
          : adminProvider.trips.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flight_takeoff, size: 64, color: Colors.white30),
                  const SizedBox(height: 16),
                  const Text(
                    'No trips found',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: adminProvider.trips.length,
              itemBuilder: (context, index) {
                final trip = adminProvider.trips[index];
                return Card(
                  color: const Color(0xFF16213E),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (trip.image != null && trip.image!.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            trip.image!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 150,
                              color: Colors.white12,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.white30,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          trip.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  trip.location,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  trip.date,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${trip.rating} (${trip.reviews} reviews)',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const Spacer(),
                                Text(
                                  '\$${trip.price}',
                                  style: TextStyle(
                                    color: accentOrange,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _editTrip(context, trip),
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              label: const Text(
                                'Edit',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () =>
                                  _deleteTrip(context, trip.id, trip.title),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createTrip(context),
        backgroundColor: accentOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Trip',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _createTrip(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminTripFormScreen()),
    );
  }

  void _editTrip(BuildContext context, trip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminTripFormScreen(trip: trip)),
    );
  }

  void _deleteTrip(BuildContext context, String tripId, String tripTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Delete Trip', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "$tripTitle"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final adminProvider = Provider.of<AdminProvider>(
                context,
                listen: false,
              );
              final success = await adminProvider.deleteTrip(tripId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Trip deleted successfully'
                          : 'Failed to delete trip',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
