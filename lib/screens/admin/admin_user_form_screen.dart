import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_profile.dart';
import '../../config/config.dart';

class AdminUserFormScreen extends StatefulWidget {
  final UserProfile? user;

  const AdminUserFormScreen({super.key, this.user});

  @override
  State<AdminUserFormScreen> createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final _avatarController = TextEditingController();
  bool _isLoading = false;

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _bioController.text = widget.user!.bio ?? '';
      _avatarController.text = widget.user!.avatar ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    bool success;

    if (isEditing) {
      success = await adminProvider.updateUser(
        userId: widget.user!.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        avatar: _avatarController.text.trim().isEmpty
            ? null
            : _avatarController.text.trim(),
      );
    } else {
      success = await adminProvider.createUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        avatar: _avatarController.text.trim().isEmpty
            ? null
            : _avatarController.text.trim(),
      );
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'User updated successfully'
                  : 'User created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminProvider.errorMessage ?? 'Failed to save user'),
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
          isEditing ? 'Edit User' : 'Create User',
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
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                enabled: !isEditing, // Email cannot be changed when editing
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!isEditing) ...[
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              _buildTextField(
                controller: _bioController,
                label: 'Bio (Optional)',
                icon: Icons.info,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _avatarController,
                label: 'Avatar URL (Optional)',
                icon: Icons.image,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveUser,
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
                        isEditing ? 'Update User' : 'Create User',
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
    bool obscureText = false,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      enabled: enabled,
      style: TextStyle(color: enabled ? Colors.white : Colors.white54),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: enabled ? Colors.white70 : Colors.white38),
        prefixIcon: Icon(icon, color: accentOrange),
        filled: true,
        fillColor: const Color(0xFF16213E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
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
