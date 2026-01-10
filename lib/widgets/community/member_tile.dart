import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/models/group_member.dart';

class MemberTile extends StatelessWidget {
  final GroupMember member;
  final bool showRemoveButton;
  final VoidCallback? onRemove;
  final bool isCurrentUser;

  const MemberTile({
    super.key,
    required this.member,
    this.showRemoveButton = false,
    this.onRemove,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? primaryBlue.withOpacity(0.05)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? primaryBlue.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: primaryBlue.withOpacity(0.1),
          child: member.userAvatar != null
              ? ClipOval(
                  child: Image.network(
                    member.userAvatar!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildAvatarPlaceholder();
                    },
                  ),
                )
              : _buildAvatarPlaceholder(),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isCurrentUser ? primaryBlue : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: successGreen,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              member.userEmail,
              style: const TextStyle(fontSize: 13, color: subtitleColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: member.isOwner
                    ? accentOrange.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    member.isOwner ? Icons.star : Icons.person,
                    size: 12,
                    color: member.isOwner ? accentOrange : subtitleColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    member.isOwner ? 'Owner' : 'Member',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: member.isOwner ? accentOrange : subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: showRemoveButton && !member.isOwner
            ? IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                ),
                onPressed: onRemove,
                tooltip: 'Remove member',
              )
            : null,
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Icon(Icons.person, size: 32, color: primaryBlue.withOpacity(0.5));
  }
}
