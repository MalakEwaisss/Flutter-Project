import 'package:flutter/material.dart';

import 'config.dart';
import 'widgets_reusable.dart';

// -----------------------------------------------------------------
// --- 2. TRIP LIST SCREEN ---
// -----------------------------------------------------------------

class TripsScreen extends StatelessWidget {
  final Function(AppPage) navigateTo;
  final bool isLoggedIn;
  final Function(BuildContext context) showAuthModal;

  const TripsScreen({
    super.key,
    required this.navigateTo,
    required this.isLoggedIn,
    required this.showAuthModal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Bar
        CustomAppBar(
          navigateTo: navigateTo,
          currentPage: AppPage.trips,
          isLoggedIn: isLoggedIn,
          onAuthAction: () => showAuthModal(context),
        ),

        // Main Content Area
        Expanded(
          child: SingleChildScrollView(
            child: MaxWidthSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended Trips (7 Results)',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Showing results based on your search filter: Asia, 2 Travelers.',
                    style: TextStyle(fontSize: 18, color: subtitleColor),
                  ),
                  const SizedBox(height: 30),

                  // Responsive Trip Grid
                  GridView.builder(
                    physics:
                        const NeverScrollableScrollPhysics(), // Handled by outer SingleChildScrollView
                    shrinkWrap: true,
                    itemCount: allTrips.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 350, // Max width of each item
                          childAspectRatio: 0.7, // Aspect ratio (taller card)
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 32,
                        ),
                    itemBuilder: (context, index) {
                      return PopularTripCard(
                        trip: allTrips[index],
                        navigateTo: navigateTo,
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------
// --- 3. PROFILE / EDIT PROFILE UI ---
// -----------------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  final Function(AppPage) navigateTo;
  final VoidCallback onLogout;
  final Map<String, String> initialUserData;
  final bool isLoggedIn;
  final Function(BuildContext context) showAuthModal; // For the App Bar

  const ProfileScreen({
    super.key,
    required this.navigateTo,
    required this.onLogout,
    required this.initialUserData,
    required this.isLoggedIn,
    required this.showAuthModal,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers using the data passed from the AppState
    _nameController = TextEditingController(
      text: widget.initialUserData['name'] ?? 'Guest User',
    );
    _emailController = TextEditingController(
      text: widget.initialUserData['email'] ?? 'N/A',
    );
    _phoneController = TextEditingController(
      text: widget.initialUserData['phone'] ?? '+1 555 123 4567',
    );
    _bioController = TextEditingController(
      text:
          widget.initialUserData['bio'] ?? 'Tell us about your next adventure!',
    );
    _locationController = TextEditingController(
      text: widget.initialUserData['location'] ?? 'Global',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    setState(() {
      _isEditing = false;
    });
    // NOTE: In a real app, this would update the user data in the AppState/Database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile saved successfully! Welcome, ${_nameController.text}.',
        ),
        backgroundColor: successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Bar
        CustomAppBar(
          navigateTo: widget.navigateTo,
          currentPage: AppPage.profile,
          isLoggedIn: widget.isLoggedIn, // Must be true here
          onAuthAction: () => widget.showAuthModal(context), // Pass auth action
        ),

        // Main Content Area
        Expanded(
          child: SingleChildScrollView(
            child: MaxWidthSection(
              verticalPadding: 30,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header and Toggle Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isEditing ? 'Edit Profile' : 'User Profile',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),

                          // Edit/Save Button and Logout Button
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit/Save Button
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (_isEditing) {
                                    _saveProfile();
                                  } else {
                                    setState(() => _isEditing = true);
                                  }
                                },
                                icon: Icon(
                                  _isEditing ? Icons.save : Icons.edit,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  _isEditing ? 'Save Changes' : 'Edit Profile',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isEditing
                                      ? successGreen
                                      : accentOrange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                ),
                              ),

                              // Logout Button (Only visible when viewing, not editing)
                              if (!_isEditing)
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      widget
                                          .onLogout(); // Call the logout action
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'You have been logged out.',
                                          ),
                                          backgroundColor: primaryBlue,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.logout,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 40, color: lightBackground),

                      // Profile Avatar
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 70,
                            backgroundColor: lightBackground,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/300?img=50',
                            ),
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: subtitleColor,
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: primaryBlue,
                                radius: 20,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Photo upload simulated!',
                                        ),
                                        backgroundColor: primaryBlue,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Profile Fields Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        childAspectRatio: 3.5,
                        crossAxisSpacing: 30,
                        mainAxisSpacing: 25,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // Name
                          _ProfileField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.badge,
                            isEditing: _isEditing,
                          ),
                          // Email
                          _ProfileField(
                            controller: _emailController,
                            label: 'Email Address',
                            icon: Icons.email,
                            isEditing: _isEditing,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          // Phone
                          _ProfileField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone,
                            isEditing: _isEditing,
                            keyboardType: TextInputType.phone,
                          ),
                          // Location
                          _ProfileField(
                            controller: _locationController,
                            label: 'Location',
                            icon: Icons.location_on,
                            isEditing: _isEditing,
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Bio Field (Full Width)
                      _ProfileField(
                        controller: _bioController,
                        label: 'Bio / About Me',
                        icon: Icons.notes,
                        isEditing: _isEditing,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // Danger Zone (Only visible when viewing, simulating settings/password change)
                      if (!_isEditing) ...[
                        const Divider(height: 40, color: lightBackground),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Account Settings',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Change Password',
                                style: TextStyle(color: accentOrange),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Reusable Profile Input/Display Field
class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isEditing;
  final TextInputType keyboardType;
  final int maxLines;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isEditing,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: !isEditing,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: subtitleColor, size: 20),
            filled: true, // Always filled for a clean look
            fillColor: isEditing
                ? lightBackground.withOpacity(0.5)
                : lightBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryBlue, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
