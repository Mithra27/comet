class Community {
  String id;
  String name;
  String description;
  String adminId;
  List<String> members;
  String imageUrl;
  DateTime createdAt;
  String address;
  String gateCode;
  bool isPrivate;
  
  Community({
    this.id = '',
    required this.name,
    required this.description,
    this.adminId = '',
    this.members = const [],
    this.imageUrl = '',
    DateTime? createdAt,
    required this.address,
    this.gateCode = '',
    this.isPrivate = true,
  }) : this.createdAt = createdAt ?? DateTime.now();
  
  factory Community.fromMap(Map<String, dynamic> map, String documentId) {
    return Community(
      id: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      adminId: map['adminId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      address: map['address'] ?? '',
      gateCode: map['gateCode'] ?? '',
      isPrivate: map['isPrivate'] ?? true,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'adminId': adminId,
      'members': members,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'address': address,
      'gateCode': gateCode,
      'isPrivate': isPrivate,
    };
  }
}