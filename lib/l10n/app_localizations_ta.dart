// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'CHIP TO CROP';

  @override
  String get kisanNetra => 'கிசான் நேத்ரா';

  @override
  String get chooseYourLanguage => 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectPreferredLanguage =>
      'நீங்கள் விரும்பும் மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get searchLanguage => 'மொழியைத் தேடுங்கள்...';

  @override
  String get continueAction => 'தொடரவும்';

  @override
  String selectedLanguage(String language) {
    return 'தேர்ந்தெடுக்கப்பட்டது: $language';
  }

  @override
  String allLanguages(int count) {
    return 'எல்லா மொழிகளும் ($count)';
  }

  @override
  String get skip => 'தவிர்க்கவும்';

  @override
  String get next => 'அடுத்து';

  @override
  String get getStarted => 'தொடங்கவும்';

  @override
  String get onboarding1Title =>
      'உங்கள் பயிர் ஆரோக்கியத்தை அறிந்து கொள்ளுங்கள்';

  @override
  String get onboarding1Desc =>
      'எளிமையான ஸ்கேன் மூலம் பயிர் தரம், நோய்கள் மற்றும் தொற்றுக்களைக் கண்டறியவும்.';

  @override
  String get onboarding2Title => 'ஒன்றாக வளருங்கள்';

  @override
  String get onboarding2Desc =>
      'விவசாயிகளுடன் இணையுங்கள், அறிவைப் பகிர்ந்து கொள்ளுங்கள் மற்றும் விவசாயப் பொருட்களை வாங்கவும் விற்கவும்.';

  @override
  String get onboarding3Title => 'ஒவ்வொரு நாளும் புத்திசாலித்தனமாக பண்ணுங்கள்';

  @override
  String get onboarding3Desc =>
      'சமீபத்திய வானிலை நிலவரங்களுடன் தொடர்ந்து இணைந்திருங்கள், மேலும் சிறந்த விவசாய முடிவுகளுக்கான வழிகாட்டுதலைப் பெறுங்கள்.';

  @override
  String get welcomeToKisanNetra => 'கிசான் நேத்ராவுக்கு வருக';

  @override
  String get authChoiceTagline =>
      'உங்கள் பண்ணை. உங்கள் அடையாளம். உங்கள் டிஜிட்டல் துணை.';

  @override
  String get register => 'பதிவு செய்க';

  @override
  String get createNewAccount => 'புதிய விவசாயி கணக்கை உருவாக்கவும்';

  @override
  String get login => 'உள்நுழைக';

  @override
  String get alreadyHaveAccount => 'ஏற்கனவே கணக்கு இருக்கிறதா? உள்நுழையவும்';

  @override
  String get secureBiometricAuth => 'பாதுகாப்பான பயோமெட்ரிக் முக அங்கீகாரம்';

  @override
  String get farmerRegistration => 'விவசாயி பதிவு';

  @override
  String get enterMobileNumber => 'உங்கள் மொபைல் எண்ணை உள்ளிடவும்';

  @override
  String get registerMobileSubtitle =>
      'உங்கள் மொபைல் எண்ணே உங்கள் விவசாயி கணக்கு ஐடி. முக அங்கீகாரம் உங்கள் கணக்கைப் பாதுகாக்கும்.';

  @override
  String get continueWithFace => 'முக அங்கீகாரத்துடன் தொடரவும்';

  @override
  String get alreadyRegistered => 'ஏற்கனவே பதிவு செய்தீர்களா?';

  @override
  String get loginHere => 'இங்கே உள்நுழையவும்';

  @override
  String get enter10DigitMobile => '10 இலக்க மொபைல் எண்ணை உள்ளிடவும்';

  @override
  String get errorEnterMobile => 'Please enter your mobile number';

  @override
  String get errorValidMobile => 'Please enter a valid 10-digit mobile number';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginMobileSubtitle =>
      'Enter your registered mobile number to verify your identity with face scan.';

  @override
  String get verifyWithFace => 'VERIFY WITH FACE';

  @override
  String get newToKisanNetra => 'New to Kisan Netra? ';

  @override
  String get registerNow => 'Register now';

  @override
  String get faceRegistration => 'Face Registration';

  @override
  String get faceVerification => 'Face Verification';

  @override
  String get positionFaceInFrame => 'Position your face inside the green frame';

  @override
  String get faceCapturedSuccess => 'Face Captured • AI Scanning Complete';

  @override
  String get keepHeadStraight => 'Keep head straight & ensure even lighting';

  @override
  String get cameraPermissionRequired => 'Camera Permission Required';

  @override
  String get cameraPermissionMessage =>
      'Please enable camera access in your device settings to scan your face.';

  @override
  String get reviewFacePhoto => 'Review Face Photograph';

  @override
  String get confirmFaceForLogin => 'உள்நுழைவுக்கு முகத்தை உறுதிப்படுத்து';

  @override
  String get ensureFaceVisible =>
      'உங்கள் முகம் தெளிவாகத் தெரியுமா என்பதை உறுதிப்படுத்தவும்.';

  @override
  String get biometricConsentText =>
      'பாதுகாப்பான அங்கீகாரத்திற்காக எனது முகத்தை ஸ்கேன் செய்ய நான் ஒப்புக்கொள்கிறேன்.';

  @override
  String get confirmAndRegister => 'உறுதிப்படுத்தி பதிவு செய்க';

  @override
  String get verifyFace => 'முகத்தை சரிபார்க்கவும்';

  @override
  String get retake => 'மீண்டும் எடுக்கவும்';

  @override
  String get grantPermission => 'அனுமதி வழங்குக';

  @override
  String get preparingBiometricScan => 'உயிர்மெட்ரிக் ஸ்கேன் தயாராகிறது...';

  @override
  String get encryptingFaceTemplate =>
      'முக வார்ப்புருவை குறியாக்கம் செய்கிறது...';

  @override
  String get matchingFacialBiometric =>
      'முக அடையாளத்தை Face++ உடன் பொருத்துகிறது...';

  @override
  String get storingEncryptedRecord =>
      'குறியாக்கம் செய்யப்பட்ட பதிவை சேமிக்கிறது...';

  @override
  String get authSuccessful => 'அங்கீகாரம் வெற்றிகரமாக முடிந்தது!';

  @override
  String get verificationFailed => 'சரிபார்ப்பு தோல்வியடைந்தது';

  @override
  String get tryAgain => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String remainingAttempts(int count) {
    return 'மீதமுள்ள முயற்சிகள்: $count';
  }

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navCommunity => 'சமூகம்';

  @override
  String get navSell => 'விற்பனை';

  @override
  String get navMarketplace => 'சந்தை';

  @override
  String get navProfile => 'சுயவிவரம்';

  @override
  String get homeGreeting => 'வணக்கம், விவசாயி';

  @override
  String get homeLocation => 'உங்கள் இருப்பிடத்தை அமைக்கவும்';

  @override
  String get homeWeatherTitle => 'இன்றைய வானிலை';

  @override
  String get homeServicesTitle => 'AI பயிர் பகுப்பாய்வு';

  @override
  String get homeSupportedCrops => 'ஆதரிக்கப்படும் பயிர்கள்';

  @override
  String get homeQuickServices => 'விரைவான சேவைகள்';

  @override
  String get qualityDetection => 'தரக் கண்டறிதல்';

  @override
  String get qualityDetectionDesc =>
      'புதிது மற்றும் பயிர் தரத்தை சரிபார்க்கவும்';

  @override
  String get diseaseDetection => 'நோய் கண்டறிதல்';

  @override
  String get diseaseDetectionDesc =>
      'பயிர் நோய்கள் மற்றும் தொற்றுக்களை அடையாளம் காணவும்';

  @override
  String get leafDiseaseDetection => 'Leaf Disease Detection';

  @override
  String get leafDiseaseDetectionDesc =>
      'Scan leaf photo for instant AI diagnosis, symptoms & remedies';

  @override
  String get cropMango => 'மாம்பழம்';

  @override
  String get cropBanana => 'வாழைப்பழம்';

  @override
  String get cropTomato => 'தக்காளி';

  @override
  String get cropPotato => 'உருளைக்கிழங்கு';

  @override
  String get serviceWeather => 'வானிலை';

  @override
  String get serviceMandiPrices => 'மண்டி விலை';

  @override
  String get serviceAIAssistant => 'AI உதவியாளர்';

  @override
  String get serviceLabour => 'வேலை தேடு';

  @override
  String get weatherLoading => 'வானிலை தரவு ஏற்றப்படுகிறது...';

  @override
  String get weatherUnavailable => 'வானிலை தரவு கிடைக்கவில்லை';

  @override
  String get weatherSetLocation =>
      'வானிலை நிலவரத்திற்கு உங்கள் இருப்பிடத்தை அமைக்கவும்';

  @override
  String get weatherRetry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get weatherAdvisory => 'விவசாய ஆலோசனை';

  @override
  String get myProfile => 'எனது சுயவிவரம்';

  @override
  String get myAiReports => 'எனது AI அறிக்கைகள்';

  @override
  String get myListings => 'எனது பட்டியல்கள்';

  @override
  String get savedProducts => 'சேமித்த பொருட்கள்';

  @override
  String get myConversations => 'எனது உரையாடல்கள்';

  @override
  String get language => 'மொழி';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get helpSupport => 'உதவி & ஆதரவு';

  @override
  String get comingSoon => 'விரைவில் வருகிறது';

  @override
  String get featureComingSoonDesc =>
      'இந்த அம்சம் உருவாக்கப்பட்டு விரைவில் கிடைக்கும்.';
}
