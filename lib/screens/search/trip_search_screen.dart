import 'package:flutter/material.dart';

class TripSearchScreen extends StatefulWidget {
  const TripSearchScreen({super.key});

  @override
  State<TripSearchScreen> createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends State<TripSearchScreen> {
  final TextEditingController _destinationController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  double _budgetValue = 1000;

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _openFilters() {
    Navigator.pushNamed(context, '/filters');
  }

  void _performSearch() {
    Navigator.pushNamed(
      context,
      '/search-results',
      arguments: {
        'destination': _destinationController.text,
        'dateRange': _selectedDateRange,
        'budget': _budgetValue,
      },
    );
  }

  String _formatDateRange() {
    if (_selectedDateRange == null) {
      return 'Select dates';
    }
    final start = _selectedDateRange!.start;
    final end = _selectedDateRange!.end;
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(233, 250, 250, 250),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Search Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilters,
            tooltip: 'Filters',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(title: 'Where to?'),
              const SizedBox(height: 12),
              _DestinationField(controller: _destinationController),
              const SizedBox(height: 24),
              _SectionTitle(title: 'When?'),
              const SizedBox(height: 12),
              _DateRangeCard(
                dateRange: _formatDateRange(),
                onTap: _selectDateRange,
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Budget'),
              const SizedBox(height: 12),
              _BudgetSliderCard(
                value: _budgetValue,
                onChanged: (value) {
                  setState(() {
                    _budgetValue = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Search Trips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _PopularDestinations(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _DestinationField extends StatelessWidget {
  final TextEditingController controller;

  const _DestinationField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter destination',
            border: InputBorder.none,
            icon: Icon(Icons.location_on),
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class _DateRangeCard extends StatelessWidget {
  final String dateRange;
  final VoidCallback onTap;

  const _DateRangeCard({required this.dateRange, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 16),
              Expanded(
                child: Text(dateRange, style: const TextStyle(fontSize: 16)),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetSliderCard extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _BudgetSliderCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Max Budget',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: 100,
              max: 10000,
              divisions: 99,
              onChanged: onChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$100',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                Text(
                  '\$10,000',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onBackground.withOpacity(0.6),
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

class _PopularDestinations extends StatelessWidget {
  final List<String> destinations = [
    'Paris',
    'Tokyo',
    'New York',
    'Dubai',
    'London',
    'Rome',
  ];

  _PopularDestinations();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Popular Destinations'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: destinations.map((destination) {
            return ActionChip(
              label: Text(destination),
              onPressed: () {},
              backgroundColor: const Color(0xFFE0E7FF),
              labelStyle: const TextStyle(color: Color(0xFF1E3A8A)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
