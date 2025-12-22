import 'package:flutter/material.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  String _selectedTripType = 'Solo';
  RangeValues _priceRange = const RangeValues(500, 5000);
  DateTimeRange? _selectedDateRange;

  final List<String> _tripTypes = ['Solo', 'Group', 'Family'];

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

  void _applyFilters() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters applied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedTripType = 'Solo';
      _priceRange = const RangeValues(500, 5000);
      _selectedDateRange = null;
    });
  }

  String _formatDateRange() {
    if (_selectedDateRange == null) {
      return 'Select date range';
    }
    final start = _selectedDateRange!.start;
    final end = _selectedDateRange!.end;
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(onPressed: _resetFilters, child: const Text('Reset')),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(title: 'Trip Type'),
              const SizedBox(height: 12),
              _TripTypeSelector(
                selectedType: _selectedTripType,
                tripTypes: _tripTypes,
                onTypeSelected: (type) {
                  setState(() {
                    _selectedTripType = type;
                  });
                },
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Price Range'),
              const SizedBox(height: 12),
              _PriceRangeCard(
                priceRange: _priceRange,
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Date Range'),
              const SizedBox(height: 12),
              _DateRangeCard(
                dateRange: _formatDateRange(),
                onTap: _selectDateRange,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
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

class _TripTypeSelector extends StatelessWidget {
  final String selectedType;
  final List<String> tripTypes;
  final ValueChanged<String> onTypeSelected;

  const _TripTypeSelector({
    required this.selectedType,
    required this.tripTypes,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: tripTypes.map((type) {
            final isSelected = type == selectedType;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _TripTypeChip(
                  label: type,
                  isSelected: isSelected,
                  onTap: () => onTypeSelected(type),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TripTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TripTypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              _getIconForType(label),
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onBackground,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onBackground,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Solo':
        return Icons.person;
      case 'Group':
        return Icons.group;
      case 'Family':
        return Icons.family_restroom;
      default:
        return Icons.person;
    }
  }
}

class _PriceRangeCard extends StatelessWidget {
  final RangeValues priceRange;
  final ValueChanged<RangeValues> onChanged;

  const _PriceRangeCard({required this.priceRange, required this.onChanged});

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
                Text(
                  '\$${priceRange.start.toInt()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                Text(
                  '\$${priceRange.end.toInt()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: priceRange,
              min: 0,
              max: 10000,
              divisions: 100,
              onChanged: onChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white
                  ),
                ),
                Text(
                  '\$10,000',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white
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
