// lib/features/profile/data/models/profile_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String apartment;
  final String? imageUrl;
  final bool isVerified;
  final bool is2FAEnabled;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final int trustScore;
  final List<String> interests;
  
  // Added fields needed by ProfileInfoCard
  final String? photoUrl;
  final String fullName;
  final String apartmentNumber;
  final double rating;
  final int reviewCount;
  final String? bio;
  final int itemsShared;
  final int itemsBorrowed;
  final int activeRequests;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.apartment,
    this.imageUrl,
    this.isVerified = false,
    this.is2FAEnabled = false,
    required this.createdAt,
    this.updatedAt,
    this.trustScore = 0,
    this.interests = const [],
    // Initialize the new fields
    this.photoUrl,
    String? fullName,
    String? apartmentNumber,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.bio,
    this.itemsShared = 0,
    this.itemsBorrowed = 0,
    this.activeRequests = 0,
  }) : 
    // Set fullName and apartmentNumber based on existing fields if not provided
    this.fullName = fullName ?? name,
    this.apartmentNumber = apartmentNumber ?? apartment;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      apartment: json['apartment'] ?? '',
      imageUrl: json['imageUrl'],
      isVerified: json['isVerified'] ?? false,
      is2FAEnabled: json['is2FAEnabled'] ?? false,
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'],
      trustScore: json['trustScore'] ?? 0,
      interests: List<String>.from(json['interests'] ?? []),
      // Additional fields
      photoUrl: json['photoUrl'] ?? json['imageUrl'],
      bio: json['bio'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      itemsShared: json['itemsShared'] ?? 0,
      itemsBorrowed: json['itemsBorrowed'] ?? 0,
      activeRequests: json['activeRequests'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'apartment': apartment,
      'imageUrl': imageUrl,
      'isVerified': isVerified,
      'is2FAEnabled': is2FAEnabled,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? Timestamp.now(),
      'trustScore': trustScore,
      'interests': interests,
      // Additional fields
      'photoUrl': photoUrl,
      'bio': bio,
      'rating': rating,
      'reviewCount': reviewCount,
      'itemsShared': itemsShared,
      'itemsBorrowed': itemsBorrowed,
      'activeRequests': activeRequests,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? apartment,
    String? imageUrl,
    bool? isVerified,
    bool? is2FAEnabled,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    int? trustScore,
    List<String>? interests,
    // Additional fields
    String? photoUrl,
    String? fullName,
    String? apartmentNumber,
    double? rating,
    int? reviewCount,
    String? bio,
    int? itemsShared,
    int? itemsBorrowed,
    int? activeRequests,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      apartment: apartment ?? this.apartment,
      imageUrl: imageUrl ?? this.imageUrl,
      isVerified: isVerified ?? this.isVerified,
      is2FAEnabled: is2FAEnabled ?? this.is2FAEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trustScore: trustScore ?? this.trustScore,
      interests: interests ?? this.interests,
      // Additional fields
      photoUrl: photoUrl ?? this.photoUrl,
      fullName: fullName ?? this.fullName,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      bio: bio ?? this.bio,
      itemsShared: itemsShared ?? this.itemsShared,
      itemsBorrowed: itemsBorrowed ?? this.itemsBorrowed,
      activeRequests: activeRequests ?? this.activeRequests,
    );
  }
}