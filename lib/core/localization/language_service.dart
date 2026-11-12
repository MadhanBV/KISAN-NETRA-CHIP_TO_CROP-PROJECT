import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'app_language.dart';

/// Service responsible for language preference persistence and
/// dynamic translation via the CHIP TO CROP FastAPI backend (Sarvam AI).
class LanguageService {
  static const String _prefKeyLanguageCode = 'chip_to_crop_selected_language_code';
  static const String _prefKeyHasSelected = 'chip_to_crop_has_selected_language';

  final http.Client _httpClient;

  LanguageService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  /// Check whether the farmer has already selected a language on first launch.
  Future<bool> hasSelectedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefKeyHasSelected) ?? false;
    } catch (e) {
      debugPrint('LanguageService: Error reading hasSelectedLanguage: $e');
      return false;
    }
  }

  /// Retrieve the previously saved language preference, or English if none.
  Future<AppLanguage> getSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKeyLanguageCode);
      return AppLanguage.fromCode(code);
    } catch (e) {
      debugPrint('LanguageService: Error reading saved language: $e');
      return AppLanguage.defaultLanguage;
    }
  }

  /// Persist the farmer's selected language preference.
  Future<void> saveLanguage(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyLanguageCode, language.code);
      await prefs.setBool(_prefKeyHasSelected, true);
    } catch (e) {
      debugPrint('LanguageService: Error saving language: $e');
    }
  }

  /// Reset language selection status (for debugging / testing first launch).
  Future<void> resetLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeyLanguageCode);
      await prefs.remove(_prefKeyHasSelected);
    } catch (e) {
      debugPrint('LanguageService: Error resetting language preference: $e');
    }
  }

  /// Dynamic translation for dynamic content (e.g. AI reports, community posts)
  /// using the backend Sarvam AI translation endpoint.
  Future<String?> translateDynamicText({
    required String text,
    required String targetLanguageCode,
    String sourceLanguageCode = 'en-IN',
  }) async {
    if (text.trim().isEmpty || targetLanguageCode == sourceLanguageCode) {
      return text;
    }

    try {
      final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/language/translate');
      final response = await _httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'input': text,
          'source_language_code': sourceLanguageCode,
          'target_language_code': targetLanguageCode,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translated_text'] as String?;
      } else {
        debugPrint('Dynamic translation failed: ${response.statusCode} - ${response.body}');
        return text; // Graceful fallback to original text
      }
    } catch (e) {
      debugPrint('Dynamic translation exception: $e');
      return text; // Graceful fallback
    }
  }
}

