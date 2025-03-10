import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String ownerName;
  final String category;
  final List<String> images;
  final double? rentAmount;
  final int? rentDuration; // in days
  final bool isAvailable;
  final DateTime createdAt;
  final String? currentBorrowerId;
  final DateTime? borrowStartDate;
  final DateTime? borrowEndDate;
  
  ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.ownerName,
    required this.category,
    required this.images,
    this.rentAmount,
    this.rentDuration,
    required this.isAvailable,
    required this.createdAt,
    this.currentBorrowerId,
    this.borrowStartDate,
    this.borrowEndDate,
  });
  
  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'category': category,
      'images': images,
      'rentAmount': rentAmount,
      'rentDuration': rentDuration,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'currentBorrowerId': currentBorrowerId,
      'borrowStartDate': borrowStartDate != null ? Timestamp.fromDate(borrowStartDate!) : null,
      'borrowEndDate': borrowEndDate != null ? Timestamp.fromDate(borrowEndDate!) : null,
    };
  }
  
  // Create from Map
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      category: map['category'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      rentAmount: map['rentAmount']?.toDouble(),
      rentDuration: map['rentDuration'],
      isAvailable: map['isAvailable'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      currentBorrowerId: map['currentBorrowerId'],
      borrowStartDate: map['borrowStartDate'] != null ? (map['borrowStartDate'] as Timestamp).toDate() : null,
      borrowEndDate: map['borrowEndDate'] != null ? (map['borrowEndDate'] as Timestamp).toDate() : null,
    );
  }
  
  // Create copy with updated fields
  ItemModel copyWith({
    String? name,
    String? description,
    String? category,
    List<String>? images,
    double? rentAmount,
    int? rentDuration,
    bool? isAvailable,
    String? currentBorrowerId,
    DateTime? borrowStartDate,
    DateTime? borrowEndDate,
  }) {
    return ItemModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId,
      ownerName: ownerName,
      category: category ?? this.category,
      images: images ?? this.images,
      rentAmount: rentAmount ?? this.rentAmount,
      rentDuration: rentDuration ?? this.rentDuration,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt,
      currentBorrowerId: currentBorrowerId ?? this.currentBorrowerId,
      borrowStartDate: borrowStartDate ?? this.borrowStartDate,
      borrowEndDate: borrowEndDate ?? this.borrowEndDate,
    );
  }
}