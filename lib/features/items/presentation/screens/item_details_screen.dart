// lib/features/items/presentation/screens/item_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/item_controller.dart';
import '../../data/models/item_model.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../profile/controller/profile_controller.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../chat/presentation/screens/chat_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailsScreen({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  _ItemDetailsScreenState createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  @override
  void initState() {
    super.initState();
    
    // Fetch item details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemController>(context, listen: false).getItemById(widget.itemId);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Details'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Consumer<ItemController>(
        builder: (context, itemController, child) {
          if (itemController.isLoading) {
            return Center(child: LoadingIndicator());
          }
          
          final item = itemController.selectedItem;
          
          if (item == null) {
            return Center(
              child: Text('Item not found. It may have been removed.'),
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItemHeader(item),
                const SizedBox(height: 24),
                _buildItemDetails(item),
                const SizedBox(height: 24),
                _buildRequesterInfo(item),
                const SizedBox(height: 24),
                if (item.status == ItemStatus.pending)
                  _buildActionButtons(context, item, itemController),
                if (item.status == ItemStatus.accepted || item.status == ItemStatus.returned)
                  _buildStatusCard(item),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildItemHeader(Item item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (item.isUrgent)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${_getStatusString(item.status)}',
              style: TextStyle(
                color: _getStatusColor(item.status),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.description,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildItemDetails(Item item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.calendar_today, 'Date Requested:', 
              _formatDateTime(item.createdAt)),
            const SizedBox(height: 12),
            if (item.startDate != null && item.endDate != null) ...[
              _buildDetailRow(Icons.date_range, 'Needed From:', 
                '${_formatDate(item.startDate!)} to ${_formatDate(item.endDate!)}'),
              const SizedBox(height: 12),
            ],
            if (item.duration != null && item.durationUnit != null) ...[
              _buildDetailRow(Icons.timer, 'Needed For:', 
                '${item.duration} ${_formatDurationUnit(item.durationUnit!)}'),
              const SizedBox(height: 12),
            ],
            _buildDetailRow(Icons.apartment, 'Community:', 'Green Heights Residency'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRequesterInfo(Item item) {
    return FutureBuilder<UserProfile?>(
      future: Provider.of<ProfileController>(context, listen: false)
          .getProfileById(item.requesterId),
      builder: (context, snapshot) {
        final UserProfile? requester = snapshot.data;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Requested By',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppConstants.primaryColorLight,
                      backgroundImage: requester?.profilePicture != null && requester!.profilePicture.isNotEmpty
                          ? NetworkImage(requester.profilePicture)
                          : null,
                      child: requester?.profilePicture == null || requester!.profilePicture.isEmpty
                          ? Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            requester?.name ?? 'Loading...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (requester != null && requester.apartment.isNotEmpty)
                            Text(
                              'Apartment ${requester.apartment}',
                              style: TextStyle(
                                color: Colors.grey[600],
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
        );
      },
    );
  }
  
  Widget _buildActionButtons(BuildContext context, Item item, ItemController controller) {
    final currentUserId = Provider.of<ProfileController>(context).currentUserId;
    final isRequester = item.requesterId == currentUserId;
    
    if (isRequester) {
      // Requester can delete their own request
      return CustomButton(
        text: 'Cancel Request',
        backgroundColor: Colors.red,
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Cancel Request?'),
              content: Text('Are you sure you want to cancel this request?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Yes'),
                ),
              ],
            ),
          );
          
          if (confirm == true) {
            final success = await controller.deleteItem(item.id);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Request cancelled successfully')),
              );
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to cancel request')),
              );
            }
          }
        },
      );
    } else {
      // Other users can offer to lend the item
      return CustomButton(
        text: 'Offer to Lend',
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Confirm Offer'),
              content: Text('Are you sure you want to offer to lend this item?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Confirm'),
                ),
              ],
            ),
          );
          
          if (confirmed == true) {
            final success = await controller.updateItemStatus(
              item.id, 
              ItemStatus.accepted,
              lenderId: currentUserId,
            );
            
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('You\'ve offered to lend this item')),
              );
              
              // After accepting, navigate to chat with requester
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    otherUserId: item.requesterId,
                    itemId: item.id,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to process your offer')),
              );
            }
          }
        },
      );
    }
  }
  
  Widget _buildStatusCard(Item item) {
    return Card(
      elevation: 2,
      color: item.status == ItemStatus.returned 
          ? Colors.green.shade50 
          : AppConstants.primaryColorLight.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  item.status == ItemStatus.returned 
                      ? Icons.check_circle 
                      : Icons.handshake,
                  color: item.status == ItemStatus.returned 
                      ? Colors.green 
                      : AppConstants.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  item.status == ItemStatus.returned 
                      ? 'Item Returned' 
                      : 'Item Matched',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: item.status == ItemStatus.returned 
                        ? Colors.green 
                        : AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.status == ItemStatus.returned 
                  ? 'This item has been returned to the lender. Transaction complete!' 
                  : 'Someone has offered to lend this item. Check your messages to coordinate the exchange.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (item.lenderId != null && item.status == ItemStatus.accepted)
              FutureBuilder<UserProfile?>(
                future: Provider.of<ProfileController>(context, listen: false)
                    .getProfileById(item.lenderId!),
                builder: (context, snapshot) {
                  final UserProfile? lender = snapshot.data;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lender:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppConstants.primaryColorLight,
                            backgroundImage: lender?.profilePicture != null && lender!.profilePicture.isNotEmpty
                                ? NetworkImage(lender.profilePicture)
                                : null,
                            child: lender?.profilePicture == null || lender!.profilePicture.isEmpty
                                ? Icon(Icons.person, color: Colors.white, size: 18)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(lender?.name ?? 'Loading...'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Open Chat',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                otherUserId: item.lenderId!,
                                itemId: item.id,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            if (item.status == ItemStatus.accepted)
              Consumer<ProfileController>(
                builder: (context, profileController, _) {
                  final currentUserId = profileController.currentUserId;
                  final isRequester = item.requesterId == currentUserId;

                  if (isRequester) {
                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Mark as Returned',
                          backgroundColor: Colors.green,
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirm Return'),
                                content: Text('Has this item been returned to the lender?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('Yes'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirmed == true) {
                              final success = await Provider.of<ItemController>(context, listen: false)
                                  .updateItemStatus(item.id, ItemStatus.returned);
                              
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Item marked as returned')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to update status')),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _getStatusString(ItemStatus status) {
    switch (status) {
      case ItemStatus.pending:
        return 'Pending';
      case ItemStatus.accepted:
        return 'Matched';
      case ItemStatus.rejected:
        return 'Rejected';
      case ItemStatus.returned:
        return 'Returned';
      default:
        return 'Unknown';
    }
  }
  
  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.pending:
        return Colors.orange;
      case ItemStatus.accepted:
        return AppConstants.primaryColor;
      case ItemStatus.rejected:
        return Colors.red;
      case ItemStatus.returned:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _formatDurationUnit(DurationUnit unit) {
    switch (unit) {
      case DurationUnit.hours:
        return 'hours';
      case DurationUnit.days:
        return 'days';
      case DurationUnit.weeks:
        return 'weeks';
      default:
        return 'unknown';
    }
  }
}