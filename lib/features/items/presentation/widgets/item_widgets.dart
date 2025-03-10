import 'package:flutter/material.dart';
import 'package:comet/config/theme.dart';
import 'package:comet/features/items/data/models/item_model.dart';
import 'package:intl/intl.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;
  final VoidCallback? onOffer;

  const ItemCard({
    Key? key,
    required this.item,
    required this.onTap,
    this.onOffer,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image or placeholder
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: item.imageUrls.isNotEmpty
                  ? Image.network(
                      item.imageUrls.first,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildStatusChip(item.status),
                      const Spacer(),
                      Text(
                        _formatTimeAgo(item.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('MMM dd').format(item.startDate)} - ${DateFormat('MMM dd').format(item.endDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (onOffer != null && item.status == ItemStatus.requested)
                        TextButton(
                          onPressed: onOffer,
                          child: const Text('Offer'),
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

  Widget _buildPlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image,
          size: 60,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ItemStatus status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case ItemStatus.requested:
        chipColor = AppColors.accent;
        statusText = 'Requested';
        break;
      case ItemStatus.offered:
        chipColor = Colors.amber;
        statusText = 'Offered';
        break;
      case ItemStatus.accepted:
        chipColor = AppColors.primary;
        statusText = 'Accepted';
        break;
      case ItemStatus.completed:
        chipColor = Colors.green;
        statusText = 'Completed';
        break;
      case ItemStatus.cancelled:
        chipColor = Colors.red;
        statusText = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 7) {
      return DateFormat('MMM dd').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              backgroundColor: Colors.grey[200],
              selectedColor: AppColors.primary.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ItemDetailCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback? onAccept;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final VoidCallback? onChat;

  const ItemDetailCard({
    Key? key,
    required this.item,
    this.onAccept,
    this.onComplete,
    this.onCancel,
    this.onChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrls.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: PageView.builder(
                    itemCount: item.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        item.imageUrls[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                _buildStatusChip(item.status),
                const Spacer(),
                Text(
                  'Category: ${item.category}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Posted by ${item.ownerName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('MMM dd, yyyy').format(item.startDate)} - ${DateFormat('MMM dd, yyyy').format(item.endDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ItemStatus status) {
    Color chipColor;
    String statusText;

    switch (status) {
      case ItemStatus.requested:
        chipColor = AppColors.accent;
        statusText = 'Requested';
        break;
      case ItemStatus.offered:
        chipColor = Colors.amber;
        statusText = 'Offered';
        break;
      case ItemStatus.accepted:
        chipColor = AppColors.primary;
        statusText = 'Accepted';
        break;
      case ItemStatus.completed:
        chipColor = Colors.green;
        statusText = 'Completed';
        break;
      case ItemStatus.cancelled:
        chipColor = Colors.red;
        statusText = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (onChat != null)
          ElevatedButton.icon(
            onPressed: onChat,
            icon: const Icon(Icons.chat),
            label: const Text('Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        if (onAccept != null)
          ElevatedButton.icon(
            onPressed: onAccept,
            icon: const Icon(Icons.check_circle),
            label: const Text('Accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        if (onComplete != null)
          ElevatedButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.done_all),
            label: const Text('Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        if (onCancel != null)
          ElevatedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }
}