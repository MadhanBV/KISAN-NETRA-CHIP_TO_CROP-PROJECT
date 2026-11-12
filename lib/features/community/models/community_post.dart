class CommunityPost {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String cropType;
  final String title;
  final String description;
  final String imageUrl;
  final int likesCount;
  final DateTime createdAt;

  const CommunityPost({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.cropType,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.likesCount,
    required this.createdAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id']?.toString() ?? '',
      farmerId: json['farmer_id']?.toString() ?? '',
      farmerName: json['farmer_name']?.toString() ?? 'Farmer',
      farmerPhone: json['farmer_phone']?.toString() ?? '',
      cropType: json['crop_type']?.toString() ?? 'General',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

