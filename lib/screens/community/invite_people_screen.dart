import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/providers/community_provider.dart';
import 'package:provider/provider.dart';

class InvitePeopleScreen extends StatefulWidget {
  final TripGroup group;

  const InvitePeopleScreen({
    super.key,
    required this.group,
  });

  @override
  State<InvitePeopleScreen> createState() => _InvitePeopleScreenState();
}

class _InvitePeopleScreenState extends State<InvitePeopleScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserProfile> _displayedUsers = [];
  String _searchQuery = '';
  bool _isAdding = false;
  final Set<String> _addedUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    final provider = Provider.of<CommunityProvider>(context, listen: false);
    
    // Filter out users who are already members
    final existingMemberIds = widget.group.members.map((m) => m.userId).toSet();
    
    setState(() {
      _displayedUsers = provider.suggestedUsers
          .where((user) => !existingMemberIds.contains(user.id))
          .toList();
    });
  }

  void _searchUsers(String query) {
    setState(() {
      _searchQuery = query;
    });

    final provider = Provider.of<CommunityProvider>(context, listen: false);
    final existingMemberIds = widget.group.members.map((m) => m.userId).toSet();
    
    setState(() {
      _displayedUsers = provider.searchUsers(query)
          .where((user) => !existingMemberIds.contains(user.id))
          .toList();
    });
  }

  Future<void> _addUser(UserProfile user) async {
    setState(() => _isAdding = true);

    final provider = Provider.of<CommunityProvider>(context, listen: false);
    final success = await provider.addMemberToGroup(widget.group.id, user);

    setState(() => _isAdding = false);

    if (success && mounted) {
      setState(() {
        _addedUserIds.add(user.id);
        _displayedUsers.removeWhere((u) => u.id == user.id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} has been added to the group'),
          backgroundColor: successGreen,
          action: SnackBarAction(
            label: 'Done',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to add member'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add People'),
        backgroundColor: primaryBlue,
      ),
      body: Column(
        children: [
          // Group Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: primaryBlue.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.groups,
                    color: primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adding to',
                        style: TextStyle(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.group.groupName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: const Icon(Icons.search, color: primaryBlue),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchUsers('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),

          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchQuery.isEmpty ? 'Available Users' : 'Search Results',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_displayedUsers.isNotEmpty)
                  Text(
                    '${_displayedUsers.length} ${_displayedUsers.length == 1 ? 'user' : 'users'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Users List
          Expanded(
            child: _displayedUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No users available'
                              : 'No users found',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'All users are already members or no other users exist'
                              : 'Try a different search term',
                          style: const TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _displayedUsers.length,
                    itemBuilder: (context, index) {
                      final user = _displayedUsers[index];
                      final isAdded = _addedUserIds.contains(user.id);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: primaryBlue.withOpacity(0.1),
                            child: user.avatar != null
                                ? ClipOval(
                                    child: Image.network(
                                      user.avatar!,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildAvatarPlaceholder();
                                      },
                                    ),
                                  )
                                : _buildAvatarPlaceholder(),
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: subtitleColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (user.bio != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  user.bio!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subtitleColor.withOpacity(0.8),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                          trailing: isAdded
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: successGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: successGreen),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: successGreen,
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Added',
                                        style: TextStyle(
                                          color: successGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed: _isAdding
                                      ? null
                                      : () => _addUser(user),
                                  icon: _isAdding
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.person_add, size: 18),
                                  label: Text(_isAdding ? 'Adding...' : 'Add'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentOrange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Icon(
      Icons.person,
      size: 32,
      color: primaryBlue.withOpacity(0.5),
    );
  }
}