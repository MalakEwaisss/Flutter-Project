// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/config.dart';
import '../main.dart'; // To access the global supabase client

class AuthModal extends StatefulWidget {
  final Function(Map<String, String>) onLoginSuccess;
  final Function(Map<String, String>)? onAdminLogin;

  const AuthModal({super.key, required this.onLoginSuccess, this.onAdminLogin});

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  bool _isLoginMode = true;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _handleSubmit(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    // Ben-check en el user mally kol el khanat
    if (email.isEmpty || password.isEmpty || (!_isLoginMode && name.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true); // Ebda2 el loading circle

    try {
      if (_isLoginMode) {
        // --- 1. ADMIN CHECK ---
        // Ben-shof law el email wel pass bto3 el admin elly el team 7addethom
        if (email.toLowerCase() == 'admin@travilo.app' && password == 'admin') {
          if (widget.onAdminLogin != null) {
            widget.onAdminLogin!({'name': 'Admin', 'email': email});
          }
          if (mounted) Navigator.pop(context);
          return;
        }

        // --- 2. REGULAR USER LOGIN ---
        final AuthResponse res = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (res.user != null) {
          // [FIX]: Ben-edi el app 500ms 3ashan y-save el session (token) 
          // fel memory, 3ashan el profile may-ollsh "login" tany.
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            widget.onLoginSuccess({
              'name': res.user!.userMetadata?['full_name'] ?? 'Traveler',
              'email': res.user!.email!,
            });
            Navigator.pop(context);
          }
        }
      } else {
        // --- 3. SIGN UP LOGIC ---
        final AuthResponse res = await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': name}, // Store el esm fel metadata bta3et Supabase
        );

        if (res.user != null) {
          // Law res.session null, dah ma3nah en el user lazim y-confirm el email
          if (res.session == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Check your email for a confirmation link!'),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            // [FIX]: Nafs el khattwa elly fo2, lazim n-estanna el session tet-sayeet.
            await Future.delayed(const Duration(milliseconds: 500));
            widget.onLoginSuccess({'name': name, 'email': email});
          }
          if (mounted) Navigator.pop(context);
        }
      }
    } on AuthException catch (error) {
      // Law fih error men Supabase (zay password ghalat)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } catch (error) {
      // Ay error tany ghair motawaqe3
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred')),
      );
    } finally {
      // Wa2af el loading loading circle f-kol el 7alat
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        // [FIX]: 3ashan el Keyboard lama yetla3 may-e3melsh overflow error (yellow lines)
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isLoginMode ? 'Welcome Back' : 'Join TravelHub',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 20),
              
              // TextField el esm bey-ban fel Sign Up bas
              if (!_isLoginMode)
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 15),
              
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              
              TextField(
                controller: _passwordController,
                obscureText: true, // 3ashan el password may-bansh
                decoration: const InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleSubmit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentOrange,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                          _isLoginMode ? 'Sign In' : 'Sign Up',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              // Text button 3ashan ne-ghayar bin el Login wel Signup
              TextButton(
                onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
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