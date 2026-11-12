import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_data.dart';
import '../../mandi/services/location_service.dart';

class WeatherApiService {
  static const String _apiKey = '60560f4bf5ba414fbd8212307260411';
  static const String _baseUrl = 'https://api.weatherapi.com/v1/forecast.json';
  static const String _cacheKey = 'cached_weather_json';
  static const String _locationKey = 'cached_weather_location';

  static final WeatherApiService _instance = WeatherApiService._internal();
  factory WeatherApiService() => _instance;
  WeatherApiService._internal();

  AgriculturalWeather? _currentWeather;
  AgriculturalWeather? get currentWeather => _currentWeather;

  /// Fetch weather by query string (e.g. "Bengaluru", "Pune", "Hassan") or GPS coordinates.
  /// If neither is given, attempts to get GPS via LocationService, or falls back to last saved location.
  Future<AgriculturalWeather> getWeather({
    String? locationQuery,
    double? latitude,
    double? longitude,
    bool forceRefresh = false,
  }) async {
    // If not forcing refresh and we have cached memory weather, return it
    if (!forceRefresh && _currentWeather != null && locationQuery == null && latitude == null) {
      return _currentWeather!;
    }

    String queryParam = '';

    if (latitude != null && longitude != null) {
      queryParam = '$latitude,$longitude';
    } else if (locationQuery != null && locationQuery.trim().isNotEmpty) {
      queryParam = locationQuery.trim();
    } else {
      // Try GPS location first
      try {
        final loc = await LocationService.getCurrentFarmerLocation();
        if (loc.success && loc.latitude != null && loc.longitude != null) {
          queryParam = '${loc.latitude},${loc.longitude}';
        } else if (loc.district != null && loc.district!.isNotEmpty) {
          queryParam = loc.district!;
        }
      } catch (e) {
        debugPrint('Location service GPS error: $e');
      }

      // If still empty, check stored preference
      if (queryParam.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        queryParam = prefs.getString(_locationKey) ?? 'Bengaluru';
      }
    }

    final uri = Uri.parse('$_baseUrl?key=$_apiKey&q=${Uri.encodeComponent(queryParam)}&days=3&aqi=yes&alerts=yes');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final weather = AgriculturalWeather.fromJson(data);
        _currentWeather = weather;

        // Cache the response
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, response.body);
        await prefs.setString(_locationKey, weather.cityName);

        return weather;
      } else {
        throw Exception('WeatherAPI returned status code ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching live weather: $e');
      // Attempt cache recovery
      final cached = await getCachedWeather();
      if (cached != null) {
        _currentWeather = cached;
        return cached;
      }
      rethrow;
    }
  }

  /// Load cached weather data from SharedPreferences
  Future<AgriculturalWeather?> getCachedWeather() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_cacheKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        final weather = AgriculturalWeather.fromJson(data);
        _currentWeather = weather;
        return weather;
      }
    } catch (e) {
      debugPrint('Failed to load cached weather: $e');
    }
    return null;
  }

  /// Get currently saved city/location name
  Future<String> getSavedLocationName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_locationKey) ?? 'Bengaluru';
  }
}

