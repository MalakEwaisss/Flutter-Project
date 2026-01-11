import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/group_member.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import '../main.dart';

class JoinRequest {
  final String id;
  final String groupId;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userAvatar;
  final String requestedAt;
  final String status; // 'pending', 'approved', 'rejected'

  JoinRequest({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userAvatar,
    required this.requestedAt,
    required this.status,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    return JoinRequest(
      id: json['id'].toString(),
      groupId: json['group_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      userAvatar: json['user_avatar'],
      requestedAt: json['requested_at'],
      status: json['status'],
    );
  }
}

class CommunityProvider with ChangeNotifier {
  List<TripGroup> _groups = [];
  List<UserProfile> _suggestedUsers = [];
  Map<String, List<JoinRequest>> _pendingRequests = {};
  bool _isLoading = false;
  String? _error;
  bool _showPublicOnly = true;

  List<TripGroup> get groups => _groups;
  List<UserProfile> get suggestedUsers => _suggestedUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showPublicOnly => _showPublicOnly;

  List<JoinRequest> getPendingRequests(String groupId) {
    return _pendingRequests[groupId] ?? [];
  }

  void toggleGroupVisibility() {
    _showPublicOnly = !_showPublicOnly;
    notifyListeners();
    loadGroups();
  }

  /// Load groups from Supabase
  Future<void> loadGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      List<dynamic> groupsData;

      if (_showPublicOnly) {
        // Load all groups (public and private are visible to everyone)
        groupsData = await supabase
            .from('trip_groups')
            .select()
            .order('created_at', ascending: false);
      } else {
        // Load groups user is a member of
        final memberRows =
            await supabase
                    .from('group_members')
                    .select('group_id')
                    .eq('user_id', user.id)
                as List<dynamic>;
        final groupIds = memberRows.map((r) => r['group_id']).toList();

        if (groupIds.isEmpty) {
          groupsData = [];
        } else {
          groupsData = await supabase
              .from('trip_groups')
              .select()
              .filter('id', 'in', '(${groupIds.join(',')})')
              .order('created_at', ascending: false);
        }
      }

      // Load members for each group (with visibility control)
      List<TripGroup> loadedGroups = [];
      for (var groupData in groupsData) {
        final groupId = groupData['id'].toString();
        final isPublic = groupData['is_public'] ?? true;
        final isOwner = groupData['owner_id'] == user.id;

        // Check if user is a member
        final isMember = await _isUserMember(groupId, user.id);

        // Only load members if group is public OR user is owner/member
        List<GroupMember> members = [];
        if (isPublic || isOwner || isMember) {
          final membersData = await supabase
              .from('group_members')
              .select()
              .eq('group_id', groupId)
              .order('joined_at', ascending: true);

          members = (membersData as List)
              .map((m) => GroupMember.fromJson(m))
              .toList();
        }

        loadedGroups.add(
          TripGroup(
            id: groupId,
            groupName: groupData['group_name'],
            tripId: groupData['trip_id'],
            tripName: groupData['trip_name'],
            destination: groupData['destination'],
            tripDate: groupData['trip_date'],
            description: groupData['description'],
            ownerId: groupData['owner_id'],
            ownerName: groupData['owner_name'],
            members: members,
            createdAt: groupData['created_at'],
            groupImage: groupData['group_image'],
            isPublic: isPublic,
          ),
        );

        // Load pending requests for owned groups
        if (isOwner) {
          await _loadPendingRequests(groupId);
        }
      }

      _groups = loadedGroups;
      await loadSuggestedUsers();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading groups: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _isUserMember(String groupId, String userId) async {
    try {
      final result = await supabase
          .from('group_members')
          .select()
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();
      return result != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadPendingRequests(String groupId) async {
    try {
      final requestsData = await supabase
          .from('join_requests')
          .select()
          .eq('group_id', groupId)
          .eq('status', 'pending')
          .order('requested_at', ascending: false);

      _pendingRequests[groupId] = (requestsData as List)
          .map((r) => JoinRequest.fromJson(r))
          .toList();
    } catch (e) {
      debugPrint('Error loading pending requests: $e');
    }
  }

  /// Load ALL authenticated users from Supabase Auth
  Future<void> loadSuggestedUsers() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Use Supabase Admin API to list all users
      // Note: This requires proper RLS policies or a server-side function
      // For now, we'll get users who have user metadata set

      // Get all unique users from auth.users via their metadata
      // Since we can't directly query auth.users, we use a workaround:
      // 1. Get users from group_members
      // 2. Get users from trip_groups owners
      // 3. Query for all users who have logged in (via a profiles table if you have one)

      final Map<String, UserProfile> uniqueUsers = {};

      // Strategy 1: Get from group members
      final allMembersData = await supabase
          .from('group_members')
          .select('user_id, user_name, user_email, user_avatar');

      for (var member in allMembersData as List) {
        final userId = member['user_id'];
        if (userId != user.id && !uniqueUsers.containsKey(userId)) {
          uniqueUsers[userId] = UserProfile(
            id: userId,
            name: member['user_name'] ?? 'User',
            email: member['user_email'] ?? '',
            avatar: member['user_avatar'],
            bio: null,
          );
        }
      }

      // Strategy 2: Get from group owners
      final allOwnersData = await supabase
          .from('trip_groups')
          .select('owner_id, owner_name');

      for (var owner in allOwnersData as List) {
        final userId = owner['owner_id'];
        if (userId != user.id && !uniqueUsers.containsKey(userId)) {
          uniqueUsers[userId] = UserProfile(
            id: userId,
            name: owner['owner_name'] ?? 'User',
            email: '',
            avatar: null,
            bio: null,
          );
        }
      }

      // Strategy 3: If you have a profiles table, query it
      // This is the BEST approach - create a profiles table that syncs with auth.users
      try {
        final profilesData = await supabase
            .from('profiles')
            .select('id, full_name, email, avatar_url, bio');

        for (var profile in profilesData as List) {
          final userId = profile['id'];
          if (userId != user.id) {
            uniqueUsers[userId] = UserProfile(
              id: userId,
              name: profile['full_name'] ?? profile['email'] ?? 'User',
              email: profile['email'] ?? '',
              avatar: profile['avatar_url'],
              bio: profile['bio'],
            );
          }
        }
      } catch (e) {
        // Profiles table might not exist, that's okay
        debugPrint('Profiles table not available: $e');
      }

      _suggestedUsers = uniqueUsers.values.toList();
      notifyListeners();
    } catch (e) {
      _suggestedUsers = [];
      debugPrint('Could not load suggested users: $e');
    }
  }

  /// Create a new group with unique name validation
  Future<bool> createGroup(TripGroup group) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if group name already exists
      final existing = await supabase
          .from('trip_groups')
          .select()
          .eq('group_name', group.groupName)
          .maybeSingle();

      if (existing != null) {
        _error =
            'A group with this name already exists. Please choose a different name.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Insert group
      await supabase.from('trip_groups').insert({
        'group_name': group.groupName,
        'trip_id': group.tripId,
        'trip_name': group.tripName,
        'destination': group.destination,
        'trip_date': group.tripDate,
        'description': group.description,
        'owner_id': user.id,
        'owner_name': group.ownerName,
        'group_image': group.groupImage,
        'is_public': group.isPublic,
      });

      // Reload groups to get the updated list
      await loadGroups();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error creating group: $e');
      return false;
    }
  }

  /// Join a PUBLIC group immediately OR request to join a PRIVATE group
  Future<bool> joinGroup(String groupId, TripGroup group) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if already a member
      final isMember = await _isUserMember(groupId, user.id);
      if (isMember) {
        _error = 'You are already a member of this group';
        notifyListeners();
        return false;
      }

      if (group.isPublic) {
        // PUBLIC GROUP: Join immediately
        await supabase.from('group_members').insert({
          'group_id': groupId,
          'user_id': user.id,
          'user_name': user.userMetadata?['full_name'] ?? 'User',
          'user_email': user.email,
          'user_avatar': user.userMetadata?['avatar_url'],
          'role': 'member',
        });

        await loadGroups();
        return true;
      } else {
        // PRIVATE GROUP: Create join request
        return await requestToJoinGroup(groupId, group);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error joining group: $e');
      return false;
    }
  }

  /// Request to join a private group
  Future<bool> requestToJoinGroup(String groupId, TripGroup group) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if already requested
      final existingRequest = await supabase
          .from('join_requests')
          .select()
          .eq('group_id', groupId)
          .eq('user_id', user.id)
          .eq('status', 'pending')
          .maybeSingle();

      if (existingRequest != null) {
        _error = 'You have already requested to join this group';
        notifyListeners();
        return false;
      }

      // Create join request
      await supabase.from('join_requests').insert({
        'group_id': groupId,
        'user_id': user.id,
        'user_name': user.userMetadata?['full_name'] ?? 'User',
        'user_email': user.email,
        'user_avatar': user.userMetadata?['avatar_url'],
        'status': 'pending',
      });

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error requesting to join group: $e');
      return false;
    }
  }

  /// Approve join request
  Future<bool> approveJoinRequest(String requestId, String groupId) async {
    try {
      // Get request details
      final request = await supabase
          .from('join_requests')
          .select()
          .eq('id', requestId)
          .single();

      // Add user to group members
      await supabase.from('group_members').insert({
        'group_id': groupId,
        'user_id': request['user_id'],
        'user_name': request['user_name'],
        'user_email': request['user_email'],
        'user_avatar': request['user_avatar'],
        'role': 'member',
      });

      // Update request status
      await supabase
          .from('join_requests')
          .update({'status': 'approved'})
          .eq('id', requestId);

      // Reload data
      await loadGroups();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error approving request: $e');
      return false;
    }
  }

  /// Reject join request
  Future<bool> rejectJoinRequest(String requestId) async {
    try {
      await supabase
          .from('join_requests')
          .update({'status': 'rejected'})
          .eq('id', requestId);

      // Reload data
      await loadGroups();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error rejecting request: $e');
      return false;
    }
  }

  /// Update group details (including visibility)
  Future<bool> updateGroup(String groupId, Map<String, dynamic> updates) async {
    try {
      // If updating group name, check for uniqueness
      if (updates.containsKey('group_name')) {
        final existing = await supabase
            .from('trip_groups')
            .select()
            .eq('group_name', updates['group_name'])
            .neq('id', groupId)
            .maybeSingle();

        if (existing != null) {
          _error =
              'A group with this name already exists. Please choose a different name.';
          notifyListeners();
          return false;
        }
      }

      await supabase.from('trip_groups').update(updates).eq('id', groupId);

      await loadGroups();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error updating group: $e');
      return false;
    }
  }

  /// Delete a group
  Future<bool> deleteGroup(String groupId) async {
    try {
      // Delete join requests
      await supabase.from('join_requests').delete().eq('group_id', groupId);

      // Delete all members
      await supabase.from('group_members').delete().eq('group_id', groupId);

      // Delete the group
      await supabase.from('trip_groups').delete().eq('id', groupId);

      _groups.removeWhere((g) => g.id == groupId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error deleting group: $e');
      return false;
    }
  }

  /// Remove a member from a group
  Future<bool> removeMember(String groupId, String memberId) async {
    try {
      await supabase.from('group_members').delete().eq('id', memberId);

      // Update local state
      final groupIndex = _groups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        _groups[groupIndex].members.removeWhere((m) => m.id == memberId);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error removing member: $e');
      return false;
    }
  }

  /// Add user to PUBLIC group immediately (owner action)
  Future<bool> addMemberToGroup(String groupId, UserProfile user) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if user is already a member
      final existing = await supabase
          .from('group_members')
          .select()
          .eq('group_id', groupId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing != null) {
        _error = 'User is already a member';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Add user as member immediately (only for public groups)
      await supabase.from('group_members').insert({
        'group_id': groupId,
        'user_id': user.id,
        'user_name': user.name,
        'user_email': user.email,
        'user_avatar': user.avatar,
        'role': 'member',
      });

      // Reload groups to get updated member list
      await loadGroups();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error adding member: $e');
      return false;
    }
  }

  /// Leave a group
  Future<bool> leaveGroup(String groupId, String userId) async {
    try {
      await supabase
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);

      await loadGroups();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error leaving group: $e');
      return false;
    }
  }

  /// Search users (for adding members)
  List<UserProfile> searchUsers(String query) {
    if (query.isEmpty) return _suggestedUsers;

    return _suggestedUsers
        .where(
          (user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// Get specific group details
  Future<TripGroup?> getGroupById(String groupId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final groupData = await supabase
          .from('trip_groups')
          .select()
          .eq('id', groupId)
          .single();

      final isPublic = groupData['is_public'] ?? true;
      final isOwner = groupData['owner_id'] == user.id;
      final isMember = await _isUserMember(groupId, user.id);

      // Only load members if authorized
      List<GroupMember> members = [];
      if (isPublic || isOwner || isMember) {
        final membersData = await supabase
            .from('group_members')
            .select()
            .eq('group_id', groupId)
            .order('joined_at', ascending: true);

        members = (membersData as List)
            .map((m) => GroupMember.fromJson(m))
            .toList();
      }

      return TripGroup(
        id: groupData['id'].toString(),
        groupName: groupData['group_name'],
        tripId: groupData['trip_id'],
        tripName: groupData['trip_name'],
        destination: groupData['destination'],
        tripDate: groupData['trip_date'],
        description: groupData['description'],
        ownerId: groupData['owner_id'],
        ownerName: groupData['owner_name'],
        members: members,
        createdAt: groupData['created_at'],
        groupImage: groupData['group_image'],
        isPublic: isPublic,
      );
    } catch (e) {
      debugPrint('Error getting group: $e');
      return null;
    }
  }
}
