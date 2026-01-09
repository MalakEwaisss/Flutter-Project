import 'package:flutter/material.dart';
import '../../config/config.dart';
import '../../models/group_model.dart';

class GroupCard extends StatelessWidget {
  final TripGroup group;
  final VoidCallback onTap;
  final bool showVisibilityBadge;

  const GroupCard({
    super.key,
    required this.group,
    required this.onTap,
    this.showVisibilityBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Image with Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: group.groupImage != null
                      ? Image.network(
                          group.groupImage!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
                // Visibility Badge
                if (showVisibilityBadge)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: group.isPublic
                            ? successGreen
                            : accentOrange,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            group.isPublic ? Icons.public : Icons.lock,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            group.isPublic ? 'Public' : 'Private',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Group Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group Name
                  Text(
                    group.groupName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Trip Name
                  Row(
                    children: [
                      const Icon(
                        Icons.flight_takeoff,
                        size: 16,
                        color: primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          group.tripName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: primaryBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Destination
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: subtitleColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          group.destination,
                          style: const TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: subtitleColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        group.tripDate,
                        style: const TextStyle(
                          fontSize: 13,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Members count and owner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            size: 18,
                            color: accentOrange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${group.memberCount} ${group.memberCount == 1 ? 'member' : 'members'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: accentOrange,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 12,
                              color: primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              group.ownerName.split(' ').first,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue.withOpacity(0.7), accentOrange.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.groups,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }
}