// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appName => 'CHIP TO CROP';

  @override
  String get kisanNetra => 'ಕಿಸಾನ್ ನೇತ್ರ';

  @override
  String get chooseYourLanguage => 'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get selectPreferredLanguage => 'ನಿಮ್ಮ ಆದ್ಯತೆಯ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get searchLanguage => 'ಭಾಷೆಯನ್ನು ಹುಡುಕಿ...';

  @override
  String get continueAction => 'ಮುಂದುವರಿಸಿ';

  @override
  String selectedLanguage(String language) {
    return 'ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ: $language';
  }

  @override
  String allLanguages(int count) {
    return 'ಎಲ್ಲಾ ಭಾಷೆಗಳು ($count)';
  }

  @override
  String get skip => 'ಬಿಟ್ಟುಬಿಡಿ';

  @override
  String get next => 'ಮುಂದೆ';

  @override
  String get getStarted => 'ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get onboarding1Title => 'ನಿಮ್ಮ ಬೆಳೆಯ ಆರೋಗ್ಯವನ್ನು ತಿಳಿಯಿರಿ';

  @override
  String get onboarding1Desc =>
      'ಸರಳ ಸ್ಕ್ಯಾನ್‌ನೊಂದಿಗೆ ಬೆಳೆಯ ಗುಣಮಟ್ಟ, ರೋಗಗಳು ಮತ್ತು ಸೋಂಕುಗಳನ್ನು ಪತ್ತೆ ಮಾಡಿ.';

  @override
  String get onboarding2Title => 'ಒಟ್ಟಿಗೆ ಬೆಳೆಯಿರಿ';

  @override
  String get onboarding2Desc =>
      'ರೈತರೊಂದಿಗೆ ಸಂಪರ್ಕ ಸಾಧಿಸಿ, ಜ್ಞಾನವನ್ನು ಹಂಚಿಕೊಳ್ಳಿ ಮತ್ತು ಕೃಷಿ ಉತ್ಪನ್ನಗಳನ್ನು ಖರೀದಿಸಿ ಅಥವಾ ಮಾರಾಟ ಮಾಡಿ.';

  @override
  String get onboarding3Title => 'ಪ್ರತಿದಿನ ಜಾಣತನದಿಂದ ಕೃಷಿ ಮಾಡಿ';

  @override
  String get onboarding3Desc =>
      'ಇತ್ತೀಚಿನ ಹವಾಮಾನದೊಂದಿಗೆ ನವೀಕೃತವಾಗಿರಿ ಮತ್ತು ಉತ್ತಮ ಕೃಷಿ ನಿರ್ಧಾರಗಳಿಗಾಗಿ ಮಾರ್ಗದರ್ಶನ ಪಡೆಯಿರಿ.';

  @override
  String get welcomeToKisanNetra => 'ಕಿಸಾನ್ ನೇತ್ರಕ್ಕೆ ಸ್ವಾಗತ';

  @override
  String get authChoiceTagline =>
      'ನಿಮ್ಮ ಜಮೀನು. ನಿಮ್ಮ ಗುರುತು. ನಿಮ್ಮ ಡಿಜಿಟಲ್ ಸಂಗಾತಿ.';

  @override
  String get register => 'ನೋಂದಾಯಿಸಿ';

  @override
  String get createNewAccount => 'ಹೊಸ ರೈತ ಖಾತೆಯನ್ನು ರಚಿಸಿ';

  @override
  String get login => 'ಲಾಗಿನ್';

  @override
  String get alreadyHaveAccount =>
      'ಈಗಾಗಲೇ ಖಾತೆಯನ್ನು ಹೊಂದಿದ್ದೀರಾ? ಸೈನ್ ಇನ್ ಮಾಡಿ';

  @override
  String get secureBiometricAuth => 'ಸುರಕ್ಷಿತ ಬಯೋಮೆಟ್ರಿಕ್ ಮುಖ ದೃಢೀಕರಣ';

  @override
  String get farmerRegistration => 'ರೈತ ನೋಂದಣಿ';

  @override
  String get enterMobileNumber => 'ನಿಮ್ಮ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ';

  @override
  String get registerMobileSubtitle =>
      'ನಿಮ್ಮ ಮೊಬೈಲ್ ಸಂಖ್ಯೆ ನಿಮ್ಮ ರೈತ ಖಾತೆಯ ID ಆಗಿದೆ. ಮುಖ ದೃಢೀಕರಣವು ನಿಮ್ಮ ಖಾತೆಯನ್ನು ರಕ್ಷಿಸುತ್ತದೆ.';

  @override
  String get continueWithFace => 'ಮುಖ ದೃಢೀಕರಣದೊಂದಿಗೆ ಮುಂದುವರಿಸಿ';

  @override
  String get alreadyRegistered => 'ಈಗಾಗಲೇ ನೋಂದಾಯಿಸಿದ್ದೀರಾ?';

  @override
  String get loginHere => 'ಇಲ್ಲಿ ಲಾಗಿನ್ ಮಾಡಿ';

  @override
  String get enter10DigitMobile => '10-ಅಂಕಿಯ ಮೊಬೈಲ್ ನಮೂದಿಸಿ';

  @override
  String get errorEnterMobile => 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ';

  @override
  String get errorValidMobile =>
      'ದಯವಿಟ್ಟು ಮಾನ್ಯವಾದ 10-ಅಂಕಿಯ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ';

  @override
  String get welcomeBack => 'ಮರಳಿ ಸ್ವಾಗತ';

  @override
  String get loginMobileSubtitle =>
      'ನಿಮ್ಮ ಗುರುತನ್ನು ಫೇಸ್ ಸ್ಕ್ಯಾನ್ ಮೂಲಕ ಪರಿಶೀಲಿಸಲು ನಿಮ್ಮ ನೋಂದಾಯಿತ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ.';

  @override
  String get verifyWithFace => 'ಫೇಸ್ ಮೂಲಕ ಪರಿಶೀಲಿಸಿ';

  @override
  String get newToKisanNetra => 'ಕಿಸಾನ್ ನೇತ್ರಕ್ಕೆ ಹೊಸಬರೇ?';

  @override
  String get registerNow => 'ಈಗಲೇ ನೋಂದಾಯಿಸಿ';

  @override
  String get faceRegistration => 'ಫೇಸ್ ನೋಂದಣಿ';

  @override
  String get faceVerification => 'ಫೇಸ್ ಪರಿಶೀಲನೆ';

  @override
  String get positionFaceInFrame => 'ನಿಮ್ಮ ಮುಖವನ್ನು ಹಸಿರು ಚೌಕಟ್ಟಿನ ಒಳಗೆ ಇರಿಸಿ';

  @override
  String get faceCapturedSuccess =>
      'ಫೇಸ್ ಸೆರೆಹಿಡಿಯಲಾಗಿದೆ • AI ಸ್ಕ್ಯಾನಿಂಗ್ ಪೂರ್ಣಗೊಂಡಿದೆ';

  @override
  String get keepHeadStraight =>
      'ತಲೆಯನ್ನು ನೇರವಾಗಿ ಇರಿಸಿ ಮತ್ತು ಸಮನಾದ ಬೆಳಕನ್ನು ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ';

  @override
  String get cameraPermissionRequired => 'ಕ್ಯಾಮೆರಾ ಅನುಮತಿ ಅಗತ್ಯವಿದೆ';

  @override
  String get cameraPermissionMessage =>
      'ನಿಮ್ಮ ಮುಖವನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ನಿಮ್ಮ ಸಾಧನದ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಕ್ಯಾಮೆರಾ ಪ್ರವೇಶವನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ.';

  @override
  String get reviewFacePhoto => 'ಫೇಸ್ ಫೋಟೋವನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get confirmFaceForLogin => 'ಖಚಿತಪಡಿಸಿ ಲಾಗಿನ್‌ಗಾಗಿ ಮುಖ';

  @override
  String get ensureFaceVisible => 'ನಿಮ್ಮ ಮುಖವು ಸ್ಪಷ್ಟವಾಗಿ ಕಾಣುವಂತೆ ನೋಡಿಕೊಳ್ಳಿ.';

  @override
  String get biometricConsentText =>
      'ಸುರಕ್ಷಿತ ದೃಢೀಕರಣಕ್ಕಾಗಿ ನನ್ನ ಮುಖದ ಸ್ಕ್ಯಾನ್ ಅನ್ನು ಬಳಸಲು ನಾನು ಸಮ್ಮತಿಸುತ್ತೇನೆ.';

  @override
  String get confirmAndRegister => 'ಖಚಿತಪಡಿಸಿ ಮತ್ತು ನೋಂದಾಯಿಸಿ';

  @override
  String get verifyFace => 'ಮುಖವನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get retake => 'ಮರುಚಿತ್ರ ತೆಗೆಯಿರಿ';

  @override
  String get grantPermission => 'ಅನುಮತಿ ನೀಡಿ';

  @override
  String get preparingBiometricScan =>
      'ಬಯೋಮೆಟ್ರಿಕ್ ಸ್ಕ್ಯಾನ್ ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ...';

  @override
  String get encryptingFaceTemplate =>
      'ಮುಖದ ಟೆಂಪ್ಲೇಟ್ ಅನ್ನು ಎನ್‌ಕ್ರಿಪ್ಟ್ ಮಾಡಲಾಗುತ್ತಿದೆ...';

  @override
  String get matchingFacialBiometric =>
      'ಫೇಸ್++ ನೊಂದಿಗೆ ಹೊಂದಾಣಿಕೆಯಾಗುವ ಮುಖದ ಬಯೋಮೆಟ್ರಿಕ್...';

  @override
  String get storingEncryptedRecord =>
      'ಎನ್‌ಕ್ರಿಪ್ಟ್ ಮಾಡಿದ ದಾಖಲೆಯನ್ನು ಸಂಗ್ರಹಿಸಲಾಗುತ್ತಿದೆ...';

  @override
  String get authSuccessful => 'ದೃಢೀಕರಣ ಯಶಸ್ವಿಯಾಗಿದೆ!';

  @override
  String get verificationFailed => 'ಪರಿಶೀಲನೆ ವಿಫಲವಾಗಿದೆ';

  @override
  String get tryAgain => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String remainingAttempts(int count) {
    return 'ಉಳಿದ ಪ್ರಯತ್ನಗಳು: $count';
  }

  @override
  String get navHome => 'ಮುಖಪುಟ';

  @override
  String get navCommunity => 'ಸಮುದಾಯ';

  @override
  String get navSell => 'ಮಾರಾಟ';

  @override
  String get navMarketplace => 'ಮಾರುಕಟ್ಟೆ';

  @override
  String get navProfile => 'ವಿವರಣೆ';

  @override
  String get homeGreeting => 'ನಮಸ್ಕಾರ, ರೈತ';

  @override
  String get homeLocation => 'ನಿಮ್ಮ ಸ್ಥಳವನ್ನು ಹೊಂದಿಸಿ';

  @override
  String get homeWeatherTitle => 'ಇಂದಿನ ವಾತಾವರಣ';

  @override
  String get homeServicesTitle => 'AI ಬೆಳೆ ವಿಶ್ಲೇಷಣೆ';

  @override
  String get homeSupportedCrops => 'ಬೆಂಬಲಿತ ಬೆಳೆಗಳು';

  @override
  String get homeQuickServices => 'ತ್ವರಿತ ಸೇವೆಗಳು';

  @override
  String get qualityDetection => 'ಗುಣಮಟ್ಟ ಪತ್ತೆ';

  @override
  String get qualityDetectionDesc => 'ತಾಜಾತನ ಮತ್ತು ಬೆಳೆ ಗುಣಮಟ್ಟವನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get diseaseDetection => 'ರೋಗ ಪತ್ತೆ';

  @override
  String get diseaseDetectionDesc => 'ಬೆಳೆ ರೋಗಗಳು ಮತ್ತು ಸೋಂಕುಗಳನ್ನು ಗುರುತಿಸಿ';

  @override
  String get leafDiseaseDetection => 'Leaf Disease Detection';

  @override
  String get leafDiseaseDetectionDesc =>
      'Scan leaf photo for instant AI diagnosis, symptoms & remedies';

  @override
  String get cropMango => 'ಮಾವಿನ ಹಣ್ಣು';

  @override
  String get cropBanana => 'ಬಾಳೆಹಣ್ಣು';

  @override
  String get cropTomato => 'ಟೊಮೆಟೊ';

  @override
  String get cropPotato => 'ಆಲೂಗಡ್ಡೆ';

  @override
  String get serviceWeather => 'ಹವಾಮಾನ';

  @override
  String get serviceMandiPrices => 'ಮಂಡಿ ಬೆಲೆಗಳು';

  @override
  String get serviceAIAssistant => 'AI ಸಹಾಯಕ';

  @override
  String get serviceLabour => 'ಕಾರ್ಮಿಕರನ್ನು ಹುಡುಕಿ';

  @override
  String get weatherLoading => 'ಹವಾಮಾನ ದತ್ತಾಂಶವನ್ನು ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ...';

  @override
  String get weatherUnavailable => 'ಹವಾಮಾನ ದತ್ತಾಂಶ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get weatherSetLocation => 'ಹವಾಮಾನಕ್ಕಾಗಿ ನಿಮ್ಮ ಸ್ಥಳವನ್ನು ಹೊಂದಿಸಿ';

  @override
  String get weatherRetry => 'ಮರುಪ್ರಯತ್ನಿಸಿ';

  @override
  String get weatherAdvisory => 'ಕೃಷಿ ಸಲಹೆ';

  @override
  String get myProfile => 'ನನ್ನ ಪ್ರೊಫೈಲ್';

  @override
  String get myAiReports => 'ನನ್ನ AI ವರದಿಗಳು';

  @override
  String get myListings => 'ನನ್ನ ಪಟ್ಟಿಗಳು';

  @override
  String get savedProducts => 'ಉಳಿಸಿದ ಉತ್ಪನ್ನಗಳು';

  @override
  String get myConversations => 'ನನ್ನ ಸಂಭಾಷಣೆಗಳು';

  @override
  String get language => 'ಭಾಷೆ';

  @override
  String get settings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get helpSupport => 'ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ';

  @override
  String get comingSoon => 'ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ';

  @override
  String get featureComingSoonDesc =>
      'ಈ ವೈಶಿಷ್ಟ್ಯವನ್ನು ಅಭಿವೃದ್ಧಿಪಡಿಸಲಾಗುತ್ತಿದೆ ಮತ್ತು ಶೀಘ್ರದಲ್ಲೇ ಲಭ್ಯವಿರುತ್ತದೆ.';
}
