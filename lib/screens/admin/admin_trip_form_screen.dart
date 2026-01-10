import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/trip_model.dart';
import '../../config/config.dart';

class AdminTripFormScreen extends StatefulWidget {
  final TripModel? trip;

  const AdminTripFormScreen({super.key, this.trip});

  @override
  State<AdminTripFormScreen> createState() => _AdminTripFormScreenState();
}

class _AdminTripFormScreenState extends State<AdminTripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _ratingController = TextEditingController();
  final _reviewsController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  final _imageController = TextEditingController();
  final _airlineController = TextEditingController();
  final _aircraftController = TextEditingController();
  final _classController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  bool get isEditing => widget.trip != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final trip = widget.trip!;
      _titleController.text = trip.title;
      _locationController.text = trip.location;
      _ratingController.text = trip.rating.toString();
      _reviewsController.text = trip.reviews.toString();
      _priceController.text = trip.price.toString();
      _dateController.text = trip.date;
      _imageController.text = trip.image ?? '';
      _airlineController.text = trip.airline ?? '';
      _aircraftController.text = trip.aircraft ?? '';
      _classController.text = trip.tripClass ?? '';
      _descriptionController.text = trip.description ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _ratingController.dispose();
    _reviewsController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _imageController.dispose();
    _airlineController.dispose();
    _aircraftController.dispose();
    _classController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final trip = TripModel(
      id: isEditing ? widget.trip!.id : '',
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      rating: double.parse(_ratingController.text.trim()),
      reviews: int.parse(_reviewsController.text.trim()),
      price: int.parse(_priceController.text.trim()),
      date: _dateController.text.trim(),
      image: _imageController.text.trim().isEmpty
          ? null
          : _imageController.text.trim(),
      airline: _airlineController.text.trim().isEmpty
          ? null
          : _airlineController.text.trim(),
      aircraft: _aircraftController.text.trim().isEmpty
          ? null
          : _aircraftController.text.trim(),
      tripClass: _classController.text.trim().isEmpty
          ? null
          : _classController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    bool success;

    if (isEditing) {
      success = await adminProvider.updateTrip(widget.trip!.id, trip);
    } else {
      success = await adminProvider.createTrip(trip);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Trip updated successfully'
                  : 'Trip created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminProvider.errorMessage ?? 'Failed to save trip'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          isEditing ? 'Edit Trip' : 'Create Trip',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Trip Title',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ratingController,
                      label: 'Rating (0-5)',
                      icon: Icons.star,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Rating is required';
                        }
                        final rating = double.tryParse(value);
                        if (rating == null || rating < 0 || rating > 5) {
                          return 'Rating must be between 0 and 5';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _reviewsController,
                      label: 'Reviews',
                      icon: Icons.rate_review,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Reviews is required';
                        }
                        final reviews = int.tryParse(value);
                        if (reviews == null || reviews < 0) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Price (\$)',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Price is required';
                        }
                        final price = int.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Price must be greater than 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _dateController,
                      label: 'Date Range',
                      icon: Icons.calendar_today,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Date is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _imageController,
                label: 'Image URL (Optional)',
                icon: Icons.image,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _airlineController,
                label: 'Airline (Optional)',
                icon: Icons.flight,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _aircraftController,
                label: 'Aircraft (Optional)',
                icon: Icons.airplanemode_active,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _classController,
                label: 'Class (Optional)',
                icon: Icons.airline_seat_recline_extra,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                icon: Icons.description,
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Trip' : 'Create Trip',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: accentOrange),
        filled: true,
        fillColor: const Color(0xFF16213E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentOrange),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
