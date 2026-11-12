class MandiRecord {
  final String? state;
  final String? district;
  final String? market;
  final String? commodity;
  final String? variety;
  final String? grade;
  final String? arrivalDate;
  final double? minPrice;
  final double? maxPrice;
  final double? modalPrice;
  final String? commodityCode;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final bool hasVerifiedCoordinates;
  final Map<String, dynamic> raw;

  const MandiRecord({
    this.state,
    this.district,
    this.market,
    this.commodity,
    this.variety,
    this.grade,
    this.arrivalDate,
    this.minPrice,
    this.maxPrice,
    this.modalPrice,
    this.commodityCode,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.hasVerifiedCoordinates = false,
    this.raw = const {},
  });

  factory MandiRecord.fromJson(Map<String, dynamic> json) {
    return MandiRecord(
      state: json['state'] as String?,
      district: json['district'] as String?,
      market: json['market'] as String?,
      commodity: json['commodity'] as String?,
      variety: json['variety'] as String?,
      grade: json['grade'] as String?,
      arrivalDate: json['arrival_date'] as String?,
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      modalPrice: (json['modal_price'] as num?)?.toDouble(),
      commodityCode: json['commodity_code']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      hasVerifiedCoordinates: json['has_verified_coordinates'] == true,
      raw: (json['raw'] as Map<String, dynamic>?) ?? {},
    );
  }
}

class MandiResponse {
  final bool success;
  final String source;
  final String resourceId;
  final int? totalRecords;
  final int count;
  final int limit;
  final int offset;
  final double? farmerLat;
  final double? farmerLon;
  final double? radiusKm;
  final String? sortBy;
  final List<MandiRecord> records;
  final String? message;

  const MandiResponse({
    required this.success,
    required this.source,
    required this.resourceId,
    this.totalRecords,
    required this.count,
    required this.limit,
    required this.offset,
    this.farmerLat,
    this.farmerLon,
    this.radiusKm,
    this.sortBy,
    required this.records,
    this.message,
  });

  factory MandiResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['records'] as List<dynamic>?) ?? [];
    return MandiResponse(
      success: json['success'] == true,
      source: json['source'] as String? ?? 'data.gov.in',
      resourceId: json['resource_id'] as String? ?? '',
      totalRecords: json['total_records'] as int?,
      count: json['count'] as int? ?? 0,
      limit: json['limit'] as int? ?? 20,
      offset: json['offset'] as int? ?? 0,
      farmerLat: (json['farmer_lat'] as num?)?.toDouble(),
      farmerLon: (json['farmer_lon'] as num?)?.toDouble(),
      radiusKm: (json['radius_km'] as num?)?.toDouble(),
      sortBy: json['sort_by'] as String?,
      records: list.map((e) => MandiRecord.fromJson(e as Map<String, dynamic>)).toList(),
      message: json['message'] as String?,
    );
  }
}

class StateDistrictsInfo {
  final String state;
  final List<String> districts;

  const StateDistrictsInfo({
    required this.state,
    required this.districts,
  });

  factory StateDistrictsInfo.fromJson(Map<String, dynamic> json) {
    return StateDistrictsInfo(
      state: json['state'] as String? ?? '',
      districts: ((json['districts'] as List<dynamic>?) ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class CommodityInfo {
  final String name;
  final String category;
  final String emoji;
  final bool popular;

  const CommodityInfo({
    required this.name,
    this.category = 'vegetable',
    this.emoji = '🌾',
    this.popular = false,
  });

  factory CommodityInfo.fromJson(Map<String, dynamic> json) {
    return CommodityInfo(
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'vegetable',
      emoji: json['emoji'] as String? ?? '🌾',
      popular: json['popular'] == true,
    );
  }
}

