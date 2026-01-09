import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/group_member.dart';
import 'package:provider/provider.dart';
import '../../config/config.dart';
import '../../models/group_model.dart';
import '../../providers/community_provider.dart';
import '../../widgets/community/member_tile.dart';
import '../../main.dart';
import 'invite_people_screen.dart';

class GroupMembersScreen extends StatefulWidget {
  final TripGroup group;

  const GroupMembersScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  String? _currentUserId;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = supabase.auth.currentUser?.id;
    _isOwner = widget.group.ownerId == _currentUserId;
  }

  Future<void> _removeMember(GroupMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove ${member.userName} from this group?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<CommunityProvider>(context, listen: false);
      final success = await provider.removeMember(widget.group.id, member.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.userName} has been removed'),
            backgroundColor: successGreen,
          ),
        );
        setState(() {}); // Refresh UI
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove member'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToInvitePeople() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvitePeopleScreen(group: widget.group),
      ),
    );
  }

  Future<void> _editGroup() async {
    final nameController = TextEditingController(text: widget.group.groupName);
    final descController = TextEditingController(text: widget.group.description ?? '');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Edit Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'group_name': nameController.text,
                'description': descController.text,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      final provider = Provider.of<CommunityProvider>(context, listen: false);
      final success = await provider.updateGroup(widget.group.id, result);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group updated successfully'),
            backgroundColor: successGreen,
          ),
        );
        Navigator.pop(context); // Go back to refresh
      }
    }
  }

  Future<void> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Group'),
        content: const Text(
          'Are you sure you want to delete this group? This action cannot be undone and all members will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<CommunityProvider>(context, listen: false);
      final success = await provider.deleteGroup(widget.group.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group deleted successfully'),
            backgroundColor: successGreen,
          ),
        );
        Navigator.pop(context); // Go back to community screen
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete group'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showGroupInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Group Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRow(
                      Icons.groups,
                      'Group Name',
                      widget.group.groupName,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.flight_takeoff,
                      'Trip',
                      widget.group.tripName,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.location_on,
                      'Destination',
                      widget.group.destination,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Travel Date',
                      widget.group.tripDate,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.person,
                      'Owner',
                      widget.group.ownerName,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      widget.group.isPublic ? Icons.public : Icons.lock,
                      'Visibility',
                      widget.group.isPublic ? 'Public' : 'Private',
                    ),
                    if (widget.group.description != null &&
                        widget.group.description!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.group.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.groupName),
        backgroundColor: primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showGroupInfo,
            tooltip: 'Group Info',
          ),
          if (_isOwner) ...[
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.edit, color: primaryBlue),
                      SizedBox(width: 8),
                      Text('Edit Group'),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(Duration.zero, () => _editGroup());
                  },
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Group'),
                    ],
                  ),
                  onTap: () {
                    Future.delayed(Duration.zero, () => _deleteGroup());
                  },
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Group Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue.withOpacity(0.1), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.groups,
                    size: 40,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${widget.group.memberCount} ${widget.group.memberCount == 1 ? 'Member' : 'Members'}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.flight_takeoff,
                      size: 16,
                      color: subtitleColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.group.tripName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Members List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.group.members.length,
              itemBuilder: (context, index) {
                final member = widget.group.members[index];
                final isCurrentUser = member.userId == _currentUserId;

                return MemberTile(
                  member: member,
                  showRemoveButton: _isOwner && !member.isOwner,
                  onRemove: () => _removeMember(member),
                  isCurrentUser: isCurrentUser,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isOwner
          ? FloatingActionButton.extended(
              onPressed: _navigateToInvitePeople,
              backgroundColor: accentOrange,
              icon: const Icon(Icons.person_add),
              label: const Text(
                'Invite People',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}