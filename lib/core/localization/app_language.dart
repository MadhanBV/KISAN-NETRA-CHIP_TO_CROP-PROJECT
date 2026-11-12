import 'package:flutter/material.dart';

/// Immutable data model representing a supported language in CHIP TO CROP.
/// Fully matches the 23 official languages supported by Sarvam-Translate v1.
class AppLanguage {
  final String code; // Full code used by Sarvam AI (e.g. 'kn-IN')
  final String languageCode; // ISO 639-1 code for Flutter Locale (e.g. 'kn')
  final String countryCode; // Country code (e.g. 'IN')
  final String name; // Name in English (e.g. 'Kannada')
  final String nativeName; // Name in native script (e.g. 'ಕನ್ನಡ')

  const AppLanguage({
    required this.code,
    required this.languageCode,
    required this.countryCode,
    required this.name,
    required this.nativeName,
  });

  Locale get locale => Locale(languageCode, countryCode);

  /// Complete list of all 23 official Indian languages supported by Sarvam-Translate v1.
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      code: 'en-IN',
      languageCode: 'en',
      countryCode: 'IN',
      name: 'English',
      nativeName: 'English',
    ),
    AppLanguage(
      code: 'hi-IN',
      languageCode: 'hi',
      countryCode: 'IN',
      name: 'Hindi',
      nativeName: 'हिन्दी',
    ),
    AppLanguage(
      code: 'kn-IN',
      languageCode: 'kn',
      countryCode: 'IN',
      name: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
    ),
    AppLanguage(
      code: 'ta-IN',
      languageCode: 'ta',
      countryCode: 'IN',
      name: 'Tamil',
      nativeName: 'தமிழ்',
    ),
    AppLanguage(
      code: 'te-IN',
      languageCode: 'te',
      countryCode: 'IN',
      name: 'Telugu',
      nativeName: 'తెలుగు',
    ),
    AppLanguage(
      code: 'ml-IN',
      languageCode: 'ml',
      countryCode: 'IN',
      name: 'Malayalam',
      nativeName: 'മലയാളം',
    ),
    AppLanguage(
      code: 'bn-IN',
      languageCode: 'bn',
      countryCode: 'IN',
      name: 'Bengali',
      nativeName: 'বাংলা',
    ),
    AppLanguage(
      code: 'mr-IN',
      languageCode: 'mr',
      countryCode: 'IN',
      name: 'Marathi',
      nativeName: 'मराठी',
    ),
    AppLanguage(
      code: 'gu-IN',
      languageCode: 'gu',
      countryCode: 'IN',
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
    ),
    AppLanguage(
      code: 'pa-IN',
      languageCode: 'pa',
      countryCode: 'IN',
      name: 'Punjabi',
      nativeName: 'ਪੰਜਾਬੀ',
    ),
    AppLanguage(
      code: 'or-IN',
      languageCode: 'or',
      countryCode: 'IN',
      name: 'Odia',
      nativeName: 'ଓଡ଼ିଆ',
    ),
    AppLanguage(
      code: 'as-IN',
      languageCode: 'as',
      countryCode: 'IN',
      name: 'Assamese',
      nativeName: 'অসমীয়া',
    ),
    AppLanguage(
      code: 'brx-IN',
      languageCode: 'brx',
      countryCode: 'IN',
      name: 'Bodo',
      nativeName: 'बर\'',
    ),
    AppLanguage(
      code: 'doi-IN',
      languageCode: 'doi',
      countryCode: 'IN',
      name: 'Dogri',
      nativeName: 'डोगरी',
    ),
    AppLanguage(
      code: 'ks-IN',
      languageCode: 'ks',
      countryCode: 'IN',
      name: 'Kashmiri',
      nativeName: 'کٲشُر',
    ),
    AppLanguage(
      code: 'kok-IN',
      languageCode: 'kok',
      countryCode: 'IN',
      name: 'Konkani',
      nativeName: 'कोंकणी',
    ),
    AppLanguage(
      code: 'mai-IN',
      languageCode: 'mai',
      countryCode: 'IN',
      name: 'Maithili',
      nativeName: 'मैथिली',
    ),
    AppLanguage(
      code: 'mni-IN',
      languageCode: 'mni',
      countryCode: 'IN',
      name: 'Manipuri',
      nativeName: 'মৈতৈলোন্',
    ),
    AppLanguage(
      code: 'ne-IN',
      languageCode: 'ne',
      countryCode: 'IN',
      name: 'Nepali',
      nativeName: 'नेपाली',
    ),
    AppLanguage(
      code: 'sa-IN',
      languageCode: 'sa',
      countryCode: 'IN',
      name: 'Sanskrit',
      nativeName: 'संस्कृतम्',
    ),
    AppLanguage(
      code: 'sat-IN',
      languageCode: 'sat',
      countryCode: 'IN',
      name: 'Santali',
      nativeName: 'ᱥᱟᱱᱛᱟᱲᱤ',
    ),
    AppLanguage(
      code: 'sd-IN',
      languageCode: 'sd',
      countryCode: 'IN',
      name: 'Sindhi',
      nativeName: 'سنڌي',
    ),
    AppLanguage(
      code: 'ur-IN',
      languageCode: 'ur',
      countryCode: 'IN',
      name: 'Urdu',
      nativeName: 'اردو',
    ),
  ];

  static AppLanguage get defaultLanguage => supportedLanguages[0]; // English

  static AppLanguage fromCode(String? code) {
    if (code == null) return defaultLanguage;
    final normalized = code.toLowerCase().replaceAll('_', '-');
    if (normalized == 'od-in' || normalized == 'od') {
      return supportedLanguages.firstWhere((l) => l.code == 'or-IN');
    }
    return supportedLanguages.firstWhere(
      (lang) =>
          lang.code.toLowerCase() == normalized ||
          lang.languageCode.toLowerCase() == normalized,
      orElse: () => defaultLanguage,
    );
  }

  static AppLanguage fromLocale(Locale locale) {
    return supportedLanguages.firstWhere(
      (lang) => lang.languageCode == locale.languageCode,
      orElse: () => defaultLanguage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLanguage &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
