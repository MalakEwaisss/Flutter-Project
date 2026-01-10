import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../config/config.dart';
import 'admin_user_form_screen.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: adminProvider.isLoadingUsers
          ? const Center(child: CircularProgressIndicator(color: accentOrange))
          : adminProvider.users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.white30),
                  const SizedBox(height: 16),
                  const Text(
                    'No users found',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: adminProvider.users.length,
              itemBuilder: (context, index) {
                final user = adminProvider.users[index];
                return Card(
                  color: const Color(0xFF16213E),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: accentOrange.withOpacity(0.2),
                      child: user.avatar != null && user.avatar!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                user.avatar!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.person, color: accentOrange),
                              ),
                            )
                          : Icon(Icons.person, color: accentOrange),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (user.bio != null && user.bio!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.bio!,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editUser(context, user),
                          tooltip: 'Edit User',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _deleteUser(context, user.id, user.name),
                          tooltip: 'Delete User',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createUser(context),
        backgroundColor: accentOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add User',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _createUser(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminUserFormScreen()),
    );
  }

  void _editUser(BuildContext context, user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminUserFormScreen(user: user)),
    );
  }

  void _deleteUser(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Delete User', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "$userName"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final adminProvider = Provider.of<AdminProvider>(
                context,
                listen: false,
              );
              final success = await adminProvider.deleteUser(userId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'User deleted successfully'
                          : 'Failed to delete user',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
