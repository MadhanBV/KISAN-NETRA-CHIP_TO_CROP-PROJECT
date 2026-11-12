// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appName => 'CHIP TO CROP';

  @override
  String get kisanNetra => 'किसान नेत्र';

  @override
  String get chooseYourLanguage => 'आफ्नो भाषा छान्नुहोस्';

  @override
  String get selectPreferredLanguage => 'आफ्नो मनपर्ने भाषा छान्नुहोस्';

  @override
  String get searchLanguage => 'भाषा खोज्नुहोस्...';

  @override
  String get continueAction => 'जारी राख्नुहोस्';

  @override
  String selectedLanguage(String language) {
    return 'चयन गरिएको: $language';
  }

  @override
  String allLanguages(int count) {
    return 'सबै भाषाहरू ($count)';
  }

  @override
  String get skip => 'छोड्नुहोस्';

  @override
  String get next => 'अर्को';

  @override
  String get getStarted => 'सुरु गर्नुहोस्';

  @override
  String get onboarding1Title => 'आफ्नो बालीको स्वास्थ्य जान्नुहोस्';

  @override
  String get onboarding1Desc =>
      'सरल स्क्यानको साथ बालीको गुणस्तर, रोग र संक्रमण पत्ता लगाउनुहोस्।';

  @override
  String get onboarding2Title => 'सँगै हुर्कनुहोस्';

  @override
  String get onboarding2Desc =>
      'किसानहरूसँग जोडिनुहोस्, ज्ञान बाँड्नुहोस् र कृषि उत्पादनहरू किन्न वा बेच्नुहोस्।';

  @override
  String get onboarding3Title => 'हरेक दिन स्मार्ट तरिकाले खेती गर्नुहोस्';

  @override
  String get onboarding3Desc =>
      'यहाँ प्रत्यक्ष मौसमको जानकारी पाउनुहोस् र राम्रो खेतीका निर्णयहरूका लागि मार्गदर्शन प्राप्त गर्नुहोस्।';

  @override
  String get welcomeToKisanNetra => 'किसान नेत्रमा स्वागत छ।';

  @override
  String get authChoiceTagline =>
      'तपाईंको खेत। तपाईंको पहिचान। तपाईंको डिजिटल साथी।';

  @override
  String get register => 'दर्ता गर्नुहोस्';

  @override
  String get createNewAccount => 'नयाँ किसान खाता खोल्नुहोस्';

  @override
  String get login => 'लगइन गर्नुहोस्';

  @override
  String get alreadyHaveAccount => 'पहिले नै खाता छ? साइन इन गर्नुहोस्';

  @override
  String get secureBiometricAuth => 'सुरक्षित बायोमेट्रिक अनुहार प्रमाणीकरण';

  @override
  String get farmerRegistration => 'किसान दर्ता';

  @override
  String get enterMobileNumber => 'आफ्नो मोबाइल नम्बर प्रविष्ट गर्नुहोस्';

  @override
  String get registerMobileSubtitle =>
      'तपाईंको मोबाइल नम्बर तपाईंको किसान खाता आईडी हो। अनुहार प्रमाणीकरणले तपाईंको खातालाई सुरक्षित राख्नेछ।';

  @override
  String get continueWithFace => 'अनुहार दर्ताको साथ जारी राख्नुहोस्';

  @override
  String get alreadyRegistered => 'पहिले नै दर्ता भइसक्यो?';

  @override
  String get loginHere => 'यहाँ लगइन गर्नुहोस्';

  @override
  String get enter10DigitMobile => '10-अङ्कको मोबाइल प्रविष्ट गर्नुहोस्';

  @override
  String get errorEnterMobile => 'कृपया आफ्नो मोबाइल नम्बर प्रविष्ट गर्नुहोस्।';

  @override
  String get errorValidMobile =>
      'कृपया मान्य 10-अङ्कको मोबाइल नम्बर प्रविष्ट गर्नुहोस्।';

  @override
  String get welcomeBack => 'फेरि स्वागत छ।';

  @override
  String get loginMobileSubtitle =>
      'फेस स्क्यानबाट आफ्नो पहिचान प्रमाणित गर्न आफ्नो दर्ता गरिएको मोबाइल नम्बर प्रविष्ट गर्नुहोस्।';

  @override
  String get verifyWithFace => 'फेसबाट प्रमाणित गर्नुहोस्।';

  @override
  String get newToKisanNetra => 'किसान नेत्रमा नयाँ हुनुहुन्छ?';

  @override
  String get registerNow => 'अहिले दर्ता गर्नुहोस्।';

  @override
  String get faceRegistration => 'फेस दर्ता।';

  @override
  String get faceVerification => 'फेस प्रमाणीकरण।';

  @override
  String get positionFaceInFrame => 'हरियो फ्रेमभित्र आफ्नो अनुहार राख्नुहोस्।';

  @override
  String get faceCapturedSuccess => 'अनुहार कैद भयो • एआई स्क्यानिङ पूरा भयो।';

  @override
  String get keepHeadStraight =>
      'टाउको सीधा राख्नुहोस् र समान प्रकाश सुनिश्चित गर्नुहोस्।';

  @override
  String get cameraPermissionRequired => 'क्यामेरा अनुमति आवश्यक छ।';

  @override
  String get cameraPermissionMessage =>
      'कृपया आफ्नो अनुहार स्क्यान गर्न आफ्नो उपकरण सेटिङमा क्यामेरा पहुँच सक्षम गर्नुहोस्।';

  @override
  String get reviewFacePhoto => 'अनुहारको फोटो हेर्नुहोस्।';

  @override
  String get confirmFaceForLogin => 'लगइनको लागि अनुहार निश्चित गर्नुहोस्';

  @override
  String get ensureFaceVisible =>
      'तपाईंको अनुहार स्पष्ट रूपमा देखिने सुनिश्चित गर्नुहोस्।';

  @override
  String get biometricConsentText =>
      'म सुरक्षित प्रमाणीकरणको लागि मेरो अनुहार स्क्यान प्रयोग गर्न सहमत छु।';

  @override
  String get confirmAndRegister => 'निश्चित गर्नुहोस् र दर्ता गर्नुहोस्';

  @override
  String get verifyFace => 'अनुहार प्रमाणित गर्नुहोस्';

  @override
  String get retake => 'फेरि खिच्नुहोस्';

  @override
  String get grantPermission => 'अनुमति दिनुहोस्';

  @override
  String get preparingBiometricScan => 'बायोमेट्रिक स्क्यान तयार गर्दै...';

  @override
  String get encryptingFaceTemplate => 'अनुहार टेम्प्लेट इन्क्रिप्ट गर्दै...';

  @override
  String get matchingFacialBiometric =>
      'अनुहारको बायोमेट्रिकलाई फेस++ सँग मिलाउँदै...';

  @override
  String get storingEncryptedRecord => 'इन्क्रिप्टेड रेकर्ड भण्डारण गर्दै...';

  @override
  String get authSuccessful => 'प्रमाणीकरण सफल भयो!';

  @override
  String get verificationFailed => 'प्रमाणीकरण असफल भयो';

  @override
  String get tryAgain => 'फेरि प्रयास गर्नुहोस्';

  @override
  String remainingAttempts(int count) {
    return 'बाँकी प्रयासहरू: $count';
  }

  @override
  String get navHome => 'घर';

  @override
  String get navCommunity => 'समुदाय';

  @override
  String get navSell => 'बेच्नुहोस्';

  @override
  String get navMarketplace => 'बजार';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get homeGreeting => 'नमस्कार, किसान';

  @override
  String get homeLocation => 'आफ्नो स्थान सेट गर्नुहोस्';

  @override
  String get homeWeatherTitle => 'आजको मौसम';

  @override
  String get homeServicesTitle => 'एआई बाली विश्लेषण';

  @override
  String get homeSupportedCrops => 'समर्थित बालीहरू';

  @override
  String get homeQuickServices => 'छिटो सेवाहरू';

  @override
  String get qualityDetection => 'गुणस्तर पत्ता लगाउनुहोस्';

  @override
  String get qualityDetectionDesc => 'ताजगी र बालीको गुणस्तर जाँच गर्नुहोस्';

  @override
  String get diseaseDetection => 'रोग पत्ता लगाउनुहोस्';

  @override
  String get diseaseDetectionDesc => 'बाली रोग र संक्रमणहरू पहिचान गर्नुहोस्';

  @override
  String get leafDiseaseDetection => 'Leaf Disease Detection';

  @override
  String get leafDiseaseDetectionDesc =>
      'Scan leaf photo for instant AI diagnosis, symptoms & remedies';

  @override
  String get cropMango => 'आँप';

  @override
  String get cropBanana => 'केरा';

  @override
  String get cropTomato => 'टमाटर';

  @override
  String get cropPotato => 'आलु';

  @override
  String get serviceWeather => 'मौसम';

  @override
  String get serviceMandiPrices => 'बजार भाउ';

  @override
  String get serviceAIAssistant => 'एआई सहायक';

  @override
  String get serviceLabour => 'श्रम खोज्नुहोस्';

  @override
  String get weatherLoading => 'मौसम डेटा लोड हुँदैछ...';

  @override
  String get weatherUnavailable => 'मौसम डेटा उपलब्ध छैन';

  @override
  String get weatherSetLocation => 'मौसमको लागि आफ्नो स्थान सेट गर्नुहोस्';

  @override
  String get weatherRetry => 'फेरि प्रयास गर्नुहोस्';

  @override
  String get weatherAdvisory => 'खेती सल्लाह';

  @override
  String get myProfile => 'मेरो प्रोफाइल';

  @override
  String get myAiReports => 'मेरो एआई रिपोर्टहरू';

  @override
  String get myListings => 'मेरो सूचीहरू';

  @override
  String get savedProducts => 'सुरक्षित गरिएका उत्पादनहरू';

  @override
  String get myConversations => 'मेरो कुराकानीहरू';

  @override
  String get language => 'भाषा';

  @override
  String get settings => 'सेटिंगहरू';

  @override
  String get helpSupport => 'मद्दत र समर्थन';

  @override
  String get comingSoon => 'चाँडै आउँदैछ';

  @override
  String get featureComingSoonDesc =>
      'यो सुविधा विकास भइरहेको छ र चाँडै उपलब्ध हुनेछ।';
}
