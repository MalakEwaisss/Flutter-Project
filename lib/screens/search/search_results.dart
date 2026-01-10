import 'package:flutter/material.dart';
import '../../config/config.dart';
import '../../widgets/trip_card.dart';
import '../../services/trips_service.dart';

class SearchResultsScreen extends StatefulWidget {
  final String? destination;
  final DateTimeRange? dateRange;
  final double? budget;

  const SearchResultsScreen({
    super.key,
    this.destination,
    this.dateRange,
    this.budget,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchTrips();
  }

  Future<void> _searchTrips() async {
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> filtered;

      // First, search by destination if provided
      if (widget.destination != null && widget.destination!.isNotEmpty) {
        filtered = await TripsService.searchTrips(widget.destination!);
      } else {
        filtered = await TripsService.getAllTrips();
      }

      // Then filter by budget if provided
      if (widget.budget != null) {
        filtered = filtered.where((trip) {
          final price = trip['price'] as int?;
          return price != null && price <= widget.budget!;
        }).toList();
      }

      setState(() {
        _results = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        // Fallback to local filtering
        _results = _filterLocally();
      });
    }
  }

  List<Map<String, dynamic>> _filterLocally() {
    List<Map<String, dynamic>> filtered = List.from(fallbackTrips);

    // Filter by destination
    if (widget.destination != null && widget.destination!.isNotEmpty) {
      final searchTerm = widget.destination!.toLowerCase();
      filtered = filtered.where((trip) {
        final title = trip['title']?.toString().toLowerCase() ?? '';
        final location = trip['location']?.toString().toLowerCase() ?? '';
        return title.contains(searchTerm) || location.contains(searchTerm);
      }).toList();
    }

    // Filter by budget
    if (widget.budget != null) {
      filtered = filtered.where((trip) {
        final price = trip['price'] as int?;
        return price != null && price <= widget.budget!;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Tooltip(
                message: 'Using offline data',
                child: Icon(Icons.cloud_off, color: Colors.orange),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Searching trips...'),
                ],
              ),
            )
          : _results.isEmpty
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
              : RefreshIndicator(
                  onRefresh: _searchTrips,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                                '${_results.length} ${_results.length == 1 ? 'trip' : 'trips'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (widget.destination != null || widget.budget != null) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (widget.destination != null && widget.destination!.isNotEmpty)
                                  Chip(
                                    label: Text('Location: ${widget.destination}'),
                                    deleteIcon: const Icon(Icons.close, size: 18),
                                    onDeleted: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                if (widget.budget != null)
                                  Chip(
                                    label: Text('Budget: \$${widget.budget!.toInt()}'),
                                    deleteIcon: const Icon(Icons.close, size: 18),
                                    onDeleted: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _results.length,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                            ),
                            itemBuilder: (context, index) {
                              return TripCard(
                                trip: _results[index],
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
                ),
    );
  }
}