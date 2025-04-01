// lib/features/community/data/models/community_model.dart

// **** ENSURE THIS IMPORT IS AT THE TOP AND THE FILE IS SAVED ****
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String? postalCode;
  final String? city;
  final String? state;
  final String? country;
  final String? gateCode;
  final int memberCount;
  final List<String> adminIds;
  final List<String> memberIds;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Add fields potentially used by widgets (can be null)
  final String? imageUrl;
  final String? coverImageUrl;


  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    this.postalCode,
    this.city,
    this.state,
    this.country,
    this.gateCode,
    required this.memberCount,
    required this.adminIds,
    required this.memberIds,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.coverImageUrl,
  });

  factory CommunityModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CommunityModel(
      id: documentId,
      name: map['name'] ?? 'Unnamed Community',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      postalCode: map['postalCode'],
      city: map['city'],
      state: map['state'],
      country: map['country'],
      gateCode: map['gateCode'],
      memberCount: map['memberCount'] ?? 0,
      adminIds: List<String>.from(map['adminIds'] ?? []),
      memberIds: List<String>.from(map['memberIds'] ?? []), // Ensure Firestore field name is correct
      createdBy: map['createdBy'] ?? '',
      // THIS LINE MUST WORK if the import is correct and saved
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'], // Added
      coverImageUrl: map['coverImageUrl'], // Added
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'address': address,
      if (postalCode != null) 'postalCode': postalCode,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (gateCode != null) 'gateCode': gateCode,
      'memberCount': memberCount,
      'adminIds': adminIds,
      'memberIds': memberIds,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (imageUrl != null) 'imageUrl': imageUrl, // Added
      if (coverImageUrl != null) 'coverImageUrl': coverImageUrl, // Added
    };
  }

   CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? postalCode,
    String? city,
    String? state,
    String? country,
    bool setGateCodeNull = false, String? gateCode,
    int? memberCount,
    List<String>? adminIds,
    List<String>? memberIds,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool setImageUrlNull = false, String? imageUrl,
    bool setCoverImageUrlNull = false, String? coverImageUrl,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      gateCode: setGateCodeNull ? null : (gateCode ?? this.gateCode),
      memberCount: memberCount ?? this.memberCount,
      adminIds: adminIds ?? this.adminIds,
      memberIds: memberIds ?? this.memberIds,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: setImageUrlNull ? null : (imageUrl ?? this.imageUrl),
      coverImageUrl: setCoverImageUrlNull ? null : (coverImageUrl ?? this.coverImageUrl),
    );
  }

  @override
  bool operator ==(Object other) => other is CommunityModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}