// lib/screens/saved_locations_screen_improved.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/config.dart';
import '../main.dart';
import '../services/ai_location_service.dart';

enum LocationCategory {
  restaurant,
  attraction,
  hotel,
  shopping,
  nature,
  transport,
  other,
}

extension LocationCategoryExtension on LocationCategory {
  String get displayName {
    switch (this) {
      case LocationCategory.restaurant:
        return 'Restaurant';
      case LocationCategory.attraction:
        return 'Attraction';
      case LocationCategory.hotel:
        return 'Hotel';
      case LocationCategory.shopping:
        return 'Shopping';
      case LocationCategory.nature:
        return 'Nature';
      case LocationCategory.transport:
        return 'Transport';
      case LocationCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case LocationCategory.restaurant:
        return Icons.restaurant;
      case LocationCategory.attraction:
        return Icons.attractions;
      case LocationCategory.hotel:
        return Icons.hotel;
      case LocationCategory.shopping:
        return Icons.shopping_bag;
      case LocationCategory.nature:
        return Icons.park;
      case LocationCategory.transport:
        return Icons.directions_bus;
      case LocationCategory.other:
        return Icons.place;
    }
  }

  Color get color {
    switch (this) {
      case LocationCategory.restaurant:
        return const Color(0xFFE91E63);
      case LocationCategory.attraction:
        return const Color(0xFF9C27B0);
      case LocationCategory.hotel:
        return const Color(0xFF2196F3);
      case LocationCategory.shopping:
        return const Color(0xFFFF9800);
      case LocationCategory.nature:
        return const Color(0xFF4CAF50);
      case LocationCategory.transport:
        return const Color(0xFF607D8B);
      case LocationCategory.other:
        return const Color(0xFF795548);
    }
  }
}

class SavedLocation {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final LocationCategory category;
  final String? notes;
  final DateTime savedAt;

  SavedLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.category,
    this.notes,
    required this.savedAt,
  });

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      location: LatLng(json['latitude'], json['longitude']),
      category: LocationCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => LocationCategory.other,
      ),
      notes: json['notes'],
      savedAt: DateTime.parse(json['saved_at']),
    );
  }
}

class SavedLocationsScreen extends StatefulWidget {
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;
  final bool isLoggedIn;
  final Function(BuildContext context) showAuthModal;
  final VoidCallback onThemeToggle;

  const SavedLocationsScreen({
    super.key,
    required this.navigateTo,
    required this.isLoggedIn,
    required this.showAuthModal,
    required this.onThemeToggle,
  });

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  List<SavedLocation> _savedLocations = [];
  List<SavedLocation> _filteredLocations = [];
  SavedLocation? _selectedLocation;
  LocationCategory? _filterCategory;
  bool _isLoading = true;

  // For location search
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    if (!widget.isLoggedIn) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await supabase
          .from('saved_locations')
          .select()
          .eq('user_id', user.id)
          .order('saved_at', ascending: false);

      setState(() {
        _savedLocations = (response as List)
            .map((json) => SavedLocation.fromJson(json))
            .toList();
        _filteredLocations = _savedLocations;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading locations: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty && _filterCategory == null) {
        _filteredLocations = _savedLocations;
      } else {
        _filteredLocations = _savedLocations.where((loc) {
          final matchesSearch = query.isEmpty ||
              loc.name.toLowerCase().contains(query.toLowerCase()) ||
              loc.description.toLowerCase().contains(query.toLowerCase());
          final matchesCategory =
              _filterCategory == null || loc.category == _filterCategory;
          return matchesSearch && matchesCategory;
        }).toList();
      }
    });
  }

  void _selectLocation(SavedLocation location) {
    setState(() {
      _selectedLocation =
          _selectedLocation?.id == location.id ? null : location;
    });
    if (_selectedLocation != null) {
      _mapController.move(_selectedLocation!.location, 14.0);
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await AILocationService.searchLocations(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteLocation(SavedLocation location) async {
    try {
      await supabase.from('saved_locations').delete().eq('id', location.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location deleted successfully'),
            backgroundColor: successGreen,
          ),
        );
        _loadSavedLocations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddLocationDialog() {
    if (!widget.isLoggedIn) {
      widget.showAuthModal(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _AddLocationDialog(
        onLocationAdded: () {
          _loadSavedLocations();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn) {
      return _buildNotLoggedInView();
    }

    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 900;
                    return isMobile
                        ? _buildMobileLayout()
                        : _buildDesktopLayout();
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryBlue),
            onPressed: () => widget.navigateTo(AppPage.home),
            tooltip: 'Back to Home',
          ),
          const SizedBox(width: 8),
          const Text(
            'TravelHub',
            style: TextStyle(
              color: primaryBlue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => widget.navigateTo(AppPage.home),
            child: const Text('Home', style: TextStyle(color: primaryBlue)),
          ),
          TextButton(
            onPressed: () => widget.navigateTo(AppPage.trips),
            child: const Text('Trips', style: TextStyle(color: primaryBlue)),
          ),
          TextButton(
            onPressed: () => widget.navigateTo(AppPage.map),
            child: const Text('Map', style: TextStyle(color: primaryBlue)),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onThemeToggle,
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => widget.navigateTo(AppPage.profile),
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text('Profile', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.place, size: 100, color: subtitleColor),
                const SizedBox(height: 24),
                const Text(
                  'Save Your Favorite Locations',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sign in to start saving locations',
                  style: TextStyle(fontSize: 16, color: subtitleColor),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => widget.showAuthModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentOrange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        _buildMap(),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              _buildSearchBar(),
              if (_searchResults.isNotEmpty) _buildSearchResults(),
            ],
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.35,
          minChildSize: 0.15,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryFilters(),
                  Expanded(child: _buildLocationsList(scrollController)),
                ],
              ),
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: _showAddLocationDialog,
            backgroundColor: accentOrange,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Location',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildMap()),
        Container(
          width: 450,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    if (_searchResults.isNotEmpty) _buildSearchResults(),
                  ],
                ),
              ),
              _buildCategoryFilters(),
              Expanded(child: _buildLocationsList(null)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _showAddLocationDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add New Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    final markers = _filteredLocations.map((loc) {
      final isSelected = _selectedLocation?.id == loc.id;

      return Marker(
        point: loc.location,
        width: 60,
        height: 60,
        child: GestureDetector(
          onTap: () => _selectLocation(loc),
          child: Column(
            children: [
              Container(
                width: isSelected ? 44 : 36,
                height: isSelected ? 44 : 36,
                decoration: BoxDecoration(
                  color: loc.category.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  loc.category.icon,
                  color: Colors.white,
                  size: isSelected ? 24 : 20,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    // Add markers for search results
    final searchMarkers = _searchResults.map((result) {
      return Marker(
        point: LatLng(result['latitude'], result['longitude']),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.search, color: Colors.white, size: 20),
        ),
      );
    }).toList();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _filteredLocations.isNotEmpty
            ? _filteredLocations.first.location
            : LatLng(0, 0),
        initialZoom: 10.0,
        minZoom: 2.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.travelhub.app',
        ),
        MarkerLayer(markers: [...markers, ...searchMarkers]),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors', onTap: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          _filterLocations(value);
          if (value.length >= 3) {
            _searchLocations(value);
          }
        },
        decoration: InputDecoration(
          hintText: 'Search locations...',
          prefixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const Icon(Icons.search, color: primaryBlue),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterLocations('');
                    setState(() => _searchResults = []);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          return ListTile(
            leading: Icon(
              Icons.location_on,
              color: primaryBlue,
            ),
            title: Text(result['name']),
subtitle: Text(result['address'] ?? result['description'] ?? ''),
trailing: IconButton(
icon: const Icon(Icons.add_circle, color: accentOrange),
onPressed: () => _saveSearchResult(result),
),
onTap: () {
_mapController.move(
LatLng(result['latitude'], result['longitude']),
15.0,
);
},
);
},
),
);
}
Future<void> _saveSearchResult(Map<String, dynamic> result) async {
final user = supabase.auth.currentUser;
if (user == null) return;
try {
  await supabase.from('saved_locations').insert({
    'user_id': user.id,
    'name': result['name'],
    'description': result['description'] ?? result['address'],
    'latitude': result['latitude'],
    'longitude': result['longitude'],
    'category': result['category'] ?? 'other',
    'saved_at': DateTime.now().toIso8601String(),
  });

  setState(() => _searchResults = []);
  _searchController.clear();

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location saved successfully!'),
        backgroundColor: successGreen,
      ),
    );
    _loadSavedLocations();
  }
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
}
Widget _buildCategoryFilters() {
return Container(
height: 60,
padding: const EdgeInsets.symmetric(horizontal: 16),
child: ListView(
scrollDirection: Axis.horizontal,
children: [
_buildCategoryChip(null, 'All', Icons.apps),
...LocationCategory.values.map((category) {
return _buildCategoryChip(
category,
category.displayName,
category.icon,
);
}),
],
),
);
}
Widget _buildCategoryChip(
LocationCategory? category,
String label,
IconData icon,
) {
final isSelected = _filterCategory == category;
return Padding(
  padding: const EdgeInsets.only(right: 8),
  child: FilterChip(
    selected: isSelected,
    label: Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isSelected
              ? Colors.white
              : (category?.color ?? primaryBlue),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    ),
    onSelected: (selected) {
      setState(() {
        _filterCategory = selected ? category : null;
      });
      _filterLocations(_searchController.text);
    },
    backgroundColor: Theme.of(context).cardColor,
    selectedColor: category?.color ?? primaryBlue,
    labelStyle: TextStyle(
      color: isSelected ? Colors.white : null,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    ),
  ),
);
}
Widget _buildLocationsList(ScrollController? scrollController) {
if (_filteredLocations.isEmpty) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.place_outlined, size: 80, color: Colors.grey.shade400),
const SizedBox(height: 16),
Text(
_savedLocations.isEmpty
? 'No saved locations yet'
: 'No locations found',
style: const TextStyle(fontSize: 18, color: subtitleColor),
),
const SizedBox(height: 8),
Text(
_savedLocations.isEmpty
? 'Search and save your favorite places'
: 'Try adjusting your filters',
style: const TextStyle(fontSize: 14, color: subtitleColor),
),
],
),
);
}
return ListView.builder(
  controller: scrollController,
  padding: const EdgeInsets.all(16),
  itemCount: _filteredLocations.length,
  itemBuilder: (context, index) {
    final location = _filteredLocations[index];
    final isSelected = _selectedLocation?.id == location.id;

    return GestureDetector(
      onTap: () => _selectLocation(location),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? location.category.color.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? location.category.color
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: location.category.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  location.category.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              title: Text(
                location.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? location.category.color : null,
                ),
              ),
              subtitle: Text(
                location.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                    onTap: () {
                      Future.delayed(
                        Duration.zero,
                        () => _deleteLocation(location),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (location.notes != null && location.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.note, size: 16, color: subtitleColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location.notes!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: location.category.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      location.category.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: location.category.color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${location.location.latitude.toStringAsFixed(4)}, ${location.location.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  },
);
}
@override
void dispose() {
_searchController.dispose();
super.dispose();
}
}
// Add Location Dialog with Search
class _AddLocationDialog extends StatefulWidget {
final VoidCallback onLocationAdded;
const _AddLocationDialog({required this.onLocationAdded});
@override
State<_AddLocationDialog> createState() => _AddLocationDialogState();
}
class _AddLocationDialogState extends State<_AddLocationDialog> {
final _searchController = TextEditingController();
final _notesController = TextEditingController();
List<Map<String, dynamic>> _searchResults = [];
Map<String, dynamic>? _selectedLocation;
LocationCategory _selectedCategory = LocationCategory.other;
bool _isSearching = false;
@override
Widget build(BuildContext context) {
return Dialog(
child: Container(
width: 600,
padding: const EdgeInsets.all(24),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Add New Location',
style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
),
const SizedBox(height: 24),
TextField(
controller: _searchController,
decoration: InputDecoration(
labelText: 'Search Location',
hintText: 'Enter place name or address',
prefixIcon: _isSearching
? const Padding(
padding: EdgeInsets.all(12.0),
child: SizedBox(
width: 20,
height: 20,
child: CircularProgressIndicator(strokeWidth: 2),
),
)
: const Icon(Icons.search),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12),
),
),
onChanged: (value) async {
if (value.length >= 3) {
setState(() => _isSearching = true);
final results =
await AILocationService.searchLocations(value);
setState(() {
_searchResults = results;
_isSearching = false;
});
}
},
),
if (_searchResults.isNotEmpty) ...[
const SizedBox(height: 16),
Container(
constraints: const BoxConstraints(maxHeight: 200),
decoration: BoxDecoration(
border: Border.all(color: Colors.grey.shade300),
borderRadius: BorderRadius.circular(12),
),
child: ListView.builder(
shrinkWrap: true,
itemCount: _searchResults.length,
itemBuilder: (context, index) {
final result = _searchResults[index];
final isSelected = _selectedLocation == result;
                return ListTile(
                  selected: isSelected,
                  leading: Icon(
                    Icons.location_on,
                    color: isSelected ? accentOrange : primaryBlue,
                  ),
                  title: Text(result['name']),
                  subtitle:
                      Text(result['address'] ?? result['description'] ?? ''),
                  onTap: () {
                    setState(() {
                      _selectedLocation = result;
                      _selectedCategory = LocationCategory.values.firstWhere(
                        (e) => e.name == result['category'],
                        orElse: () => LocationCategory.other,
                      );
                    });
                  },
                );
              },
            ),
          ),
        ],
        if (_selectedLocation != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: successGreen),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: successGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedLocation!['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _selectedLocation!['address'] ??
                            _selectedLocation!['description'] ??
                            '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<LocationCategory>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: LocationCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(category.icon, size: 20, color: category.color),
                    const SizedBox(width: 8),
                    Text(category.displayName),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedCategory = value!);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Notes (Optional)',
              hintText: 'Add personal notes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _selectedLocation == null
                  ? null
                  : () async {
                      await _saveLocation();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Save Location',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);
}
Future<void> _saveLocation() async {
if (_selectedLocation == null) return;
try {
  final user = supabase.auth.currentUser;
  if (user == null) return;

  await supabase.from('saved_locations').insert({
    'user_id': user.id,
    'name': _selectedLocation!['name'],
    'description':
        _selectedLocation!['description'] ?? _selectedLocation!['address'],
    'latitude': _selectedLocation!['latitude'],
    'longitude': _selectedLocation!['longitude'],
    'category': _selectedCategory.name,
    'notes':
        _notesController.text.isEmpty ? null : _notesController.text,
    'saved_at': DateTime.now().toIso8601String(),
  });

  if (mounted) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location saved successfully!'),
        backgroundColor: successGreen,
      ),
    );
    widget.onLocationAdded();
  }
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
}
@override
void dispose() {
_searchController.dispose();
_notesController.dispose();
super.dispose();
}
}