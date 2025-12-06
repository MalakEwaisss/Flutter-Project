import 'package:flutter/material.dart';

import 'config.dart'; // For colors and AppPage

// --- AUTH MODAL WIDGET ---
class AuthModal extends StatefulWidget {
  // Signature changed to accept profile data map
  final Function(Map<String, String>) onLoginSuccess;
  const AuthModal({super.key, required this.onLoginSuccess});

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  bool _isLoginMode = true;
  // Initialize with sample data for quick testing/login mode
  final TextEditingController _emailController = TextEditingController(
    text: 'test@user.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'password123',
  );
  final TextEditingController _nameController = TextEditingController(
    text: 'New Explorer',
  );

  void _handleSubmit(BuildContext context) {
    // Basic validation check (simulated)
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        (!_isLoginMode && _nameController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all required fields.'),
          backgroundColor: accentOrange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // --- Prepare User Data to Pass Back ---
    final String userName = _isLoginMode
        ? 'Returning Traveler' // Default name for simple login
        : _nameController.text.trim();

    final userData = {
      'name': userName,
      'email': _emailController.text.trim(),
      // Stubbed defaults for new accounts
      'phone': '+1 555 123 4567',
      'bio': 'Tell us about your next adventure!',
      'location': 'Global',
    };

    // Simulate API call success
    Navigator.of(context).pop(); // Close modal
    widget.onLoginSuccess(userData); // Pass the new user data

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isLoginMode
              ? 'Welcome back! Logged in as ${userData['email']}'
              : 'Account created successfully! Welcome, $userName',
        ),
        backgroundColor: successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(30),
      title: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: primaryBlue,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Text(
          _isLoginMode ? 'Sign In to TravelHub' : 'Create Your Account',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400, // Fixed width for desktop modal
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name Field (Only for Sign Up)
              if (!_isLoginMode) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person, color: primaryBlue),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email, color: primaryBlue),
                ),
              ),
              const SizedBox(height: 20),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: primaryBlue),
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleSubmit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentOrange,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    _isLoginMode ? 'Sign In' : 'Sign Up',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Switch Mode Text
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                  });
                },
                child: Text(
                  _isLoginMode
                      ? 'Need an account? Sign Up'
                      : 'Already have an account? Sign In',
                  style: const TextStyle(
                    color: primaryBlue,
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
}
