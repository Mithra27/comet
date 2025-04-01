// lib/features/items/presentation/screens/item_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Make sure intl is imported
import '../../controller/item_controller.dart';
// Import the CONSOLIDATED ItemModel and enums
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

    // Fetch item details using ItemController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Assuming getItemById is defined in ItemController and sets selectedItem
      Provider.of<ItemController>(context, listen: false)
          .getItemById(widget.itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'), // Made const
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Consumer<ItemController>(
        builder: (context, itemController, child) {
          // Assuming isLoading and selectedItem exist in ItemController
          if (itemController.isLoading) {
            return const Center(child: LoadingIndicator()); // Made const
          }

          // Use ItemModel? for selectedItem from controller
          final ItemModel? item = itemController.selectedItem;

          if (item == null) {
            return const Center( // Made const
              child: Text('Item not found. It may have been removed.'),
            );
          }

          // Now use the unified ItemModel
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0), // Made const
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItemHeader(item),
                const SizedBox(height: 24),
                _buildItemDetails(item),
                const SizedBox(height: 24),
                _buildRequesterInfo(item), // Pass ItemModel
                const SizedBox(height: 24),
                // Adjust logic based on the unified ItemStatus
                // Example: Show buttons if status allows for action
                if (item.status == ItemStatus.requested || item.status == ItemStatus.offered || item.status == ItemStatus.accepted)
                  _buildActionButtons(context, item, itemController), // Pass ItemModel
                // Example: Show status card for completed/cancelled items
                if (item.status == ItemStatus.completed || item.status == ItemStatus.cancelled)
                   _buildStatusCard(item), // Pass ItemModel
              ],
            ),
          );
        },
      ),
    );
  }

  // Method now accepts ItemModel
  Widget _buildItemHeader(ItemModel item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16), // Made const
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title, // Use title from unified model
                    style: const TextStyle( // Made const
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Use isUrgent from unified model
                if (item.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Made const
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text( // Made const
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
              // Use status from unified model and new helper
              'Status: ${_getStatusString(item.status)}',
              style: TextStyle(
                color: _getStatusColor(item.status), // Use new helper
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.description, // Use description from unified model
              style: const TextStyle(fontSize: 16), // Made const
            ),
          ],
        ),
      ),
    );
  }

  // Method now accepts ItemModel
  Widget _buildItemDetails(ItemModel item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16), // Made const
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text( // Made const
              'Request Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.calendar_today, 'Date Requested:',
              _formatDateTime(item.createdAt)), // Use createdAt from model
            const SizedBox(height: 12),
            // Use startDate/endDate from unified model
            if (item.startDate != null && item.endDate != null) ...[
              _buildDetailRow(Icons.date_range, 'Needed:',
                '${_formatDate(item.startDate!)} to ${_formatDate(item.endDate!)}'),
              const SizedBox(height: 12),
            ],
            // Use duration/durationUnit from unified model
            if (item.duration != null && item.durationUnit != null) ...[
              _buildDetailRow(Icons.timer, 'For:',
                '${item.duration} ${_formatDurationUnit(item.durationUnit!)}'),
              const SizedBox(height: 12),
            ],
            // You might need community info from the UserProfile or ItemModel
            _buildDetailRow(Icons.apartment, 'Community:', 'Green Heights Residency'), // Placeholder
          ],
        ),
      ),
    );
  }

  // Method now accepts ItemModel
  Widget _buildRequesterInfo(ItemModel item) {
    // Use requesterId from unified model
    return FutureBuilder<UserProfile?>(
      future: Provider.of<ProfileController>(context, listen: false)
          .getProfileById(item.requesterId),
      builder: (context, snapshot) {
        final UserProfile? requester = snapshot.data;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16), // Made const
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text( // Made const
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
                      backgroundColor: AppConstants.primaryColorLight, // Check if defined
                      backgroundImage: requester?.profilePicture != null && requester!.profilePicture.isNotEmpty
                          ? NetworkImage(requester.profilePicture)
                          : null,
                      child: requester?.profilePicture == null || requester!.profilePicture.isEmpty
                          ? const Icon(Icons.person, color: Colors.white) // Made const
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            requester?.name ?? 'Loading...',
                            style: const TextStyle( // Made const
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (requester != null && requester.apartment.isNotEmpty)
                            Text(
                              'Apt ${requester.apartment}', // Adjusted text
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

  // Method now accepts ItemModel
  Widget _buildActionButtons(BuildContext context, ItemModel item, ItemController controller) {
    // Assuming currentUserId exists in ProfileController
    final currentUserId = Provider.of<ProfileController>(context, listen: false).currentUserId;
    final isRequester = item.requesterId == currentUserId;

    // --- Requester Actions ---
    if (isRequester) {
      // Requester can cancel if item is requested or offered
      if (item.status == ItemStatus.requested || item.status == ItemStatus.offered) {
        return CustomButton(
          text: 'Cancel Request',
          backgroundColor: Colors.red,
          onPressed: () => _handleCancelRequest(context, item, controller),
        );
      }
      // Requester can mark as completed/returned if accepted
      else if (item.status == ItemStatus.accepted) {
         return CustomButton(
            text: 'Mark as Completed', // Or "Mark Returned"
            backgroundColor: Colors.green,
            onPressed: () => _handleMarkAsCompleted(context, item, controller),
          );
      }
    }
    // --- Potential Lender Actions ---
    else {
      // Can offer if the item is still requested and not already offered *by this user*
      // (Need more logic in controller/repo to check existing offers if multiple are allowed)
      if (item.status == ItemStatus.requested) {
         return CustomButton(
          text: 'Offer to Lend',
          onPressed: () => _handleOfferToLend(context, item, controller, currentUserId),
        );
      }
      // Can cancel offer if they are the lender and status is offered
      else if (item.status == ItemStatus.offered && item.lenderId == currentUserId) {
         return CustomButton(
          text: 'Cancel Offer',
          backgroundColor: Colors.orange,
          onPressed: () => _handleCancelOffer(context, item, controller),
        );
      }
      // Lender can cancel if accepted (before completion)
       else if (item.status == ItemStatus.accepted && item.lenderId == currentUserId) {
         return CustomButton(
          text: 'Cancel Agreement',
           backgroundColor: Colors.red,
          onPressed: () => _handleLenderCancelAgreement(context, item, controller),
        );
      }
    }

    // No actions available for this user/status combination
    return const SizedBox.shrink(); // Made const
  }


  // ---- Helper methods for actions ----

  Future<void> _handleCancelRequest(BuildContext context, ItemModel item, ItemController controller) async {
     final confirm = await _showConfirmationDialog(context,'Cancel Request?','Are you sure you want to cancel this request?');
     if (confirm == true) {
        // Assuming deleteItem exists in controller
        final success = await controller.deleteItem(item.id);
        if (context.mounted) { // Check context after await
          _showFeedback(context, success, 'Request cancelled successfully', 'Failed to cancel request');
          if (success) Navigator.pop(context);
        }
     }
  }

   Future<void> _handleMarkAsCompleted(BuildContext context, ItemModel item, ItemController controller) async {
     final confirm = await _showConfirmationDialog(context,'Confirm Completion','Has this item been returned/completed?');
     if (confirm == true) {
        // Assuming updateItemStatus takes id and new status
        final success = await controller.updateItemStatus(item.id, ItemStatus.completed);
         if (context.mounted) {
          _showFeedback(context, success, 'Item marked as completed', 'Failed to update status');
         }
     }
  }

  Future<void> _handleOfferToLend(BuildContext context, ItemModel item, ItemController controller, String? lenderId) async {
     if (lenderId == null) {
       _showFeedback(context, false, '', 'Could not identify current user.');
       return;
     }
     final confirm = await _showConfirmationDialog(context,'Confirm Offer','Are you sure you want to offer to lend this item?');
     if (confirm == true) {
        // Assuming updateItemStatus takes id, status, and optional lenderId
        final success = await controller.updateItemStatus(
          item.id,
          ItemStatus.offered, // Status changes to offered
          lenderId: lenderId,
        );
         if (context.mounted) {
           _showFeedback(context, success, 'You\'ve offered to lend this item', 'Failed to process your offer');
           // Maybe navigate to chat here ONLY if offer is immediately accepted?
           // Or wait for requester to accept the offer via notification/message.
           // Let's remove the automatic chat navigation for now.
           /* if (success) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    // Ensure ProfileController provides these names/IDs correctly
                    chatId: '${item.id}_${item.requesterId}_${lenderId}',
                    itemName: item.title,
                    recipientName: item.ownerName, // Requester's name
                    otherUserId: item.requesterId,
                  ),
                ),
              );
           } */
         }
     }
  }

  Future<void> _handleCancelOffer(BuildContext context, ItemModel item, ItemController controller) async {
     final confirm = await _showConfirmationDialog(context,'Cancel Offer?','Are you sure you want to withdraw your offer?');
     if (confirm == true) {
        // Need a way to revert status to 'requested' and clear lenderId
        final success = await controller.updateItemStatus(
          item.id,
          ItemStatus.requested, // Revert status
          lenderId: null, // Clear lender
        );
         if (context.mounted) {
          _showFeedback(context, success, 'Offer cancelled', 'Failed to cancel offer');
         }
     }
  }

   Future<void> _handleLenderCancelAgreement(BuildContext context, ItemModel item, ItemController controller) async {
     final confirm = await _showConfirmationDialog(context,'Cancel Agreement?','Are you sure you want to cancel this lending agreement?');
     if (confirm == true) {
        // Revert status to requested, clear lender
        final success = await controller.updateItemStatus(
          item.id,
          ItemStatus.cancelled, // Or requested? Depends on flow
          lenderId: null,
        );
         if (context.mounted) {
          _showFeedback(context, success, 'Agreement cancelled', 'Failed to cancel agreement');
         }
     }
  }


  // --- End Action Helpers ---


  // Method now accepts ItemModel
  Widget _buildStatusCard(ItemModel item) {
    // Use the unified ItemStatus
    bool isPositiveStatus = item.status == ItemStatus.completed; // Or accepted?
    String titleText = 'Unknown Status';
    String bodyText = 'The status of this item is unclear.';
    IconData iconData = Icons.info_outline;
    Color cardColor = Colors.grey.shade100;
    Color textColor = Colors.grey.shade800;

    switch (item.status) {
        case ItemStatus.accepted:
             titleText = 'Item Matched';
             bodyText = 'Please coordinate the exchange with the other party via chat.';
             iconData = Icons.handshake;
             cardColor = AppConstants.primaryColorLight.withOpacity(0.1);
             textColor = AppConstants.primaryColor;
             break;
        case ItemStatus.completed:
             titleText = 'Item Transaction Completed';
             bodyText = 'This item request/lending process is complete.';
             iconData = Icons.check_circle;
             cardColor = Colors.green.shade50;
             textColor = Colors.green;
             break;
         case ItemStatus.cancelled:
             titleText = 'Cancelled';
             bodyText = 'This request/offer has been cancelled.';
             iconData = Icons.cancel;
             cardColor = Colors.red.shade50;
             textColor = Colors.red;
             break;
         // Add cases for offered, requested, unknown if needed
         default:
           // Keep default grey state
           break;
    }


    return Card(
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16), // Made const
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconData, color: textColor),
                const SizedBox(width: 8),
                Text(
                  titleText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              bodyText,
              style: const TextStyle(fontSize: 14), // Made const
            ),
            const SizedBox(height: 16),
            // Show lender info if status is accepted or completed
            if ((item.status == ItemStatus.accepted || item.status == ItemStatus.completed) && item.lenderId != null)
              _buildLenderInfoForStatusCard(context, item),

             // Button to open chat (maybe always show if lenderId exists?)
             if (item.lenderId != null && item.status != ItemStatus.cancelled && item.status != ItemStatus.completed) // Example condition
               Padding(
                 padding: const EdgeInsets.only(top: 16.0),
                 child: CustomButton(
                        text: 'Open Chat',
                        onPressed: () {
                          // Ensure ProfileController provides requester/lender names
                          // You might need to fetch the requester profile too
                          final profileController = Provider.of<ProfileController>(context, listen: false);
                          final currentUserId = profileController.currentUserId;
                          final otherUserId = (item.requesterId == currentUserId) ? item.lenderId : item.requesterId;
                          // Fetching names might be async, handle potential nulls
                          final recipientName = (item.requesterId == currentUserId) ? item.lenderName : item.ownerName;

                          if (otherUserId != null) {
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  // Generate a consistent chat ID
                                  chatId: _generateChatId(item.id, item.requesterId, otherUserId),
                                  itemName: item.title,
                                  recipientName: recipientName ?? 'User',
                                  otherUserId: otherUserId,
                                ),
                              ),
                            );
                          } else {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not determine chat recipient.'))
                            );
                          }
                        },
                      ),
               ),

          ],
        ),
      ),
    );
  }

   // Helper to build lender info within the status card
  Widget _buildLenderInfoForStatusCard(BuildContext context, ItemModel item) {
    // Use lenderId from the unified model
     return FutureBuilder<UserProfile?>(
                future: Provider.of<ProfileController>(context, listen: false)
                    .getProfileById(item.lenderId!), // Assume lenderId is non-null here
                builder: (context, snapshot) {
                  final UserProfile? lender = snapshot.data;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lender:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700], // Subtle color
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
                                ? const Icon(Icons.person, color: Colors.white, size: 18) // Made const
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(lender?.name ?? 'Loading...'),
                        ],
                      ),
                      // Optionally add apartment number if needed: Text('Apt ${lender?.apartment}')
                    ],
                  );
                },
              );
  }


  // Helper to generate a consistent chat ID
  String _generateChatId(String itemId, String user1, String user2) {
    List<String> ids = [user1, user2];
    ids.sort(); // Ensure order doesn't matter
    return '${itemId}_${ids[0]}_${ids[1]}';
  }

  // Helper for showing confirmation dialogs
  Future<bool?> _showConfirmationDialog(BuildContext context, String title, String content) {
    return showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'), // Made const
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes'), // Made const
                ),
              ],
            ),
          );
  }

   // Helper for showing feedback Snackbars
  void _showFeedback(BuildContext context, bool success, String successMessage, String errorMessage) {
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? successMessage : errorMessage),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
     );
  }


  // --- Formatting and Status Helpers ---

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
                style: const TextStyle(fontSize: 16), // Made const
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Updated to use the unified ItemStatus enum
  String _getStatusString(ItemStatus status) {
    switch (status) {
      case ItemStatus.requested: return 'Requested';
      case ItemStatus.offered: return 'Offer Received';
      case ItemStatus.accepted: return 'Matched / Accepted';
      case ItemStatus.completed: return 'Completed / Returned';
      case ItemStatus.cancelled: return 'Cancelled';
      case ItemStatus.unknown:
      default: return 'Unknown';
    }
  }

  // Updated to use the unified ItemStatus enum
  Color _getStatusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.requested: return Colors.blue; // Changed color
      case ItemStatus.offered: return Colors.orange;
      case ItemStatus.accepted: return AppConstants.primaryColor; // Keep consistent
      case ItemStatus.completed: return Colors.green;
      case ItemStatus.cancelled: return Colors.red;
      case ItemStatus.unknown:
      default: return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    // Use intl package for better formatting
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  String _formatDate(DateTime date) {
    // Use intl package
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Uses DurationUnit enum defined in item_model.dart
  String _formatDurationUnit(DurationUnit unit) {
    switch (unit) {
      case DurationUnit.hours: return 'hour(s)'; // Make pluralization clearer
      case DurationUnit.days: return 'day(s)';
      case DurationUnit.weeks: return 'week(s)';
      // Default case not strictly needed if all enum values are handled
    }
  }
}