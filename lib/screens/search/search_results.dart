import 'package:flutter/material.dart';
import '../../config/config.dart';
import '../../widgets/trip_card.dart';

class SearchResultsScreen extends StatelessWidget {
  final String? destination;
  final DateTimeRange? dateRange;
  final double? budget;

  const SearchResultsScreen({
    super.key,
    this.destination,
    this.dateRange,
    this.budget,
  });

  List<Map<String, dynamic>> _filterTrips() {
    List<Map<String, dynamic>> filtered = allTrips;

    // Filter by destination (title or location)
    if (destination != null && destination!.isNotEmpty) {
      final searchTerm = destination!.toLowerCase();
      filtered = filtered.where((trip) {
        final title = trip['title']?.toString().toLowerCase() ?? '';
        final location = trip['location']?.toString().toLowerCase() ?? '';
        return title.contains(searchTerm) || location.contains(searchTerm);
      }).toList();
    }

    // Filter by max budget (price)
    if (budget != null) {
      filtered = filtered.where((trip) {
        final price = trip['price'] as int?;
        return price != null && price <= budget!;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final results = _filterTrips();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: results.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  const Text(
                    'Trip not found',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Try adjusting your search criteria',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Back to Search',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Found Trips',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${results.length} ${results.length == 1 ? 'trip' : 'trips'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: results.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 400,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                      itemBuilder: (context, index) {
                        return TripCard(
                          trip: results[index],
                          onViewDetails: (trip) {
                            Navigator.pushNamed(
                              context,
                              '/trip-details',
                              arguments: trip,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
