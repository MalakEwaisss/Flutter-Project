import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/config/trip_data.dart';
import 'package:flutter_application_1/models/group_member.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:flutter_application_1/providers/community_provider.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedTripId;
  Map<String, dynamic>? _selectedTrip;
  bool _isCreating = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTrip == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a trip'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    final provider = Provider.of<CommunityProvider>(context, listen: false);
    
    final newGroup = TripGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupName: _groupNameController.text.trim(),
      tripId: _selectedTrip!['id'],
      tripName: _selectedTrip!['title'],
      destination: _selectedTrip!['location'],
      tripDate: _selectedTrip!['date'],
      description: _descriptionController.text.trim(),
      ownerId: 'current_user',
      ownerName: 'Current User',
      createdAt: DateTime.now().toIso8601String(),
      groupImage: _selectedTrip!['image'],
      members: [
        GroupMember(
          id: 'm1',
          userId: 'current_user',
          userName: 'Current User',
          userEmail: 'user@example.com',
          role: 'owner',
          joinedAt: DateTime.now().toIso8601String(),
        ),
      ],
    );

    final success = await provider.createGroup(newGroup);

    setState(() => _isCreating = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group created successfully!'),
          backgroundColor: successGreen,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create group'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTripPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Column(
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
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Select a Trip',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: allTrips.length,
                    itemBuilder: (context, index) {
                      final trip = allTrips[index];
                      final isSelected = _selectedTripId == trip['id'];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? primaryBlue : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? primaryBlue.withOpacity(0.05)
                              : Colors.transparent,
                        ),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              _selectedTripId = trip['id'];
                              _selectedTrip = trip;
                            });
                            Navigator.pop(context);
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              trip['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            trip['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? primaryBlue : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(trip['location']),
                              const SizedBox(height: 2),
                              Text(
                                trip['date'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: primaryBlue,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Group'),
        backgroundColor: primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Group Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create a group to connect with travelers on the same trip',
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(height: 32),

              // Group Name
              TextFormField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  labelText: 'Group Name *',
                  hintText: 'e.g., Bali Beach Explorers',
                  prefixIcon: const Icon(Icons.groups, color: primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a group name';
                  }
                  if (value.trim().length < 3) {
                    return 'Group name must be at least 3 characters';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),

              // Trip Selection
              InkWell(
                onTap: _showTripPicker,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Select Trip *',
                    prefixIcon: const Icon(Icons.flight_takeoff, color: primaryBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedTrip != null
                              ? _selectedTrip!['title']
                              : 'Tap to select a trip',
                          style: TextStyle(
                            color: _selectedTrip != null
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: subtitleColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Tell travelers about your group...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description, color: primaryBlue),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),

              // Selected Trip Preview
              if (_selectedTrip != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Trip',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _selectedTrip!['image'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedTrip!['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedTrip!['location'],
                                  style: const TextStyle(
                                    color: subtitleColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedTrip!['date'],
                                  style: const TextStyle(
                                    color: subtitleColor,
                                    fontSize: 12,
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
                const SizedBox(height: 32),
              ],

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isCreating ? null : _createGroup,
                  icon: _isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_circle),
                  label: Text(
                    _isCreating ? 'Creating...' : 'Create Group',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '* Required fields',
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor.withOpacity(0.7),
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