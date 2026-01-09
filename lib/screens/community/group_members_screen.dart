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
  bool _isMember = false;
  bool _hasRequestedToJoin = false;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = supabase.auth.currentUser?.id;
    _isOwner = widget.group.ownerId == _currentUserId;
    _isMember = widget.group.members.any((m) => m.userId == _currentUserId);
    _checkJoinRequestStatus();
  }

  Future<void> _checkJoinRequestStatus() async {
    if (_currentUserId == null || _isMember || _isOwner) return;
    
    try {
      final request = await supabase
          .from('join_requests')
          .select()
          .eq('group_id', widget.group.id)
          .eq('user_id', _currentUserId!)
          .eq('status', 'pending')
          .maybeSingle();
      
      setState(() {
        _hasRequestedToJoin = request != null;
      });
    } catch (e) {
      debugPrint('Error checking join request: $e');
    }
  }

  Future<void> _handleJoinGroup() async {
    setState(() => _isJoining = true);
    
    final provider = Provider.of<CommunityProvider>(context, listen: false);
    final success = await provider.joinGroup(widget.group.id, widget.group);
    
    setState(() => _isJoining = false);
    
    if (success && mounted) {
      if (widget.group.isPublic) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the group!'),
            backgroundColor: successGreen,
          ),
        );
        Navigator.pop(context); // Refresh by going back
      } else {
        setState(() => _hasRequestedToJoin = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Join request sent! Waiting for owner approval.'),
            backgroundColor: successGreen,
          ),
        );
      }
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        Navigator.pop(context);
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

  void _navigateToAddPeople() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvitePeopleScreen(group: widget.group),
      ),
    ).then((_) {
      Navigator.pop(context);
    });
  }

  Future<void> _editGroup() async {
    final nameController = TextEditingController(text: widget.group.groupName);
    final descController = TextEditingController(text: widget.group.description ?? '');
    bool isPublic = widget.group.isPublic;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Edit Group'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 20),
                const Text(
                  'Group Visibility',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPublic
                        ? successGreen.withOpacity(0.1)
                        : accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPublic ? successGreen : accentOrange,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPublic ? Icons.public : Icons.lock,
                            color: isPublic ? successGreen : accentOrange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isPublic ? 'Public Group' : 'Private Group',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isPublic ? successGreen : accentOrange,
                              ),
                            ),
                          ),
                          Switch(
                            value: isPublic,
                            onChanged: (value) {
                              setDialogState(() {
                                isPublic = value;
                              });
                            },
                            activeColor: successGreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPublic
                            ? 'Anyone can join this group instantly'
                            : 'Users must request to join and wait for approval',
                        style: const TextStyle(
                          fontSize: 12,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                  'is_public': isPublic,
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
        Navigator.pop(context);
      } else if (mounted && provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.red,
          ),
        );
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
        Navigator.pop(context);
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
                      widget.group.isPublic ? 'Public (Anyone can join)' : 'Private (Request required)',
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
    // Show limited view if not a member of private group
    final canViewMembers = widget.group.isPublic || _isMember || _isOwner;
    
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
                if (canViewMembers) ...[
                  Text(
                    '${widget.group.memberCount} ${widget.group.memberCount == 1 ? 'Member' : 'Members'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Private Group',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.group.isPublic ? Icons.public : Icons.lock,
                      size: 16,
                      color: widget.group.isPublic ? successGreen : accentOrange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.group.isPublic ? 'Public Group' : 'Private Group',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.group.isPublic ? successGreen : accentOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
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

          // Content based on access level
          Expanded(
            child: canViewMembers
                ? _buildMembersList()
                : _buildPrivateGroupView(),
          ),
        ],
      ),
      floatingActionButton: _isOwner && canViewMembers
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddPeople,
              backgroundColor: accentOrange,
              icon: const Icon(Icons.person_add),
              label: const Text(
                'Add People',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildMembersList() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        final pendingRequests = provider.getPendingRequests(widget.group.id);
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Pending Join Requests (only visible to owner)
            if (_isOwner && pendingRequests.isNotEmpty) ...[
              const Text(
                'Pending Join Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: accentOrange,
                ),
              ),
              const SizedBox(height: 12),
              ...pendingRequests.map((request) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentOrange),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryBlue.withOpacity(0.1),
                      child: request.userAvatar != null
                          ? ClipOval(
                              child: Image.network(
                                request.userAvatar!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.person, color: primaryBlue);
                                },
                              ),
                            )
                          : const Icon(Icons.person, color: primaryBlue),
                    ),
                    title: Text(
                      request.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(request.userEmail),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: successGreen),
                          onPressed: () async {
                            final success = await provider.approveJoinRequest(
                              request.id,
                              widget.group.id,
                            );
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${request.userName} approved'),
                                  backgroundColor: successGreen,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          tooltip: 'Approve',
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () async {
                            final success = await provider.rejectJoinRequest(request.id);
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${request.userName} rejected'),
                                  backgroundColor: Colors.grey,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                          tooltip: 'Reject',
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // Members List
            const Text(
              'Members',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.group.members.map((member) {
              final isCurrentUser = member.userId == _currentUserId;

              return MemberTile(
                member: member,
                showRemoveButton: _isOwner && !member.isOwner,
                onRemove: () => _removeMember(member),
                isCurrentUser: isCurrentUser,
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildPrivateGroupView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Private Group',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _hasRequestedToJoin
                  ? 'Your join request is pending.\nWaiting for owner approval.'
                  : 'This is a private group.\nRequest to join to see members.',
              style: const TextStyle(
                fontSize: 16,
                color: subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (!_hasRequestedToJoin)
              ElevatedButton.icon(
                onPressed: _isJoining ? null : _handleJoinGroup,
                icon: _isJoining
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.person_add),
                label: Text(_isJoining ? 'Requesting...' : 'Request to Join'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentOrange),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, color: accentOrange),
                    SizedBox(width: 12),
                    Text(
                      'Request Pending',
                      style: TextStyle(
                        color: accentOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}