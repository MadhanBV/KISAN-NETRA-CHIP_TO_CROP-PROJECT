import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class FarmerLocationResult {
  final bool success;
  final double? latitude;
  final double? longitude;
  final String? state;
  final String? district;
  final String? locality;
  final String? errorMessage;
  final bool permissionDenied;

  const FarmerLocationResult({
    required this.success,
    this.latitude,
    this.longitude,
    this.state,
    this.district,
    this.locality,
    this.errorMessage,
    this.permissionDenied = false,
  });
}

class LocationService {
  /// Normalize detected state and district names to match standard Indian administrative names
  static String normalizeStateName(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final s = raw.trim();
    if (s.toLowerCase().contains('karnataka')) return 'Karnataka';
    if (s.toLowerCase().contains('maharashtra')) return 'Maharashtra';
    if (s.toLowerCase().contains('tamil nadu')) return 'Tamil Nadu';
    if (s.toLowerCase().contains('telangana')) return 'Telangana';
    if (s.toLowerCase().contains('andhra')) return 'Andhra Pradesh';
    if (s.toLowerCase().contains('madhya pradesh')) return 'Madhya Pradesh';
    if (s.toLowerCase().contains('gujarat')) return 'Gujarat';
    if (s.toLowerCase().contains('punjab')) return 'Punjab';
    if (s.toLowerCase().contains('rajasthan')) return 'Rajasthan';
    if (s.toLowerCase().contains('uttar pradesh')) return 'Uttar Pradesh';
    if (s.toLowerCase().contains('kerala')) return 'Kerala';
    if (s.toLowerCase().contains('delhi')) return 'Delhi';
    return s;
  }

  static String normalizeDistrictName(String? raw, String? state) {
    if (raw == null || raw.trim().isEmpty) return '';
    final d = raw.trim();
    // Common aliases in Karnataka
    if (d.toLowerCase().contains('bengaluru') || d.toLowerCase().contains('bangalore')) {
      return 'Bangalore';
    }
    if (d.toLowerCase().contains('mysore') || d.toLowerCase().contains('mysuru')) {
      return 'Mysuru';
    }
    if (d.toLowerCase().contains('belgaum') || d.toLowerCase().contains('belagavi')) {
      return 'Belagavi';
    }
    if (d.toLowerCase().contains('shimoga') || d.toLowerCase().contains('shivamogga')) {
      return 'Shivamogga';
    }
    if (d.toLowerCase().contains('bellary') || d.toLowerCase().contains('ballari')) {
      return 'Ballari';
    }
    if (d.toLowerCase().contains('tumkur') || d.toLowerCase().contains('tumakuru')) {
      return 'Tumakuru';
    }
    if (d.toLowerCase().contains('pune')) {
      return 'Pune';
    }
    if (d.toLowerCase().contains('mumbai')) {
      return 'Mumbai';
    }
    return d;
  }

  /// Request GPS location and reverse-geocode to State and District
  static Future<FarmerLocationResult> getCurrentFarmerLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const FarmerLocationResult(
          success: false,
          errorMessage: 'Location services are disabled on your phone. Please enable GPS in device settings.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const FarmerLocationResult(
            success: false,
            permissionDenied: true,
            errorMessage: 'Location permission was denied. You can still select your state and district manually.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const FarmerLocationResult(
          success: false,
          permissionDenied: true,
          errorMessage: 'Location permission is permanently denied. You can select your state and district manually.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      String? state;
      String? district;
      String? locality;

      try {
        final placemarks = await Geocoding().placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          state = normalizeStateName(place.administrativeArea);
          district = normalizeDistrictName(
            place.subAdministrativeArea?.isNotEmpty == true
                ? place.subAdministrativeArea
                : place.locality,
            state,
          );
          locality = place.locality ?? place.subLocality;
        }
      } catch (geocodeError) {
        debugPrint('Geocoding error: $geocodeError');
        // Still return valid GPS coordinates even if reverse geocoding had a network glitch
      }

      return FarmerLocationResult(
        success: true,
        latitude: position.latitude,
        longitude: position.longitude,
        state: state,
        district: district,
        locality: locality,
      );
    } catch (e) {
      debugPrint('Location service exception: $e');
      return FarmerLocationResult(
        success: false,
        errorMessage: 'Could not detect location: $e. You can choose state and district manually.',
      );
    }
  }
}
