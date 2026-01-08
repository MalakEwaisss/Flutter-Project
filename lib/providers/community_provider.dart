import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/group_member.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import '../main.dart';

class CommunityProvider with ChangeNotifier {
  List<TripGroup> _groups = [];
  List<UserProfile> _suggestedUsers = [];
  bool _isLoading = false;
  String? _error;
  bool _showPublicOnly = true;

  List<TripGroup> get groups => _groups;
  List<UserProfile> get suggestedUsers => _suggestedUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showPublicOnly => _showPublicOnly;

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
        // Load only public groups
        groupsData = await supabase
            .from('trip_groups')
            .select()
            .eq('is_public', true)
            .order('created_at', ascending: false);
      } else {
        // Load groups user is a member of (both public and private)
        final memberRows = await supabase
            .from('group_members')
            .select('group_id')
            .eq('user_id', user.id) as List<dynamic>;
        final groupIds = memberRows.map((r) => r['group_id']).toList();

        if (groupIds.isEmpty) {
          groupsData = [];
        } else {
          // Use .filter with 'in' operator — value must be a parenthesized, comma-separated list
          groupsData = await supabase
              .from('trip_groups')
              .select()
              .filter('id', 'in', '(${groupIds.join(',')})')
              .order('created_at', ascending: false);
        }
      }

      // Load members for each group
      List<TripGroup> loadedGroups = [];
      for (var groupData in groupsData) {
        final membersData = await supabase
            .from('group_members')
            .select()
            .eq('group_id', groupData['id'])
            .order('joined_at', ascending: true);

        final members = (membersData as List)
            .map((m) => GroupMember.fromJson(m))
            .toList();

        loadedGroups.add(TripGroup(
          id: groupData['id'],
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
          isPublic: groupData['is_public'] ?? true,
        ));
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

  /// Load suggested users for invitations
  Future<void> loadSuggestedUsers() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Get all users except current user
      final usersData = await supabase
          .from('auth.users')
          .select('id, email, raw_user_meta_data')
          .neq('id', user.id)
          .limit(20);

      _suggestedUsers = (usersData as List).map((userData) {
        final metaData = userData['raw_user_meta_data'] ?? {};
        return UserProfile(
          id: userData['id'],
          name: metaData['full_name'] ?? 'User',
          email: userData['email'],
          avatar: metaData['avatar_url'],
          bio: metaData['bio'],
        );
      }).toList();
    } catch (e) {
      // If we can't access auth.users, create empty list
      _suggestedUsers = [];
      debugPrint('Could not load suggested users: $e');
    }
  }

  /// Create a new group
  Future<bool> createGroup(TripGroup group) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Insert group
      final insertedGroup = await supabase
          .from('trip_groups')
          .insert({
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
          })
          .select()
          .single();

      // The trigger will automatically add owner as member
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

  /// Update group details
  Future<bool> updateGroup(String groupId, Map<String, dynamic> updates) async {
    try {
      await supabase
          .from('trip_groups')
          .update(updates)
          .eq('id', groupId);

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
      await supabase
          .from('trip_groups')
          .delete()
          .eq('id', groupId);

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
      await supabase
          .from('group_members')
          .delete()
          .eq('id', memberId);

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

  /// Invite/Add user to group
  Future<bool> inviteUser(String groupId, UserProfile user) async {
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

      // Add user as member
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
      debugPrint('Error inviting user: $e');
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

  /// Search users (for invitation)
  List<UserProfile> searchUsers(String query) {
    if (query.isEmpty) return _suggestedUsers;
    
    return _suggestedUsers
        .where((user) =>
            user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get specific group details
  Future<TripGroup?> getGroupById(String groupId) async {
    try {
      final groupData = await supabase
          .from('trip_groups')
          .select()
          .eq('id', groupId)
          .single();

      final membersData = await supabase
          .from('group_members')
          .select()
          .eq('group_id', groupId)
          .order('joined_at', ascending: true);

      final members = (membersData as List)
          .map((m) => GroupMember.fromJson(m))
          .toList();

      return TripGroup(
        id: groupData['id'],
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
        isPublic: groupData['is_public'] ?? true,
      );
    } catch (e) {
      debugPrint('Error getting group: $e');
      return null;
    }
  }
}