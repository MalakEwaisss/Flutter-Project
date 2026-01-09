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

  /// Load suggested users for invitations - FIXED VERSION
  Future<void> loadSuggestedUsers() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Get all existing group members across all groups
      final allMembersData = await supabase
          .from('group_members')
          .select('user_id, user_name, user_email, user_avatar');

      // Create a set of unique users (excluding current user)
      final Map<String, UserProfile> uniqueUsers = {};
      
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

      _suggestedUsers = uniqueUsers.values.toList();
      
      // If no users found from group members, create some mock users for testing
      if (_suggestedUsers.isEmpty) {
        _suggestedUsers = [
          UserProfile(
            id: 'mock_user_1',
            name: 'John Traveler',
            email: 'john@example.com',
            avatar: null,
            bio: 'Love to explore new places',
          ),
          UserProfile(
            id: 'mock_user_2',
            name: 'Sarah Adventure',
            email: 'sarah@example.com',
            avatar: null,
            bio: 'Adventure seeker',
          ),
          UserProfile(
            id: 'mock_user_3',
            name: 'Mike Explorer',
            email: 'mike@example.com',
            avatar: null,
            bio: 'World traveler',
          ),
        ];
      }
      
      notifyListeners();
    } catch (e) {
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
      // First delete all members
      await supabase
          .from('group_members')
          .delete()
          .eq('group_id', groupId);
      
      // Then delete the group
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
        isPublic: groupData['is_public'] ?? true,
      );
    } catch (e) {
      debugPrint('Error getting group: $e');
      return null;
    }
  }
}