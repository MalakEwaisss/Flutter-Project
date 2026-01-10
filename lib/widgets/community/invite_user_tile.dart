
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/constants.dart';
import 'package:flutter_application_1/models/user_profile.dart';

class InviteUserTile extends StatefulWidget {
  final UserProfile user;
  final VoidCallback onInvite;
  final bool isInviting;

  const InviteUserTile({
    super.key,
    required this.user,
    required this.onInvite,
    this.isInviting = false,
  });

  @override
  State<InviteUserTile> createState() => _InviteUserTileState();
}

class _InviteUserTileState extends State<InviteUserTile> {
  bool _invited = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: primaryBlue.withOpacity(0.1),
          child: widget.user.avatar != null
              ? ClipOval(
                  child: Image.network(
                    widget.user.avatar!,
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
        title: Text(
          widget.user.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              widget.user.email,
              style: const TextStyle(
                fontSize: 13,
                color: subtitleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.user.bio != null) ...[
              const SizedBox(height: 6),
              Text(
                widget.user.bio!,
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: _invited
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: successGreen),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: successGreen,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Invited',
                      style: TextStyle(
                        color: successGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : ElevatedButton.icon(
                onPressed: widget.isInviting
                    ? null
                    : () {
                        setState(() => _invited = true);
                        widget.onInvite();
                      },
                icon: widget.isInviting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_add, size: 18),
                label: Text(widget.isInviting ? 'Inviting...' : 'Invite'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Icon(
      Icons.person,
      size: 32,
      color: primaryBlue.withOpacity(0.5),
    );
  }
}

