import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/group_member.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/services/firebase_community_service.dart';
import 'package:flutter_application_1/services/firebase_community_service.dart';

class CommunityProvider with ChangeNotifier {
  List<TripGroup> _groups = [];
  List<UserProfile> _suggestedUsers = [];
  bool _isLoading = false;
  String? _error;

  List<TripGroup> get groups => _groups;
  List<UserProfile> get suggestedUsers => _suggestedUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load groups from Firebase
  Future<void> loadGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _groups = await FirebaseCommunityService.fetchGroups();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load suggested users from Firebase
  Future<void> loadSuggestedUsers({String? excludeGroupId}) async {
    try {
      _suggestedUsers = await FirebaseCommunityService.fetchSuggestedUsers(
        excludeGroupId: excludeGroupId,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Create a new group
  Future<bool> createGroup(TripGroup group) async {
    try {
      _isLoading = true;
      notifyListeners();

      await FirebaseCommunityService.createGroup(group);

      // Reload groups to include the new one
      await loadGroups();

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Remove a member from a group
  Future<bool> removeMember(String groupId, String memberId) async {
    try {
      await FirebaseCommunityService.removeMemberFromGroup(groupId, memberId);
      
      // Reload groups to reflect changes
      await loadGroups();
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Invite a user to a group
  Future<bool> inviteUser(String groupId, UserProfile user) async {
    try {
      _isLoading = true;
      notifyListeners();

      await FirebaseCommunityService.addMemberToGroup(groupId, user);

      // Reload groups to reflect changes
      await loadGroups();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Search users by query
  Future<List<UserProfile>> searchUsers(String query, {String? excludeGroupId}) async {
    try {
      return await FirebaseCommunityService.searchUsers(
        query,
        excludeGroupId: excludeGroupId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Delete a group (owner only)
  Future<bool> deleteGroup(String groupId) async {
    try {
      await FirebaseCommunityService.deleteGroup(groupId);
      await loadGroups();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Listen to groups in real-time
  Stream<List<TripGroup>> get groupsStream {
    return FirebaseCommunityService.streamGroups();
  }
  }