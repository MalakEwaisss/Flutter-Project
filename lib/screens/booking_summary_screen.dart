import 'package:flutter/material.dart';
import '../config/config.dart';
import '../widgets/max_width_section.dart';
import '../main.dart';

class BookingSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;

  const BookingSummaryScreen({
    super.key,
    required this.trip,
    required this.navigateTo,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final TextEditingController _guestsController = TextEditingController(
    text: '1',
  );
  final TextEditingController _specialRequestsController =
      TextEditingController();
  final TextEditingController _seatNumberController = TextEditingController();
  bool _isLoading = false;
  DateTime? _selectedTravelDate;
  String? _selectedMeetingPoint;
  String? _selectedSeatCategory = 'Economy';
  final List<String> _seatCategories = ['Economy', 'Business', 'First Class'];

  @override
  void initState() {
    super.initState();
    if (widget.trip['_selectedMeetingPoint'] != null) {
      _selectedMeetingPoint = widget.trip['_selectedMeetingPoint'];
    }
  }

  @override
  void dispose() {
    _guestsController.dispose();
    _specialRequestsController.dispose();
    _seatNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmBooking() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to complete booking'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate number of guests
    if (_guestsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter number of guests'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final guestsCount = int.tryParse(_guestsController.text.trim());
    if (guestsCount == null || guestsCount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number of guests'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate travel date
    if (_selectedTravelDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a travel date'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final basePrice = widget.trip['price'] as int;
      final totalPrice = basePrice * guestsCount;

      await supabase.from('bookings').insert({
        'user_id': user.id,
        'trip_name': widget.trip['title'],
        'trip_id': widget.trip['id'],
        'location': widget.trip['location'],
        'trip_image': widget.trip['image'],
        'number_of_guests': guestsCount,
        'travel_date': _selectedTravelDate!.toIso8601String().split('T')[0],
        'meeting_point': _selectedMeetingPoint ?? 'Not selected',
        'special_requests': _specialRequestsController.text.trim(),
        'total_price': totalPrice,
        'booking_date': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        await _showSuccessDialog();
        widget.navigateTo(AppPage.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: successGreen,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                'Your trip to ${widget.trip['title']} has been successfully booked.',
                style: TextStyle(fontSize: 16, color: subtitleColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successGreen,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final guestsCount = int.tryParse(_guestsController.text.trim()) ?? 1;
    final basePrice = widget.trip['price'] as int;
    final totalPrice = basePrice * guestsCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Booking'),
        backgroundColor: primaryBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              widget.navigateTo(AppPage.tripDetails, trip: widget.trip),
        ),
      ),
      body: SingleChildScrollView(
        child: MaxWidthSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Trip Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trip Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.trip['image'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.trip['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.trip['location'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtitleColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '\$${widget.trip['price']} per person',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                'Booking Information',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Number of Guests
              TextField(
                controller: _guestsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of Guests',
                  hintText: 'Enter number of guests',
                  prefixIcon: const Icon(Icons.people, color: primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 20),

              // Travel Date Picker
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedTravelDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Travel Date',
                    prefixIcon: const Icon(
                      Icons.calendar_today,
                      color: primaryBlue,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTravelDate == null
                            ? 'Select travel date'
                            : '${_selectedTravelDate!.year}-${_selectedTravelDate!.month.toString().padLeft(2, '0')}-${_selectedTravelDate!.day.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: _selectedTravelDate == null
                              ? Colors.grey
                              : null,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: subtitleColor,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Seat Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSeatCategory,
                decoration: InputDecoration(
                  labelText: 'Seat Category',
                  prefixIcon: const Icon(
                    Icons.airline_seat_recline_extra,
                    color: primaryBlue,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                items: _seatCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedSeatCategory = newValue;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // Seat Number Input
              TextField(
                controller: _seatNumberController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Seat Number',
                  hintText: 'e.g., 19D, 23B, 4C',
                  prefixIcon: const Icon(Icons.event_seat, color: primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
              ),

              const SizedBox(height: 20),

              // Meeting Point Selection
              InkWell(
                onTap: () {
                  // Pass current booking data along with trip
                  final tripWithBookingData = Map<String, dynamic>.from(
                    widget.trip,
                  );
                  tripWithBookingData['_fromBooking'] = true;
                  widget.navigateTo(
                    AppPage.selectMeetingPoint,
                    trip: tripWithBookingData,
                  );
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Meeting Point',
                    prefixIcon: const Icon(Icons.place, color: primaryBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedMeetingPoint ??
                              'Tap to select meeting location',
                          style: TextStyle(
                            color: _selectedMeetingPoint == null
                                ? Colors.grey
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: subtitleColor,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Special Requests
              TextField(
                controller: _specialRequestsController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Special Requests (Optional)',
                  hintText: 'Any special requirements or requests...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.note, color: primaryBlue),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 30),

              // Price Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: primaryBlue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Price per person:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '\$${widget.trip['price']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Number of guests:',
                          style: TextStyle(fontSize: 16, color: subtitleColor),
                        ),
                        Text(
                          guestsCount.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$$totalPrice',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleConfirmBooking,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Processing...' : 'Confirm Booking',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
