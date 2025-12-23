import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import '../models/group_member.dart';
import '../models/user_profile.dart';
import '../main.dart'; // For supabase client

class FirebaseCommunityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _groupsCollection = 'trip_groups';
  static const String _usersCollection = 'users';
  
  // Get current user ID from Supabase
  static String? get currentUserId => supabase.auth.currentUser?.id;
  
  // Get current user email from Supabase
  static String? get currentUserEmail => supabase.auth.currentUser?.email;
  
  // Get current user name from Supabase metadata
  static String get currentUserName {
    final user = supabase.auth.currentUser;
    return user?.userMetadata?['full_name'] ?? 'User';
  }

  // ============================================================================
  // GROUPS
  // ============================================================================

  /// Fetch all groups
  static Future<List<TripGroup>> fetchGroups() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_groupsCollection)
          .orderBy('created_at', descending: true)
          .get();

      List<TripGroup> groups = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Fetch members for this group
        final membersSnapshot = await _firestore
            .collection(_groupsCollection)
            .doc(doc.id)
            .collection('members')
            .get();
        
        List<GroupMember> members = membersSnapshot.docs
            .map((memberDoc) {
              final memberData = memberDoc.data();
              return GroupMember.fromJson({
                'id': memberDoc.id,
                'user_id': memberData['user_id'],
                'user_name': memberData['user_name'],
                'user_email': memberData['user_email'],
                'role': memberData['role'],
                'joined_at': (memberData['joined_at'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
                'user_avatar': memberData['user_avatar'],
              });
            })
            .toList();
        
        groups.add(TripGroup.fromJson({
          'id': doc.id,
          'group_name': data['group_name'],
          'trip_id': data['trip_id'],
          'trip_name': data['trip_name'],
          'destination': data['destination'],
          'trip_date': data['trip_date'],
          'description': data['description'],
          'owner_id': data['owner_id'],
          'owner_name': data['owner_name'],
          'created_at': (data['created_at'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
          'group_image': data['group_image'],
          'members': members.map((m) => m.toJson()).toList(),
        }));
      }
      
      return groups;
    } catch (e) {
      throw Exception('Error fetching groups: $e');
    }
  }

  /// Create a new group
  static Future<String> createGroup(TripGroup group) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Create group document
      final docRef = await _firestore.collection(_groupsCollection).add({
        'group_name': group.groupName,
        'trip_id': group.tripId,
        'trip_name': group.tripName,
        'destination': group.destination,
        'trip_date': group.tripDate,
        'description': group.description,
        'owner_id': currentUserId,
        'owner_name': currentUserName,
        'created_at': FieldValue.serverTimestamp(),
        'group_image': group.groupImage,
      });

      // Add owner as first member
      await _firestore
          .collection(_groupsCollection)
          .doc(docRef.id)
          .collection('members')
          .add({
        'user_id': currentUserId,
        'user_name': currentUserName,
        'user_email': currentUserEmail ?? '',
        'role': 'owner',
        'joined_at': FieldValue.serverTimestamp(),
        'user_avatar': null,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Error creating group: $e');
    }
  }

  /// Add member to group
  static Future<void> addMemberToGroup(
    String groupId,
    UserProfile user,
  ) async {
    try {
      await _firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection('members')
          .add({
        'user_id': user.id,
        'user_name': user.name,
        'user_email': user.email,
        'role': 'member',
        'joined_at': FieldValue.serverTimestamp(),
        'user_avatar': user.avatar,
      });
    } catch (e) {
      throw Exception('Error adding member: $e');
    }
  }

  /// Remove member from group
  static Future<void> removeMemberFromGroup(
    String groupId,
    String memberId,
  ) async {
    try {
      await _firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection('members')
          .doc(memberId)
          .delete();
    } catch (e) {
      throw Exception('Error removing member: $e');
    }
  }

  /// Delete a group (owner only)
  static Future<void> deleteGroup(String groupId) async {
    try {
      // Delete all members first
      final membersSnapshot = await _firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .collection('members')
          .get();

      for (var doc in membersSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the group
      await _firestore.collection(_groupsCollection).doc(groupId).delete();
    } catch (e) {
      throw Exception('Error deleting group: $e');
    }
  }

  // ============================================================================
  // USERS (Synced from Supabase)
  // ============================================================================

  /// Sync user profile to Firebase when they sign up/login
  static Future<void> syncUserProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).set({
        'name': name,
        'email': email,
        'avatar': null,
        'bio': null,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error syncing user profile: $e');
    }
  }

  /// Fetch suggested users (excluding current user and current group members)
  static Future<List<UserProfile>> fetchSuggestedUsers({
    String? excludeGroupId,
  }) async {
    try {
      // Get all users from Firebase
      final usersSnapshot = await _firestore
          .collection(_usersCollection)
          .limit(50)
          .get();

      List<UserProfile> users = usersSnapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) {
            final data = doc.data();
            return UserProfile.fromJson({
              'id': doc.id,
              'name': data['name'],
              'email': data['email'],
              'avatar': data['avatar'],
              'bio': data['bio'],
            });
          })
          .toList();

      // If a group ID is provided, exclude members of that group
      if (excludeGroupId != null) {
        final membersSnapshot = await _firestore
            .collection(_groupsCollection)
            .doc(excludeGroupId)
            .collection('members')
            .get();

        final memberIds = membersSnapshot.docs
            .map((doc) => doc.data()['user_id'] as String)
            .toSet();

        users = users.where((user) => !memberIds.contains(user.id)).toList();
      }

      return users;
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  /// Search users by name or email
  static Future<List<UserProfile>> searchUsers(
    String query, {
    String? excludeGroupId,
  }) async {
    try {
      if (query.isEmpty) {
        return await fetchSuggestedUsers(excludeGroupId: excludeGroupId);
      }

      final queryLower = query.toLowerCase();

      // Get all users and filter in memory (Firestore doesn't support case-insensitive search)
      final allUsers = await fetchSuggestedUsers(excludeGroupId: excludeGroupId);
      
      return allUsers.where((user) {
        return user.name.toLowerCase().contains(queryLower) ||
               user.email.toLowerCase().contains(queryLower);
      }).toList();
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }

  // ============================================================================
  // REAL-TIME LISTENERS
  // ============================================================================

  /// Listen to group changes in real-time
  static Stream<List<TripGroup>> streamGroups() {
    return _firestore
        .collection(_groupsCollection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<TripGroup> groups = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Fetch members for this group
        final membersSnapshot = await _firestore
            .collection(_groupsCollection)
            .doc(doc.id)
            .collection('members')
            .get();

        List<GroupMember> members = membersSnapshot.docs
            .map((memberDoc) {
              final memberData = memberDoc.data();
              return GroupMember.fromJson({
                'id': memberDoc.id,
                'user_id': memberData['user_id'],
                'user_name': memberData['user_name'],
                'user_email': memberData['user_email'],
                'role': memberData['role'],
                'joined_at': (memberData['joined_at'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
                'user_avatar': memberData['user_avatar'],
              });
            })
            .toList();

        groups.add(TripGroup.fromJson({
          'id': doc.id,
          'group_name': data['group_name'],
          'trip_id': data['trip_id'],
          'trip_name': data['trip_name'],
          'destination': data['destination'],
          'trip_date': data['trip_date'],
          'description': data['description'],
          'owner_id': data['owner_id'],
          'owner_name': data['owner_name'],
          'created_at': (data['created_at'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
          'group_image': data['group_image'],
          'members': members.map((m) => m.toJson()).toList(),
        }));
      }

      return groups;
    });
  }

  /// Listen to members of a specific group
  static Stream<List<GroupMember>> streamGroupMembers(String groupId) {
    return _firestore
        .collection(_groupsCollection)
        .doc(groupId)
        .collection('members')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return GroupMember.fromJson({
                'id': doc.id,
                'user_id': data['user_id'],
                'user_name': data['user_name'],
                'user_email': data['user_email'],
                'role': data['role'],
                'joined_at': (data['joined_at'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
                'user_avatar': data['user_avatar'],
              });
            })
            .toList());
  }
}