// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'CHIP TO CROP';

  @override
  String get kisanNetra => 'किसान नेत्र';

  @override
  String get chooseYourLanguage => 'अपनी भाषा चुनें';

  @override
  String get selectPreferredLanguage => 'अपनी पसंदीदा भाषा का चयन करें';

  @override
  String get searchLanguage => 'भाषा खोजें...';

  @override
  String get continueAction => 'जारी रखें';

  @override
  String selectedLanguage(String language) {
    return 'Selected: $language';
  }

  @override
  String allLanguages(int count) {
    return 'All Languages ($count)';
  }

  @override
  String get skip => 'छोड़ें';

  @override
  String get next => 'अगला';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get onboarding1Title => 'अपनी फसल के स्वास्थ्य को जानें';

  @override
  String get onboarding1Desc =>
      'एक साधारण स्कैन से फसल की गुणवत्ता, रोगों और संक्रमणों का पता लगाएं।';

  @override
  String get onboarding2Title => 'एक साथ बढ़ें';

  @override
  String get onboarding2Desc =>
      'किसानों से जुड़ें, ज्ञान साझा करें और कृषि उत्पाद खरीदें या बेचें।';

  @override
  String get onboarding3Title => 'हर दिन बेहतर खेती करें';

  @override
  String get onboarding3Desc =>
      'लाइव मौसम के साथ अपडेट रहें और बेहतर खेती संबंधी निर्णय लेने के लिए मार्गदर्शन प्राप्त करें।';

  @override
  String get welcomeToKisanNetra => 'किसान नेत्र में आपका स्वागत है।';

  @override
  String get authChoiceTagline => 'आपका खेत। आपकी पहचान। आपका डिजिटल साथी।';

  @override
  String get register => 'पंजीकरण करें';

  @override
  String get createNewAccount => 'एक नया किसान खाता बनाएँ';

  @override
  String get login => 'लॉगिन करें';

  @override
  String get alreadyHaveAccount => 'क्या आपका खाता पहले से है? साइन इन करें';

  @override
  String get secureBiometricAuth => 'सुरक्षित बायोमेट्रिक चेहरा प्रमाणीकरण';

  @override
  String get farmerRegistration => 'किसान पंजीकरण';

  @override
  String get enterMobileNumber => 'अपना मोबाइल नंबर दर्ज करें';

  @override
  String get registerMobileSubtitle =>
      'आपका मोबाइल नंबर आपका किसान खाता आईडी है। चेहरा प्रमाणीकरण आपके खाते की सुरक्षा करेगा।';

  @override
  String get continueWithFace => 'चेहरा पंजीकरण के साथ जारी रखें';

  @override
  String get alreadyRegistered => 'क्या आप पहले से पंजीकृत हैं?';

  @override
  String get loginHere => 'यहां लॉग इन करें';

  @override
  String get enter10DigitMobile => '10 अंकों का मोबाइल नंबर दर्ज करें';

  @override
  String get errorEnterMobile => 'कृपया अपना मोबाइल नंबर दर्ज करें।';

  @override
  String get errorValidMobile =>
      'कृपया एक मान्य 10-अंकीय मोबाइल नंबर दर्ज करें।';

  @override
  String get welcomeBack => 'वापसी पर स्वागत है।';

  @override
  String get loginMobileSubtitle =>
      'फेस स्कैन से अपनी पहचान सत्यापित करने के लिए अपना पंजीकृत मोबाइल नंबर दर्ज करें।';

  @override
  String get verifyWithFace => 'फेस से सत्यापित करें';

  @override
  String get newToKisanNetra => 'किसान नेत्र में नए हैं?';

  @override
  String get registerNow => 'अभी पंजीकरण करें';

  @override
  String get faceRegistration => 'फेस पंजीकरण';

  @override
  String get faceVerification => 'फेस सत्यापन';

  @override
  String get positionFaceInFrame => 'अपने चेहरे को हरे फ्रेम के अंदर रखें';

  @override
  String get faceCapturedSuccess => 'फेस कैप्चर किया गया • एआई स्कैनिंग पूर्ण';

  @override
  String get keepHeadStraight => 'सिर सीधा रखें और समान रोशनी सुनिश्चित करें';

  @override
  String get cameraPermissionRequired => 'कैमरा अनुमति आवश्यक है';

  @override
  String get cameraPermissionMessage =>
      'अपने चेहरे को स्कैन करने के लिए कृपया अपनी डिवाइस सेटिंग्स में कैमरा एक्सेस सक्षम करें।';

  @override
  String get reviewFacePhoto => 'फेस फोटो की समीक्षा करें';

  @override
  String get confirmFaceForLogin => 'लॉगिन के लिए चेहरा सत्यापित करें';

  @override
  String get ensureFaceVisible =>
      'सुनिश्चित करें कि आपका चेहरा स्पष्ट रूप से दिखाई दे रहा है।';

  @override
  String get biometricConsentText =>
      'मैं सुरक्षित प्रमाणीकरण के लिए अपने चेहरे के स्कैन का उपयोग करने के लिए सहमत हूँ।';

  @override
  String get confirmAndRegister => 'पुष्टि करें और रजिस्टर करें';

  @override
  String get verifyFace => 'चेहरा सत्यापित करें';

  @override
  String get retake => 'फिर से लें';

  @override
  String get grantPermission => 'अनुमति दें';

  @override
  String get preparingBiometricScan =>
      'बायोमेट्रिक स्कैन तैयार किया जा रहा है...';

  @override
  String get encryptingFaceTemplate =>
      'चेहरे के टेम्पलेट को एन्क्रिप्ट किया जा रहा है...';

  @override
  String get matchingFacialBiometric =>
      'चेहरे के बायोमेट्रिक को फेस++ के साथ मिलाया जा रहा है...';

  @override
  String get storingEncryptedRecord =>
      'एन्क्रिप्टेड रिकॉर्ड संग्रहीत किया जा रहा है...';

  @override
  String get authSuccessful => 'प्रमाणीकरण सफल हुआ!';

  @override
  String get verificationFailed => 'सत्यापन विफल';

  @override
  String get tryAgain => 'फिर से प्रयास करें';

  @override
  String remainingAttempts(int count) {
    return 'शेष प्रयास: $count';
  }

  @override
  String get navHome => 'होम';

  @override
  String get navCommunity => 'समुदाय';

  @override
  String get navSell => 'बेचना';

  @override
  String get navMarketplace => 'बाज़ार';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get homeGreeting => 'नमस्ते, किसान';

  @override
  String get homeLocation => 'अपना स्थान सेट करें';

  @override
  String get homeWeatherTitle => 'आज का मौसम';

  @override
  String get homeServicesTitle => 'एआई फसल विश्लेषण';

  @override
  String get homeSupportedCrops => 'समर्थित फसलें';

  @override
  String get homeQuickServices => 'त्वरित सेवाएं';

  @override
  String get qualityDetection => 'गुणवत्ता का पता लगाना';

  @override
  String get qualityDetectionDesc => 'ताजगी और फसल की गुणवत्ता जांचें';

  @override
  String get diseaseDetection => 'रोग का पता लगाना';

  @override
  String get diseaseDetectionDesc => 'फसल रोगों और संक्रमणों की पहचान करें';

  @override
  String get leafDiseaseDetection => 'Leaf Disease Detection';

  @override
  String get leafDiseaseDetectionDesc =>
      'Scan leaf photo for instant AI diagnosis, symptoms & remedies';

  @override
  String get cropMango => 'आम';

  @override
  String get cropBanana => 'केला';

  @override
  String get cropTomato => 'टमाटर';

  @override
  String get cropPotato => 'आलू';

  @override
  String get serviceWeather => 'मौसम';

  @override
  String get serviceMandiPrices => 'मंडी भाव';

  @override
  String get serviceAIAssistant => 'एआई असिस्टेंट';

  @override
  String get serviceLabour => 'मजदूरी ढूंढो';

  @override
  String get weatherLoading => 'मौसम डेटा लोड हो रहा है...';

  @override
  String get weatherUnavailable => 'मौसम डेटा अनुपलब्ध है';

  @override
  String get weatherSetLocation => 'मौसम के लिए अपना स्थान सेट करें';

  @override
  String get weatherRetry => 'फिर से प्रयास करें';

  @override
  String get weatherAdvisory => 'खेती की सलाह';

  @override
  String get myProfile => 'मेरी प्रोफाइल';

  @override
  String get myAiReports => 'मेरी एआई रिपोर्ट';

  @override
  String get myListings => 'मेरी लिस्टिंग';

  @override
  String get savedProducts => 'सहेजे गए उत्पाद';

  @override
  String get myConversations => 'मेरी बातचीत';

  @override
  String get language => 'भाषा';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get helpSupport => 'मदद और समर्थन';

  @override
  String get comingSoon => 'जल्द ही आ रहा है';

  @override
  String get featureComingSoonDesc =>
      'यह सुविधा विकसित की जा रही है और जल्द ही उपलब्ध होगी।';
}
