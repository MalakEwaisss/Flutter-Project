import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/group_model.dart';
import 'package:provider/provider.dart';
import '../../config/config.dart';
import '../../providers/community_provider.dart';
import '../../widgets/community/group_card_updated.dart';
import '../../widgets/community/empty_state_widget.dart';
import 'create_group_screen.dart';
import 'group_members_screen.dart';

class CommunityScreen extends StatefulWidget {
  final Function(AppPage, {Map<String, dynamic>? trip}) navigateTo;
  final bool isLoggedIn;
  final Function(BuildContext context) showAuthModal;
  final VoidCallback onThemeToggle;

  const CommunityScreen({
    super.key,
    required this.navigateTo,
    required this.isLoggedIn,
    required this.showAuthModal,
    required this.onThemeToggle,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isLoggedIn) {
        Provider.of<CommunityProvider>(context, listen: false).loadGroups();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn) {
      return _buildNotLoggedInView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community & Groups'),
        backgroundColor: primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onThemeToggle,
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => widget.navigateTo(AppPage.home),
            tooltip: 'Home',
          ),
        ],
      ),
      body: Consumer<CommunityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.groups.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => provider.loadGroups(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.groups.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.groups_outlined,
              title: 'No Groups Yet',
              subtitle: provider.showPublicOnly
                  ? 'Create or join a group to connect with fellow travelers'
                  : 'You haven\'t joined any groups yet',
              buttonText: 'Create Your First Group',
              onButtonPressed: _navigateToCreateGroup,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadGroups,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Travel Groups',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${provider.groups.length} ${provider.groups.length == 1 ? 'group' : 'groups'} available',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: accentOrange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.groups,
                                color: accentOrange,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // NEW: Public/Private Toggle
                        Row(
                          children: [
                            Expanded(
                              child: _buildFilterChip(
                                label: 'Public Groups',
                                icon: Icons.public,
                                isSelected: provider.showPublicOnly,
                                onTap: () {
                                  if (!provider.showPublicOnly) {
                                    provider.toggleGroupVisibility();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFilterChip(
                                label: 'My Groups',
                                icon: Icons.lock,
                                isSelected: !provider.showPublicOnly,
                                onTap: () {
                                  if (provider.showPublicOnly) {
                                    provider.toggleGroupVisibility();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final group = provider.groups[index];
                        return GroupCard(
                          group: group,
                          onTap: () => _navigateToGroupMembers(group),
                          showVisibilityBadge: true,
                        );
                      },
                      childCount: provider.groups.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateGroup,
        backgroundColor: accentOrange,
        icon: const Icon(Icons.add),
        label: const Text(
          'Create Group',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryBlue
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryBlue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community & Groups'),
        backgroundColor: primaryBlue,
      ),
      body: EmptyStateWidget(
        icon: Icons.lock_outline,
        title: 'Login Required',
        subtitle: 'Please sign in to view and join travel groups',
        buttonText: 'Sign In',
        onButtonPressed: () => widget.showAuthModal(context),
      ),
    );
  }

  void _navigateToCreateGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
      ),
    );
  }

  void _navigateToGroupMembers(TripGroup group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupMembersScreen(group: group),
      ),
    );
  }
}