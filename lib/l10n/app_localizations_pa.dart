// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get appName => 'CHIP TO CROP';

  @override
  String get kisanNetra => 'ਕਿਸਾਨ ਨੇਤਰਾ';

  @override
  String get chooseYourLanguage => 'ਆਪਣੀ ਭਾਸ਼ਾ ਚੁਣੋ';

  @override
  String get selectPreferredLanguage => 'ਆਪਣੀ ਪਸੰਦੀਦਾ ਭਾਸ਼ਾ ਚੁਣੋ';

  @override
  String get searchLanguage => 'ਭਾਸ਼ਾ ਖੋਜੋ...';

  @override
  String get continueAction => 'ਜਾਰੀ ਰੱਖੋ';

  @override
  String selectedLanguage(String language) {
    return 'ਚੁਣੀ ਗਈ: $language';
  }

  @override
  String allLanguages(int count) {
    return 'ਸਾਰੀਆਂ ਭਾਸ਼ਾਵਾਂ ($count)';
  }

  @override
  String get skip => 'ਛੱਡੋ';

  @override
  String get next => 'ਅੱਗੇ';

  @override
  String get getStarted => 'ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get onboarding1Title => 'ਆਪਣੀ ਫਸਲ ਦੀ ਸਿਹਤ ਜਾਣੋ';

  @override
  String get onboarding1Desc =>
      'ਇੱਕ ਸਧਾਰਨ ਸਕੈਨ ਨਾਲ ਫਸਲ ਦੀ ਗੁਣਵੱਤਾ, ਬਿਮਾਰੀਆਂ ਅਤੇ ਇਨਫੈਕਸ਼ਨਾਂ ਦਾ ਪਤਾ ਲਗਾਓ।';

  @override
  String get onboarding2Title => 'ਇਕੱਠੇ ਵਧੋ';

  @override
  String get onboarding2Desc =>
      'ਕਿਸਾਨਾਂ ਨਾਲ ਜੁੜੋ, ਗਿਆਨ ਸਾਂਝਾ ਕਰੋ ਅਤੇ ਖੇਤੀਬਾੜੀ ਉਤਪਾਦ ਖਰੀਦੋ ਜਾਂ ਵੇਚੋ।';

  @override
  String get onboarding3Title => 'ਹਰ ਰੋਜ਼ ਸਮਝਦਾਰੀ ਨਾਲ ਖੇਤੀ ਕਰੋ';

  @override
  String get onboarding3Desc =>
      'ਇੱਥੇ ਲਾਈਵ ਮੌਸਮ ਬਾਰੇ ਜਾਣਕਾਰੀ ਪ੍ਰਾਪਤ ਕਰੋ ਅਤੇ ਬਿਹਤਰ ਖੇਤੀਬਾੜੀ ਫੈਸਲਿਆਂ ਲਈ ਮਾਰਗਦਰਸ਼ਨ ਲਵੋ।';

  @override
  String get welcomeToKisanNetra => 'ਕਿਸਾਨ ਨੇਤਰਾ ਵਿੱਚ ਤੁਹਾਡਾ ਸੁਆਗਤ ਹੈ।';

  @override
  String get authChoiceTagline =>
      'ਤੁਹਾਡਾ ਖੇਤ। ਤੁਹਾਡੀ ਪਛਾਣ। ਤੁਹਾਡੀ ਡਿਜੀਟਲ ਸਾਥੀ।';

  @override
  String get register => 'ਰਜਿਸਟਰ ਕਰੋ';

  @override
  String get createNewAccount => 'ਇੱਕ ਨਵਾਂ ਕਿਸਾਨ ਖਾਤਾ ਬਣਾਓ';

  @override
  String get login => 'ਲਾਗਇਨ ਕਰੋ';

  @override
  String get alreadyHaveAccount => 'ਕੀ ਤੁਹਾਡਾ ਪਹਿਲਾਂ ਤੋਂ ਖਾਤਾ ਹੈ? ਸਾਈਨ ਇਨ ਕਰੋ';

  @override
  String get secureBiometricAuth => 'ਸੁਰੱਖਿਅਤ ਬਾਇਓਮੀਟ੍ਰਿਕ ਫੇਸ ਪ੍ਰਮਾਣਿਕਤਾ';

  @override
  String get farmerRegistration => 'ਕਿਸਾਨ ਰਜਿਸਟ੍ਰੇਸ਼ਨ';

  @override
  String get enterMobileNumber => 'ਆਪਣਾ ਮੋਬਾਈਲ ਨੰਬਰ ਦਰਜ ਕਰੋ';

  @override
  String get registerMobileSubtitle =>
      'ਤੁਹਾਡਾ ਮੋਬਾਈਲ ਨੰਬਰ ਤੁਹਾਡੀ ਕਿਸਾਨ ਖਾਤਾ ID ਹੈ। ਫੇਸ ਪ੍ਰਮਾਣਿਕਤਾ ਤੁਹਾਡੇ ਖਾਤੇ ਦੀ ਸੁਰੱਖਿਆ ਕਰੇਗੀ।';

  @override
  String get continueWithFace => 'ਫੇਸ ਰਜਿਸਟ੍ਰੇਸ਼ਨ ਨਾਲ ਜਾਰੀ ਰੱਖੋ';

  @override
  String get alreadyRegistered => 'ਕੀ ਪਹਿਲਾਂ ਤੋਂ ਰਜਿਸਟਰਡ ਹੋ?';

  @override
  String get loginHere => 'ਇੱਥੇ ਲਾਗਇਨ ਕਰੋ';

  @override
  String get enter10DigitMobile => '10-ਅੰਕਾਂ ਦਾ ਮੋਬਾਈਲ ਨੰਬਰ ਦਰਜ ਕਰੋ';

  @override
  String get errorEnterMobile => 'ਕਿਰਪਾ ਕਰਕੇ ਆਪਣਾ ਮੋਬਾਈਲ ਨੰਬਰ ਦਰਜ ਕਰੋ।';

  @override
  String get errorValidMobile =>
      'ਕਿਰਪਾ ਕਰਕੇ ਇੱਕ ਵੈਧ 10-ਅੰਕਾਂ ਦਾ ਮੋਬਾਈਲ ਨੰਬਰ ਦਰਜ ਕਰੋ।';

  @override
  String get welcomeBack => 'ਵਾਪਸੀ \'ਤੇ ਤੁਹਾਡਾ ਸੁਆਗਤ ਹੈ।';

  @override
  String get loginMobileSubtitle =>
      'ਫੇਸ ਸਕੈਨ ਨਾਲ ਆਪਣੀ ਪਛਾਣ ਤਸਦੀਕ ਕਰਨ ਲਈ ਆਪਣਾ ਰਜਿਸਟਰਡ ਮੋਬਾਈਲ ਨੰਬਰ ਦਰਜ ਕਰੋ।';

  @override
  String get verifyWithFace => 'ਫੇਸ ਨਾਲ ਤਸਦੀਕ ਕਰੋ';

  @override
  String get newToKisanNetra => 'ਕਿਸਾਨ ਨੇਤਰਾ ਲਈ ਨਵੇਂ ਹੋ?';

  @override
  String get registerNow => 'ਹੁਣੇ ਰਜਿਸਟਰ ਕਰੋ';

  @override
  String get faceRegistration => 'ਫੇਸ ਰਜਿਸਟ੍ਰੇਸ਼ਨ';

  @override
  String get faceVerification => 'ਫੇਸ ਤਸਦੀਕ';

  @override
  String get positionFaceInFrame => 'ਆਪਣੇ ਚਿਹਰੇ ਨੂੰ ਹਰੇ ਫਰੇਮ ਦੇ ਅੰਦਰ ਰੱਖੋ';

  @override
  String get faceCapturedSuccess => 'ਫੇਸ ਕੈਪਚਰ ਹੋ ਗਿਆ • AI ਸਕੈਨਿੰਗ ਪੂਰੀ ਹੋ ਗਈ';

  @override
  String get keepHeadStraight =>
      'ਸਿਰ ਸਿੱਧਾ ਰੱਖੋ ਅਤੇ ਯਕੀਨੀ ਬਣਾਓ ਕਿ ਰੋਸ਼ਨੀ ਵੀ ਬਰਾਬਰ ਹੋਵੇ';

  @override
  String get cameraPermissionRequired => 'ਕੈਮਰਾ ਇਜਾਜ਼ਤ ਦੀ ਲੋੜ ਹੈ';

  @override
  String get cameraPermissionMessage =>
      'ਆਪਣੇ ਚਿਹਰੇ ਨੂੰ ਸਕੈਨ ਕਰਨ ਲਈ ਕਿਰਪਾ ਕਰਕੇ ਆਪਣੀ ਡਿਵਾਈਸ ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਕੈਮਰਾ ਐਕਸੈਸ ਨੂੰ ਸਮਰੱਥ ਕਰੋ।';

  @override
  String get reviewFacePhoto => 'ਫੇਸ ਫੋਟੋ ਦੀ ਸਮੀਖਿਆ ਕਰੋ';

  @override
  String get confirmFaceForLogin => 'ਲਾਗਇਨ ਕਰਨ ਲਈ ਚਿਹਰਾ ਤਸਦੀਕ ਕਰੋ';

  @override
  String get ensureFaceVisible =>
      'ਯਕੀਨੀ ਬਣਾਓ ਕਿ ਤੁਹਾਡਾ ਚਿਹਰਾ ਸਾਫ਼ ਦਿਖਾਈ ਦੇ ਰਿਹਾ ਹੈ।';

  @override
  String get biometricConsentText =>
      'ਮੈਂ ਸੁਰੱਖਿਅਤ ਪ੍ਰਮਾਣਿਕਤਾ ਲਈ ਆਪਣੇ ਚਿਹਰੇ ਦੇ ਸਕੈਨ ਦੀ ਵਰਤੋਂ ਕਰਨ ਲਈ ਸਹਿਮਤ ਹਾਂ।';

  @override
  String get confirmAndRegister => 'ਪੁਸ਼ਟੀ ਕਰੋ ਅਤੇ ਰਜਿਸਟਰ ਕਰੋ';

  @override
  String get verifyFace => 'ਚਿਹਰਾ ਤਸਦੀਕ ਕਰੋ';

  @override
  String get retake => 'ਦੁਬਾਰਾ ਫੋਟੋ ਖਿੱਚੋ';

  @override
  String get grantPermission => 'ਇਜਾਜ਼ਤ ਦਿਓ';

  @override
  String get preparingBiometricScan =>
      'ਬਾਇਓਮੀਟ੍ਰਿਕ ਸਕੈਨ ਤਿਆਰ ਕੀਤਾ ਜਾ ਰਿਹਾ ਹੈ...';

  @override
  String get encryptingFaceTemplate =>
      'ਫੇਸ ਟੈਮਪਲੇਟ ਨੂੰ ਐਨਕ੍ਰਿਪਟ ਕੀਤਾ ਜਾ ਰਿਹਾ ਹੈ...';

  @override
  String get matchingFacialBiometric =>
      'ਫੇਸ++ ਨਾਲ ਚਿਹਰੇ ਦੇ ਬਾਇਓਮੀਟ੍ਰਿਕ ਦਾ ਮੇਲ ਕੀਤਾ ਜਾ ਰਿਹਾ ਹੈ...';

  @override
  String get storingEncryptedRecord =>
      'ਐਨਕ੍ਰਿਪਟਡ ਰਿਕਾਰਡ ਸਟੋਰ ਕੀਤਾ ਜਾ ਰਿਹਾ ਹੈ...';

  @override
  String get authSuccessful => 'ਪ੍ਰਮਾਣਿਕਤਾ ਸਫਲ!';

  @override
  String get verificationFailed => 'ਤਸਦੀਕ ਅਸਫਲ';

  @override
  String get tryAgain => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String remainingAttempts(int count) {
    return 'ਬਾਕੀ ਕੋਸ਼ਿਸ਼ਾਂ: $count';
  }

  @override
  String get navHome => 'ਘਰ';

  @override
  String get navCommunity => 'ਕਮਿਊਨਿਟੀ';

  @override
  String get navSell => 'ਵੇਚੋ';

  @override
  String get navMarketplace => 'ਮਾਰਕੀਟਪਲੇਸ';

  @override
  String get navProfile => 'ਪ੍ਰੋਫਾਈਲ';

  @override
  String get homeGreeting => 'ਸਤਿ ਸ੍ਰੀ ਅਕਾਲ, ਕਿਸਾਨ';

  @override
  String get homeLocation => 'ਆਪਣੀ ਲੋਕੇਸ਼ਨ ਸੈੱਟ ਕਰੋ';

  @override
  String get homeWeatherTitle => 'ਅੱਜ ਦਾ ਮੌਸਮ';

  @override
  String get homeServicesTitle => 'ਏ.ਆਈ. ਫ਼ਸਲ ਵਿਸ਼ਲੇਸ਼ਣ';

  @override
  String get homeSupportedCrops => 'ਸਮਰਥਿਤ ਫ਼ਸਲਾਂ';

  @override
  String get homeQuickServices => 'ਤੁਰੰਤ ਸੇਵਾਵਾਂ';

  @override
  String get qualityDetection => 'ਕੁਆਲਿਟੀ ਡਿਟੈਕਸ਼ਨ';

  @override
  String get qualityDetectionDesc => 'ਤਾਜ਼ਗੀ ਅਤੇ ਫ਼ਸਲ ਦੀ ਕੁਆਲਿਟੀ ਦੀ ਜਾਂਚ ਕਰੋ';

  @override
  String get diseaseDetection => 'ਬਿਮਾਰੀ ਦੀ ਜਾਂਚ';

  @override
  String get diseaseDetectionDesc =>
      'ਫ਼ਸਲਾਂ ਦੀਆਂ ਬਿਮਾਰੀਆਂ ਅਤੇ ਇਨਫੈਕਸ਼ਨਾਂ ਦੀ ਪਛਾਣ ਕਰੋ';

  @override
  String get leafDiseaseDetection => 'Leaf Disease Detection';

  @override
  String get leafDiseaseDetectionDesc =>
      'Scan leaf photo for instant AI diagnosis, symptoms & remedies';

  @override
  String get cropMango => 'ਅੰਬ';

  @override
  String get cropBanana => 'ਕੇਲਾ';

  @override
  String get cropTomato => 'ਟਮਾਟਰ';

  @override
  String get cropPotato => 'ਆਲੂ';

  @override
  String get serviceWeather => 'ਮੌਸਮ';

  @override
  String get serviceMandiPrices => 'ਮੰਡੀ ਕੀਮਤਾਂ';

  @override
  String get serviceAIAssistant => 'ਏ.ਆਈ. ਅਸਿਸਟੈਂਟ';

  @override
  String get serviceLabour => 'ਮਜ਼ਦੂਰ ਲੱਭੋ';

  @override
  String get weatherLoading => 'ਮੌਸਮ ਡਾਟਾ ਲੋਡ ਹੋ ਰਿਹਾ ਹੈ...';

  @override
  String get weatherUnavailable => 'ਮੌਸਮ ਡਾਟਾ ਉਪਲਬਧ ਨਹੀਂ ਹੈ';

  @override
  String get weatherSetLocation => 'ਮੌਸਮ ਲਈ ਆਪਣੀ ਲੋਕੇਸ਼ਨ ਸੈੱਟ ਕਰੋ';

  @override
  String get weatherRetry => 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ';

  @override
  String get weatherAdvisory => 'ਖੇਤੀਬਾੜੀ ਸਲਾਹ';

  @override
  String get myProfile => 'ਮੇਰੀ ਪ੍ਰੋਫਾਈਲ';

  @override
  String get myAiReports => 'ਮੇਰੀਆਂ ਏ.ਆਈ. ਰਿਪੋਰਟਾਂ';

  @override
  String get myListings => 'ਮੇਰੀਆਂ ਸੂਚੀਆਂ';

  @override
  String get savedProducts => 'ਸੁਰੱਖਿਅਤ ਕੀਤੇ ਉਤਪਾਦ';

  @override
  String get myConversations => 'ਮੇਰੀਆਂ ਗੱਲਾਂ';

  @override
  String get language => 'ਭਾਸ਼ਾ';

  @override
  String get settings => 'ਸੈਟਿੰਗਾਂ';

  @override
  String get helpSupport => 'ਮਦਦ ਅਤੇ ਸਹਾਇਤਾ';

  @override
  String get comingSoon => 'ਜਲਦੀ ਹੀ ਆ ਰਿਹਾ ਹੈ';

  @override
  String get featureComingSoonDesc =>
      'ਇਹ ਵਿਸ਼ੇਸ਼ਤਾ ਵਿਕਸਤ ਕੀਤੀ ਜਾ ਰਹੀ ਹੈ ਅਤੇ ਜਲਦੀ ਹੀ ਉਪਲਬਧ ਹੋਵੇਗੀ।';
}
