import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/group_member.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:flutter_application_1/models/user_profile.dart';

class CommunityProvider with ChangeNotifier {
  List<TripGroup> _groups = [];
  List<UserProfile> _suggestedUsers = [];
  bool _isLoading = false;
  String? _error;

  List<TripGroup> get groups => _groups;
  List<UserProfile> get suggestedUsers => _suggestedUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mock data for demonstration
  void loadMockData() {
    _groups = [
      TripGroup(
        id: '1',
        groupName: 'Bali Beach Explorers',
        tripId: '1',
        tripName: 'Bali Beach Paradise',
        destination: 'Bali, Indonesia',
        tripDate: 'Mar 15 - Mar 22',
        description: 'Join us for an amazing beach adventure in Bali!',
        ownerId: 'user1',
        ownerName: 'Sarah Johnson',
        createdAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        groupImage: 'https://images.unsplash.com/photo-1577717903315-1691ae25ab3f?w=400',
        members: [
          GroupMember(
            id: 'm1',
            userId: 'user1',
            userName: 'Sarah Johnson',
            userEmail: 'sarah@example.com',
            role: 'owner',
            joinedAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          ),
          GroupMember(
            id: 'm2',
            userId: 'user2',
            userName: 'Mike Chen',
            userEmail: 'mike@example.com',
            role: 'member',
            joinedAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          ),
          GroupMember(
            id: 'm3',
            userId: 'user3',
            userName: 'Emma Davis',
            userEmail: 'emma@example.com',
            role: 'member',
            joinedAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          ),
        ],
      ),
      TripGroup(
        id: '2',
        groupName: 'Tokyo Adventure Squad',
        tripId: '4',
        tripName: 'Tokyo Modern',
        destination: 'Tokyo, Japan',
        tripDate: 'Jun 1 - Jun 10',
        description: 'Explore the vibrant city of Tokyo together!',
        ownerId: 'user4',
        ownerName: 'Alex Kim',
        createdAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        groupImage: 'https://images.unsplash.com/photo-1617869884925-f8f0a51b2374?w=400',
        members: [
          GroupMember(
            id: 'm4',
            userId: 'user4',
            userName: 'Alex Kim',
            userEmail: 'alex@example.com',
            role: 'owner',
            joinedAt: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          ),
          GroupMember(
            id: 'm5',
            userId: 'user5',
            userName: 'Lisa Wong',
            userEmail: 'lisa@example.com',
            role: 'member',
            joinedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          ),
        ],
      ),
      TripGroup(
        id: '3',
        groupName: 'European Explorers',
        tripId: '2',
        tripName: 'European Escapade',
        destination: 'Paris & Rome',
        tripDate: 'Apr 10 - Apr 20',
        description: 'Experience the best of Europe with fellow travelers',
        ownerId: 'user6',
        ownerName: 'Sophie Martin',
        createdAt: DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        groupImage: 'https://images.unsplash.com/photo-1473951574080-01fe45ec8643?w=400',
        members: [
          GroupMember(
            id: 'm6',
            userId: 'user6',
            userName: 'Sophie Martin',
            userEmail: 'sophie@example.com',
            role: 'owner',
            joinedAt: DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          ),
          GroupMember(
            id: 'm7',
            userId: 'user7',
            userName: 'James Wilson',
            userEmail: 'james@example.com',
            role: 'member',
            joinedAt: DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
          ),
          GroupMember(
            id: 'm8',
            userId: 'user8',
            userName: 'Maria Garcia',
            userEmail: 'maria@example.com',
            role: 'member',
            joinedAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          ),
          GroupMember(
            id: 'm9',
            userId: 'user9',
            userName: 'David Lee',
            userEmail: 'david@example.com',
            role: 'member',
            joinedAt: DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          ),
        ],
      ),
    ];

    _suggestedUsers = [
      UserProfile(
        id: 'user10',
        name: 'Rachel Green',
        email: 'rachel@example.com',
        bio: 'Love traveling and photography!',
      ),
      UserProfile(
        id: 'user11',
        name: 'John Smith',
        email: 'john@example.com',
        bio: 'Adventure seeker and foodie',
      ),
      UserProfile(
        id: 'user12',
        name: 'Ana Silva',
        email: 'ana@example.com',
        bio: 'World traveler | Beach lover',
      ),
      UserProfile(
        id: 'user13',
        name: 'Tom Brown',
        email: 'tom@example.com',
        bio: 'Exploring one city at a time',
      ),
      UserProfile(
        id: 'user14',
        name: 'Nina Patel',
        email: 'nina@example.com',
        bio: 'Travel blogger and photographer',
      ),
    ];

    notifyListeners();
  }

  Future<void> loadGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      loadMockData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createGroup(TripGroup group) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      _groups.insert(0, group);
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

  Future<bool> removeMember(String groupId, String memberId) async {
    try {
      final groupIndex = _groups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        final group = _groups[groupIndex];
        group.members.removeWhere((m) => m.id == memberId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> inviteUser(String groupId, UserProfile user) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final groupIndex = _groups.indexWhere((g) => g.id == groupId);
      if (groupIndex != -1) {
        final newMember = GroupMember(
          id: 'm${DateTime.now().millisecondsSinceEpoch}',
          userId: user.id,
          userName: user.name,
          userEmail: user.email,
          role: 'member',
          joinedAt: DateTime.now().toIso8601String(),
          userAvatar: user.avatar,
        );
        _groups[groupIndex].members.add(newMember);
      }

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

  List<UserProfile> searchUsers(String query) {
    if (query.isEmpty) return _suggestedUsers;
    return _suggestedUsers
        .where((user) =>
            user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}