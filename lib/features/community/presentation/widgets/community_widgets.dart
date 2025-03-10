import 'package:flutter/material.dart';
import 'package:comet/config/theme.dart';
import 'package:comet/features/community/data/models/community_model.dart';
import 'package:intl/intl.dart';

class CommunityCard extends StatelessWidget {
  final CommunityModel community;
  final VoidCallback onTap;
  final bool isMember;
  final VoidCallback? onJoin;

  const CommunityCard({
    Key? key,
    required this.community,
    required this.onTap,
    this.isMember = false,
    this.onJoin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      community.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          community.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${community.city}, ${community.state}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${community.memberCount} members',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                community.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created ${_formatTimeAgo(community.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  if (isMember)
                    Chip(
                      label: const Text('Member'),
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else if (onJoin != null)
                    OutlinedButton(
                      onPressed: onJoin,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                      ),
                      child: const Text('Join'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 30) {
      return DateFormat('MMM yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Recently';
    }
  }
}

class CommunityMemberCard extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final String role;
  final String apartmentNumber;
  final VoidCallback onTap;

  const CommunityMemberCard({
    Key? key,
    required this.name,
    this.photoUrl,
    required this.role,
    required this.apartmentNumber,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl!)
                    : const AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Apartment $apartmentNumber',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: role == 'Admin'
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    color: role == 'Admin' ? AppColors.primary : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JoinCommunityForm extends StatelessWidget {
  final TextEditingController apartmentController;
  final TextEditingController proofController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const JoinCommunityForm({
    Key? key,
    required this.apartmentController,
    required this.proofController,
    required this.isLoading,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apartment Details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: apartmentController,
          decoration: const InputDecoration(
            labelText: 'Apartment Number/ID',
            hintText: 'e.g. A-101, 304, etc.',
            prefixIcon: Icon(Icons.home),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your apartment number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Verification',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: proofController,
          decoration: const InputDecoration(
            labelText: 'Proof of Residence',
            hintText: 'e.g. Resident ID, Lease Number, etc.',
            prefixIcon: Icon(Icons.verified_user),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please provide proof of residence';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Join Community'),
          ),
        ),
      ],
    );
  }
}