import 'package:flutter/material.dart';
import 'app_language.dart';
import 'language_service.dart';

/// Lightweight, reactive controller managing the active application Locale.
/// Compatible with Flutter's built-in ChangeNotifier and ListenableBuilder.
class LocaleController extends ChangeNotifier {
  static final LocaleController _singleton = LocaleController._internal();
  factory LocaleController() => _singleton;
  static LocaleController get instance => _singleton;

  final LanguageService _languageService;
  AppLanguage _currentLanguage = AppLanguage.defaultLanguage;
  bool _isInitialized = false;

  LocaleController._internal({LanguageService? languageService})
      : _languageService = languageService ?? LanguageService();

  // Constructor for testing / mocking
  @visibleForTesting
  LocaleController.withService(this._languageService);

  AppLanguage get currentLanguage => _currentLanguage;
  Locale get locale => _currentLanguage.locale;
  bool get isInitialized => _isInitialized;

  /// Load persisted language choice on startup
  Future<void> initialize() async {
    if (_isInitialized) return;
    _currentLanguage = await _languageService.getSavedLanguage();
    _isInitialized = true;
    notifyListeners();
  }

  /// Change application language, persist preference, and trigger immediate UI rebuild
  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    notifyListeners();
    await _languageService.saveLanguage(language);
  }

  /// Direct sync update for testing
  @visibleForTesting
  void updateLanguageDirectly(AppLanguage language) {
    _currentLanguage = language;
    notifyListeners();
  }
}

