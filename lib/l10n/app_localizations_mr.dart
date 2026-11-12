// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'CHIP TO CROP';

  @override
  String get kisanNetra => 'किसान नेत्रा';

  @override
  String get chooseYourLanguage => 'तुमची भाषा निवडा';

  @override
  String get selectPreferredLanguage => 'तुमची आवडती भाषा सिलेक्ट करा';

  @override
  String get searchLanguage => 'भाषा शोधा...';

  @override
  String get continueAction => 'सुरू ठेवा';

  @override
  String selectedLanguage(String language) {
    return 'Selected: $language';
  }

  @override
  String allLanguages(int count) {
    return 'All Languages ($count)';
  }

  @override
  String get skip => 'सोडा';

  @override
  String get next => 'पुढील';

  @override
  String get getStarted => 'सुरुवात करा';

  @override
  String get onboarding1Title => 'तुमच्या पिकाची आरोग्य स्थिती जाणून घ्या';

  @override
  String get onboarding1Desc =>
      'एका साध्या स्कॅनने पिकाची गुणवत्ता, रोग आणि संसर्ग ओळखा.';

  @override
  String get onboarding2Title => 'एकत्र वाढवा';

  @override
  String get onboarding2Desc =>
      'शेतकऱ्यांशी संपर्क साधा, ज्ञान सामायिक करा आणि कृषी उत्पादने खरेदी किंवा विक्री करा.';

  @override
  String get onboarding3Title => 'दररोज अधिक स्मार्ट शेती करा';

  @override
  String get onboarding3Desc =>
      'हवामानाची माहिती मिळवा आणि शेतीसाठी योग्य निर्णय घेण्यासाठी मार्गदर्शन मिळवा.';

  @override
  String get welcomeToKisanNetra => 'किसान नेत्रा मध्ये आपले स्वागत आहे.';

  @override
  String get authChoiceTagline => 'तुमचे शेत. तुमची ओळख. तुमची डिजिटल सोबती.';

  @override
  String get register => 'नोंदणी करा';

  @override
  String get createNewAccount => 'नवीन शेतकरी खाते तयार करा';

  @override
  String get login => 'लॉग इन करा';

  @override
  String get alreadyHaveAccount => 'तुमचे खाते आधीपासून आहे? साइन इन करा';

  @override
  String get secureBiometricAuth => 'सुरक्षित बायोमेट्रिक फेस ऑथेंटिकेशन';

  @override
  String get farmerRegistration => 'शेतकरी नोंदणी';

  @override
  String get enterMobileNumber => 'तुमचा मोबाइल नंबर टाका';

  @override
  String get registerMobileSubtitle =>
      'तुमचा मोबाइल नंबर हा तुमच्या शेतकरी खात्याचा आयडी आहे. फेस ऑथेंटिकेशन तुमच्या खात्याचे संरक्षण करेल.';

  @override
  String get continueWithFace => 'फेस रजिस्ट्रेशन पुढे चालू ठेवा';

  @override
  String get alreadyRegistered => 'आधीच नोंदणी केली आहे?';

  @override
  String get loginHere => 'येथे लॉग इन करा';

  @override
  String get enter10DigitMobile => '10 अंकी मोबाइल नंबर टाका';

  @override
  String get errorEnterMobile => 'कृपया तुमचा मोबाईल नंबर टाका.';

  @override
  String get errorValidMobile => 'कृपया तुमचा वैध 10-अंकी मोबाईल नंबर टाका.';

  @override
  String get welcomeBack => 'पुन्हा स्वागत आहे.';

  @override
  String get loginMobileSubtitle =>
      'फेस स्कॅनद्वारे तुमची ओळख सत्यापित करण्यासाठी तुमचा नोंदणीकृत मोबाईल नंबर टाका.';

  @override
  String get verifyWithFace => 'फेस द्वारे सत्यापित करा.';

  @override
  String get newToKisanNetra => 'किसान नेत्रावर नवीन आहात?';

  @override
  String get registerNow => 'आता नोंदणी करा.';

  @override
  String get faceRegistration => 'फेस नोंदणी.';

  @override
  String get faceVerification => 'फेस पडताळणी.';

  @override
  String get positionFaceInFrame => 'हिरव्या फ्रेममध्ये तुमचा चेहरा ठेवा.';

  @override
  String get faceCapturedSuccess =>
      'चेहरा कॅप्चर झाला • एआय स्कॅनिंग पूर्ण झाले.';

  @override
  String get keepHeadStraight =>
      'डोके सरळ ठेवा आणि प्रकाश व्यवस्थित असल्याची खात्री करा.';

  @override
  String get cameraPermissionRequired => 'कॅमेऱ्याच्या परवानगीची आवश्यकता आहे.';

  @override
  String get cameraPermissionMessage =>
      'तुमचा चेहरा स्कॅन करण्यासाठी कृपया तुमच्या डिव्हाइस सेटिंग्जमध्ये कॅमेरा ॲक्सेस सक्षम करा.';

  @override
  String get reviewFacePhoto => 'चेहऱ्याचा फोटो तपासा.';

  @override
  String get confirmFaceForLogin => 'लॉगिनसाठी चेहरा निश्चित करा';

  @override
  String get ensureFaceVisible =>
      'तुमचा चेहरा स्पष्टपणे दिसत असल्याची खात्री करा.';

  @override
  String get biometricConsentText =>
      'सुरक्षित प्रमाणीकरणासाठी माझा फेस स्कॅन वापरण्यास मी सहमत आहे.';

  @override
  String get confirmAndRegister => 'पुष्टी करा आणि नोंदणी करा';

  @override
  String get verifyFace => 'चेहरा सत्यापित करा';

  @override
  String get retake => 'पुन्हा घ्या';

  @override
  String get grantPermission => 'परवानगी द्या';

  @override
  String get preparingBiometricScan => 'बायोमेट्रिक स्कॅन तयार करत आहे...';

  @override
  String get encryptingFaceTemplate => 'फेस टेम्पलेट एन्क्रिप्ट करत आहे...';

  @override
  String get matchingFacialBiometric =>
      'फेस++ सह चेहऱ्याचे बायोमेट्रिक जुळवत आहे...';

  @override
  String get storingEncryptedRecord => 'एन्क्रिप्टेड रेकॉर्ड साठवत आहे...';

  @override
  String get authSuccessful => 'प्रमाणीकरण यशस्वी झाले!';

  @override
  String get verificationFailed => 'सत्यापन अयशस्वी झाले';

  @override
  String get tryAgain => 'पुन्हा प्रयत्न करा';

  @override
  String remainingAttempts(int count) {
    return 'उर्वरित प्रयत्न: $count';
  }

  @override
  String get navHome => 'मुख्यपृष्ठ';

  @override
  String get navCommunity => 'समुदाय';

  @override
  String get navSell => 'विक्री';

  @override
  String get navMarketplace => 'बाजारपेठ';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get homeGreeting => 'नमस्कार, शेतकरी';

  @override
  String get homeLocation => 'तुमचे स्थान सेट करा';

  @override
  String get homeWeatherTitle => 'आजचे हवामान';

  @override
  String get homeServicesTitle => 'एआय पीक विश्लेषण';

  @override
  String get homeSupportedCrops => 'समर्थित पिके';

  @override
  String get homeQuickServices => 'त्वरित सेवा';

  @override
  String get qualityDetection => 'गुणवत्ता शोध';

  @override
  String get qualityDetectionDesc => 'ताजेपणा आणि पिकाची गुणवत्ता तपासा';

  @override
  String get diseaseDetection => 'रोग शोध';

  @override
  String get diseaseDetectionDesc => 'पिकांचे रोग आणि संसर्ग ओळखा';

  @override
  String get leafDiseaseDetection => 'Leaf Disease Detection';

  @override
  String get leafDiseaseDetectionDesc =>
      'Scan leaf photo for instant AI diagnosis, symptoms & remedies';

  @override
  String get cropMango => 'आंबा';

  @override
  String get cropBanana => 'केळी';

  @override
  String get cropTomato => 'टोमॅटो';

  @override
  String get cropPotato => 'बटाटा';

  @override
  String get serviceWeather => 'हवामान';

  @override
  String get serviceMandiPrices => 'मंडई भाव';

  @override
  String get serviceAIAssistant => 'एआय असिस्टंट';

  @override
  String get serviceLabour => 'मजूर शोधा';

  @override
  String get weatherLoading => 'हवामानाचा डेटा लोड होत आहे...';

  @override
  String get weatherUnavailable => 'हवामानाचा डेटा उपलब्ध नाही';

  @override
  String get weatherSetLocation => 'हवामानासाठी तुमचे स्थान सेट करा';

  @override
  String get weatherRetry => 'पुन्हा प्रयत्न करा';

  @override
  String get weatherAdvisory => 'शेतीविषयक सल्ला';

  @override
  String get myProfile => 'माझी प्रोफाइल';

  @override
  String get myAiReports => 'माझे एआय अहवाल';

  @override
  String get myListings => 'माझ्या याद्या';

  @override
  String get savedProducts => 'साठवलेली उत्पादने';

  @override
  String get myConversations => 'माझ्या संभाषणा';

  @override
  String get language => 'भाषा';

  @override
  String get settings => 'सेटिंग्ज';

  @override
  String get helpSupport => 'मदत आणि आधार';

  @override
  String get comingSoon => 'लवकरच येत आहे';

  @override
  String get featureComingSoonDesc =>
      'हे वैशिष्ट्य विकसित केले जात आहे आणि लवकरच उपलब्ध होईल.';
}
