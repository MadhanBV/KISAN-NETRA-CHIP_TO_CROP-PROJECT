import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../models/auth_models.dart';

/// Client service communicating with the CHIP TO CROP FastAPI backend.
class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  /// Check whether an account exists for a phone number.
  Future<bool> checkPhoneExists(String phoneNumber) async {
    try {
      final uri = Uri.parse(
        '${AppConfig.backendBaseUrl}/api/auth/check-phone?phone_number=${Uri.encodeComponent(phoneNumber)}',
      );
      final response = await _client.get(uri).timeout(AppConfig.apiTimeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] == true;
      }
      return false;
    } catch (_) {
      // In offline / dev mode without backend, return false
      return false;
    }
  }

  /// Register a new farmer with phone number, captured face image, and consent.
  Future<AuthResult> register({
    required String phoneNumber,
    required List<int> imageBytes,
    required String filename,
    required bool consent,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/auth/register');
      final request = http.MultipartRequest('POST', uri)
        ..fields['phone_number'] = phoneNumber
        ..fields['consent'] = consent.toString()
        ..files.add(
          http.MultipartFile.fromBytes(
            'face_image',
            imageBytes,
            filename: filename,
          ),
        );

      final streamedResponse =
          await _client.send(request).timeout(AppConfig.apiTimeout);
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (streamedResponse.statusCode == 200) {
        return AuthResult.success(
          message: data['message'] ?? 'Registration successful!',
          token: data['access_token'],
          farmerId: data['farmer_id'],
          isDemo: data['is_demo'] ?? false,
        );
      } else {
        return AuthResult.failure(
          message: data['detail'] ?? 'Registration failed. Please try again.',
          errorCode: 'REGISTRATION_ERROR',
        );
      }
    } on SocketException {
      return AuthResult.failure(
        message:
            'Server unavailable. Cannot connect to ${AppConfig.backendBaseUrl}. Please ensure the backend is running.',
        errorCode: 'SERVER_UNAVAILABLE',
      );
    } on TimeoutException {
      return AuthResult.failure(
        message: 'Request timed out while contacting server. Please check your network connection.',
        errorCode: 'NETWORK_TIMEOUT',
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Network error: $e',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Verify farmer face against registered profile via Face++ backend comparison.
  Future<AuthResult> login({
    required String phoneNumber,
    required List<int> imageBytes,
    required String filename,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/auth/login');
      final request = http.MultipartRequest('POST', uri)
        ..fields['phone_number'] = phoneNumber
        ..files.add(
          http.MultipartFile.fromBytes(
            'face_image',
            imageBytes,
            filename: filename,
          ),
        );

      final streamedResponse =
          await _client.send(request).timeout(AppConfig.apiTimeout);
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (streamedResponse.statusCode == 200) {
        final success = data['success'] == true;
        if (success) {
          final tokenData = data['token'];
          return AuthResult.success(
            message: data['message'] ?? 'Face verified successfully.',
            token: tokenData != null ? tokenData['access_token'] : null,
            farmerId: tokenData != null ? tokenData['farmer_id'] : null,
            confidence: (data['confidence'] as num?)?.toDouble(),
            isDemo: tokenData != null ? (tokenData['is_demo'] ?? false) : false,
          );
        } else {
          return AuthResult.failure(
            message: data['message'] ?? 'Face verification failed.',
            errorCode: 'VERIFICATION_FAILED',
            remainingAttempts: data['remaining_attempts'],
          );
        }
      } else {
        return AuthResult.failure(
          message: data['detail'] ?? 'Login failed. Please try again.',
          errorCode: streamedResponse.statusCode == 404
              ? 'NOT_REGISTERED'
              : streamedResponse.statusCode == 429
                  ? 'RATE_LIMITED'
                  : 'SERVER_ERROR',
        );
      }
    } on SocketException {
      return AuthResult.failure(
        message:
            'Server unavailable. Cannot connect to ${AppConfig.backendBaseUrl}. Please ensure the backend is running.',
        errorCode: 'SERVER_UNAVAILABLE',
      );
    } on TimeoutException {
      return AuthResult.failure(
        message: 'Request timed out. Please check your network connection.',
        errorCode: 'NETWORK_TIMEOUT',
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Network error: $e',
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }
}

