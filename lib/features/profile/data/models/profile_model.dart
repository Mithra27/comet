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
  });

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
    );
  }
}