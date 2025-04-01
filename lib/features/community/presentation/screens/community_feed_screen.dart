// lib/features/community/presentation/widgets/community_widgets.dart
import 'package:comet/core/constants/app_constants.dart';
import 'package:comet/features/community/data/models/community_model.dart'; // Import the model
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For network images
import 'package:comet/core/utils/helpers.dart'; // For placeholder image

// --- FIX: Added EmptyCommunityState Widget Definition ---
class EmptyCommunityState extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData icon;

  const EmptyCommunityState({
    Key? key,
    required this.message,
    this.onAction,
    this.actionLabel,
    this.icon = Icons.info_outline, // Default icon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


// --- Basic CommunityCard Widget (Placeholder) ---
class CommunityCard extends StatelessWidget {
  final CommunityModel community; // Use the fixed model
  final bool isMember;
  final VoidCallback onTap;
  final VoidCallback? onJoin; // Make optional as it's only for discover

  const CommunityCard({
    Key? key,
    required this.community,
    required this.isMember,
    required this.onTap,
    this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // TODO: Replace with actual community image logic if available
    final placeholderImage = Helpers.getPlaceholderImageUrl(seed: community.id.hashCode);

    return Card(
      // Uses CardTheme from AppTheme
      clipBehavior: Clip.antiAlias, // Ensures image corners are rounded with card
      child: InkWell( // Make the whole card tappable
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Community Image Placeholder
              ClipRRect(
                 borderRadius: BorderRadius.circular(8.0),
                 child: CachedNetworkImage(
                   imageUrl: placeholderImage, // Use placeholder
                   width: 60,
                   height: 60,
                   fit: BoxFit.cover,
                   placeholder: (context, url) => Container(
                     width: 60,
                     height: 60,
                     color: Colors.grey[300],
                     child: Icon(Icons.group, color: Colors.grey[500]),
                   ),
                   errorWidget: (context, url, error) => Container(
                     width: 60,
                     height: 60,
                     color: Colors.grey[300],
                     child: Icon(Icons.broken_image, color: Colors.grey[500]),
                   ),
                 ),
               ),
              const SizedBox(width: 12),
              // Community Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.name,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      community.description,
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                     const SizedBox(height: 4),
                    Text(
                      '${community.memberCount} Member${community.memberCount == 1 ? '' : 's'}', // Handle plural
                       style: textTheme.labelSmall?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Action Button (Join)
              if (!isMember && onJoin != null)
                TextButton(
                  onPressed: onJoin,
                  style: TextButton.styleFrom(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                     backgroundColor: colorScheme.primaryContainer.withOpacity(0.2),
                     foregroundColor: colorScheme.primary,
                     textStyle: textTheme.labelSmall,
                     tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce padding
                  ),
                  child: const Text('Join'),
                ),
              if (isMember) // Placeholder for member indicator
                 Icon(Icons.check_circle, color: Colors.green.shade300, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// Add other community-related widgets here as needed