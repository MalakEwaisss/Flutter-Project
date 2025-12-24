import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/providers/community_provider.dart';
import 'package:flutter_application_1/widgets/community/invite_user_tile.dart';
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
  bool _isInviting = false;
  bool _isLoadingUsers = true;

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

  // UPDATED METHOD - Load users from Firebase
  void _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    
    final provider = Provider.of<CommunityProvider>(context, listen: false);
    await provider.loadSuggestedUsers(excludeGroupId: widget.group.id);
    
    setState(() {
      _displayedUsers = provider.suggestedUsers;
      _isLoadingUsers = false;
    });
  }

  // UPDATED METHOD - Search users from Firebase
  void _searchUsers(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoadingUsers = true;
    });

    final provider = Provider.of<CommunityProvider>(context, listen: false);
    final results = await provider.searchUsers(
      query,
      excludeGroupId: widget.group.id,
    );
    
    setState(() {
      _displayedUsers = results;
      _isLoadingUsers = false;
    });
  }

  Future<void> _inviteUser(UserProfile user) async {
    setState(() => _isInviting = true);

    final provider = Provider.of<CommunityProvider>(context, listen: false);
    final success = await provider.inviteUser(widget.group.id, user);

    setState(() => _isInviting = false);

    if (success && mounted) {
      // Remove the invited user from the list
      setState(() {
        _displayedUsers.removeWhere((u) => u.id == user.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} has been invited to the group'),
          backgroundColor: successGreen,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send invitation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite People'),
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
                        'Inviting to',
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
                  _searchQuery.isEmpty ? 'Suggested Users' : 'Search Results',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_isLoadingUsers && _displayedUsers.isNotEmpty)
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
            child: _isLoadingUsers
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading users...',
                          style: TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : _displayedUsers.isEmpty
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
                                  ? 'All users are already members'
                                  : 'Try a different search term',
                              style: const TextStyle(
                                fontSize: 14,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _displayedUsers.length,
                        itemBuilder: (context, index) {
                          final user = _displayedUsers[index];
                          return InviteUserTile(
                            user: user,
                            onInvite: () => _inviteUser(user),
                            isInviting: _isInviting,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}