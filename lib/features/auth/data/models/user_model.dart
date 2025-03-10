import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String apartmentNumber;
  final String community;
  final DateTime createdAt;
  final bool twoFactorEnabled;
  final String twoFactorSecret;
  final String? profileImage;
  final String? phoneNumber;
  final String? fcmToken;
  final List<String>? favoriteItems;
  final Map<String, dynamic>? privacySettings;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.apartmentNumber,
    required this.community,
    required this.createdAt,
    required this.twoFactorEnabled,
    required this.twoFactorSecret,
    this.profileImage,
    this.phoneNumber,
    this.fcmToken,
    this.favoriteItems,
    this.privacySettings,
  });

  // Convert UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'apartmentNumber': apartmentNumber,
      'community': community,
      'createdAt': createdAt,
      'twoFactorEnabled': twoFactorEnabled,
      'twoFactorSecret': twoFactorSecret,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
      'fcmToken': fcmToken,
      'favoriteItems': favoriteItems ?? [],
      'privacySettings': privacySettings ?? {
        'showPhoneNumber': false,
        'showApartmentNumber': false,
        'allowNotifications': true,
      },
    };
  }

  // Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      apartmentNumber: map['apartmentNumber'] ?? '',
      community: map['community'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      twoFactorEnabled: map['twoFactorEnabled'] ?? false,
      twoFactorSecret: map['twoFactorSecret'] ?? '',
      profileImage: map['profileImage'],
      phoneNumber: map['phoneNumber'],
      fcmToken: map['fcmToken'],
      favoriteItems: List<String>.from(map['favoriteItems'] ?? []),
      privacySettings: map['privacySettings'],
    );
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? name,
    String? email,
    String? apartmentNumber,
    String? community,
    bool? twoFactorEnabled,
    String? twoFactorSecret,
    String? profileImage,
    String? phoneNumber,
    String? fcmToken,
    List<String>? favoriteItems,
    Map<String, dynamic>? privacySettings,
  }) {
    return UserModel(
      uid: this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      community: community ?? this.community,
      createdAt: this.createdAt,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      twoFactorSecret: twoFactorSecret ?? this.twoFactorSecret,
      profileImage: profileImage ?? this.profileImage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fcmToken: fcmToken ?? this.fcmToken,
      favoriteItems: favoriteItems ?? this.favoriteItems,
      privacySettings: privacySettings ?? this.privacySettings,
    );
  }
}