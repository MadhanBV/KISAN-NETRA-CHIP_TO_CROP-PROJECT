import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../models/mandi_models.dart';

class MandiApiService {
  final http.Client _client;

  MandiApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch live mandi prices with optional filters, radius, and sorting
  Future<MandiResponse> fetchPrices({
    String? state,
    String? district,
    String? market,
    String? commodity,
    String? variety,
    int limit = 50,
    int offset = 0,
    double? farmerLat,
    double? farmerLon,
    double? radiusKm,
    String sortBy = 'latest_date',
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
      'sort_by': sortBy,
    };

    if (state != null && state.trim().isNotEmpty) {
      queryParams['state'] = state.trim();
    }
    if (district != null && district.trim().isNotEmpty) {
      queryParams['district'] = district.trim();
    }
    if (market != null && market.trim().isNotEmpty) {
      queryParams['market'] = market.trim();
    }
    if (commodity != null && commodity.trim().isNotEmpty) {
      queryParams['commodity'] = commodity.trim();
    }
    if (variety != null && variety.trim().isNotEmpty) {
      queryParams['variety'] = variety.trim();
    }
    if (farmerLat != null && farmerLon != null) {
      queryParams['farmer_lat'] = farmerLat.toString();
      queryParams['farmer_lon'] = farmerLon.toString();
    }
    if (radiusKm != null && radiusKm > 0) {
      queryParams['radius_km'] = radiusKm.toString();
    }

    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/mandi/prices')
        .replace(queryParameters: queryParams);

    debugPrint('Fetching Mandi prices: $uri');

    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 35));

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return MandiResponse.fromJson(json);
    } else {
      String errorMsg = 'Failed to load mandi prices (${response.statusCode})';
      try {
        final errJson = jsonDecode(response.body);
        if (errJson['detail'] != null) {
          errorMsg = errJson['detail'].toString();
        }
      } catch (_) {}
      throw Exception(errorMsg);
    }
  }

  /// Fetch list of official Indian States and Districts
  Future<List<StateDistrictsInfo>> fetchLocations() async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/mandi/locations');
    final response = await _client.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final list = (json['states'] as List<dynamic>?) ?? [];
      return list
          .map((e) => StateDistrictsInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetch standard and popular commodities
  Future<List<CommodityInfo>> fetchCommodities() async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/mandi/commodities');
    final response = await _client.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final list = (json['all_commodities'] as List<dynamic>?) ?? [];
      return list
          .map((e) => CommodityInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

