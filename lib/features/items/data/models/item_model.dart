// Replace the existing ItemModel class in lib/features/items/data/models/item_model.dart
// with this consolidated version.

import 'package:cloud_firestore/cloud_firestore.dart';

// --- Enums defined above this line ---
enum ItemStatus { requested, offered, accepted, completed, cancelled, unknown }
enum DurationUnit { hours, days, weeks }
// --- ---

class ItemModel {
  final String id;
  final String title; // Changed from name
  final String description;
  final String requesterId; // Added: Who is requesting the item
  final String ownerName; // Kept: Name of the user requesting (redundant?) -> Maybe rename to requesterName
  final String category;
  final List<String> imageUrls; // Changed from images
  final ItemStatus status; // Added
  final DateTime createdAt;
  final DateTime? startDate; // Added: When the item is needed from
  final DateTime? endDate; // Added: When the item is needed until
  final int? duration; // Added: Optional duration
  final DurationUnit? durationUnit; // Added: Optional duration unit
  final bool isUrgent; // Added
  final String? lenderId; // Added: Who offered/accepted to lend
  final String? lenderName; // Added: Name of the lender

  // Removed: ownerId (use requesterId), rentAmount, rentDuration, isAvailable,
  // currentBorrowerId, borrowStartDate, borrowEndDate (use startDate/endDate/lenderId/status instead)
  // Kept ownerName but consider renaming to requesterName

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requesterId, // Changed from ownerId
    required this.ownerName, // Consider renaming this field
    required this.category,
    required this.imageUrls, // Changed from images
    required this.status, // Added
    required this.createdAt,
    this.startDate, // Added
    this.endDate, // Added
    this.duration, // Added
    this.durationUnit, // Added
    this.isUrgent = false, // Added with default
    this.lenderId, // Added
    this.lenderName, // Added
  });

  // Convert ItemModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requesterId': requesterId,
      'ownerName': ownerName, // Remember to handle potential rename
      'category': category,
      'imageUrls': imageUrls,
      'status': status.name, // Store enum as string
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'duration': duration,
      'durationUnit': durationUnit?.name, // Store enum as string or null
      'isUrgent': isUrgent,
      'lenderId': lenderId,
      'lenderName': lenderName,
    };
  }

  // Create ItemModel from Firestore Map
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] ?? '',
      title: map['title'] ?? map['name'] ?? '', // Handle old 'name' field if needed
      description: map['description'] ?? '',
      requesterId: map['requesterId'] ?? map['ownerId'] ?? '', // Handle old 'ownerId'
      ownerName: map['ownerName'] ?? '', // Handle potential rename
      category: map['category'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? map['images'] ?? []), // Handle old 'images'
      // Deserialize status safely
      status: ItemStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => ItemStatus.unknown, // Default if status string is invalid/missing
          ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(), // Handle potential null
      startDate: (map['startDate'] as Timestamp?)?.toDate(), // Handle potential null
      endDate: (map['endDate'] as Timestamp?)?.toDate(), // Handle potential null
      duration: map['duration'] as int?, // Handle potential null type mismatch
      // Deserialize durationUnit safely
      durationUnit: map['durationUnit'] != null
          ? DurationUnit.values.firstWhere(
              (e) => e.name == map['durationUnit'],
              orElse: () => null, // Use null if string is invalid
            )
          : null,
      isUrgent: map['isUrgent'] ?? false,
      lenderId: map['lenderId'] as String?, // Handle potential null
      lenderName: map['lenderName'] as String?, // Handle potential null
    );
  }

  // Create copy with updated fields (ensure all fields are included)
   ItemModel copyWith({
    String? id,
    String? title,
    String? description,
    String? requesterId,
    String? ownerName, // Handle potential rename
    String? category,
    List<String>? imageUrls,
    ItemStatus? status,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    int? duration,
    DurationUnit? durationUnit,
    bool? isUrgent,
    String? lenderId,
    String? lenderName,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      requesterId: requesterId ?? this.requesterId,
      ownerName: ownerName ?? this.ownerName,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      duration: duration ?? this.duration,
      durationUnit: durationUnit ?? this.durationUnit,
      isUrgent: isUrgent ?? this.isUrgent,
      lenderId: lenderId ?? this.lenderId,
      lenderName: lenderName ?? this.lenderName,
    );
  }
}