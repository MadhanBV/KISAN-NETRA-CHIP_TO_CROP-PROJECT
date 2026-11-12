/// Application configuration container for CHIP TO CROP.
///
/// Designed to load environment variables, endpoints, and feature flags
/// without hardcoding any sensitive credentials in the source code.
class AppConfig {
  AppConfig._();

  // FastAPI Backend Endpoints
  // Uses 127.0.0.1:8000 via ADB reverse (adb reverse tcp:8000 tcp:8000) for real devices, desktop & emulator.
  static String backendBaseUrl = 'http://127.0.0.1:8000';
  static String backendWsUrl = 'ws://127.0.0.1:8000/ws';

  // Weather Service Endpoint (Planned integration)
  static String weatherApiBaseUrl = '';
  static String weatherApiKey = '';

  // Government Mandi API Endpoint (Planned integration)
  static String mandiApiBaseUrl = '';
  static String mandiApiKey = '';

  // AI & Voice Services (Sarvam AI / RAG)
  static String sarvamApiKey = '';

  // Timeout settings
  static const Duration apiTimeout = Duration(seconds: 15);
  static const Duration connectTimeout = Duration(seconds: 10);

  /// Helper to check if external weather API is configured
  static bool get isWeatherApiConfigured =>
      weatherApiBaseUrl.isNotEmpty && weatherApiKey.isNotEmpty;

  /// Helper to check if mandi API is configured
  static bool get isMandiApiConfigured =>
      mandiApiBaseUrl.isNotEmpty && mandiApiKey.isNotEmpty;
}
