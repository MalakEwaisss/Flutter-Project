import 'package:flutter/material.dart';
import '../config/config.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/max_width_section.dart';
import '../widgets/trip_card.dart';
import '../services/trips_service.dart';

class ExploreTripsScreen extends StatefulWidget {
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;
  final bool isLoggedIn;
  final Function(BuildContext context) showAuthModal;
  final VoidCallback onThemeToggle;

  const ExploreTripsScreen({
    super.key,
    required this.navigateTo,
    required this.isLoggedIn,
    required this.showAuthModal,
    required this.onThemeToggle,
  });

  @override
  State<ExploreTripsScreen> createState() => _ExploreTripsScreenState();
}

class _ExploreTripsScreenState extends State<ExploreTripsScreen> {
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    try {
      final trips = await TripsService.getAllTrips();
      setState(() {
        _trips = trips;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        // Use fallback data
        _trips = fallbackTrips;
      });
    }
  }

  Future<void> _refreshTrips() async {
    try {
      final trips = await TripsService.refreshTrips();
      setState(() {
        _trips = trips;
        _error = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trips refreshed successfully'),
            backgroundColor: successGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          navigateTo: (page) => widget.navigateTo(page),
          currentPage: AppPage.explore,
          isLoggedIn: widget.isLoggedIn,
          onAuthAction: () => widget.showAuthModal(context),
          onThemeToggle: widget.onThemeToggle,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshTrips,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: MaxWidthSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Explore All Trips',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Tooltip(
                                  message: 'Using offline data',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.orange),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.cloud_off, color: Colors.orange, size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          'Offline',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            Text(
                              '${_trips.length} destinations available',
                              style: TextStyle(fontSize: 16, color: subtitleColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(60),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Loading trips...'),
                            ],
                          ),
                        ),
                      )
                    else if (_trips.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(60),
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              const Text(
                                'No trips available',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text('Please try again later'),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _loadTrips,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _trips.length,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemBuilder: (context, index) {
                          return TripCard(
                            trip: _trips[index],
                            onViewDetails: (trip) => widget.navigateTo(AppPage.tripDetails, trip: trip),
                          );
                        },
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}