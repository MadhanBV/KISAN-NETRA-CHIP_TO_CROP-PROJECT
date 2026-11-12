// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CHIP TO CROP';

  @override
  String get kisanNetra => 'Kisan Netra';

  @override
  String get chooseYourLanguage => 'Choose Your Language';

  @override
  String get selectPreferredLanguage => 'Select your preferred language';

  @override
  String get searchLanguage => 'Search language...';

  @override
  String get continueAction => 'Continue';

  @override
  String selectedLanguage(String language) {
    return 'Selected: $language';
  }

  @override
  String allLanguages(int count) {
    return 'All Languages ($count)';
  }

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboarding1Title => 'Know Your Crop Health';

  @override
  String get onboarding1Desc =>
      'Detect crop quality, diseases and infections with a simple scan.';

  @override
  String get onboarding2Title => 'Grow Together';

  @override
  String get onboarding2Desc =>
      'Connect with farmers, share knowledge and buy or sell agricultural products.';

  @override
  String get onboarding3Title => 'Farm Smarter Every Day';

  @override
  String get onboarding3Desc =>
      'Stay updated with live weather and get guidance for better farming decisions.';

  @override
  String get welcomeToKisanNetra => 'Welcome to Kisan Netra';

  @override
  String get authChoiceTagline =>
      'Your farm. Your identity. Your digital companion.';

  @override
  String get register => 'REGISTER';

  @override
  String get createNewAccount => 'Create a new farmer account';

  @override
  String get login => 'LOGIN';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get secureBiometricAuth => 'Secure biometric face authentication';

  @override
  String get farmerRegistration => 'FARMER REGISTRATION';

  @override
  String get enterMobileNumber => 'Enter your mobile number';

  @override
  String get registerMobileSubtitle =>
      'Your mobile number is your farmer account ID. Face authentication will protect your account.';

  @override
  String get continueWithFace => 'CONTINUE WITH FACE REGISTRATION';

  @override
  String get alreadyRegistered => 'Already registered? ';

  @override
  String get loginHere => 'Login here';

  @override
  String get enter10DigitMobile => 'Enter 10-digit mobile';

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
  String get confirmFaceForLogin => 'Confirm Face for Login';

  @override
  String get ensureFaceVisible => 'Ensure your face is clearly visible.';

  @override
  String get biometricConsentText =>
      'I consent to using my face scan for secure authentication.';

  @override
  String get confirmAndRegister => 'CONFIRM & REGISTER';

  @override
  String get verifyFace => 'VERIFY FACE';

  @override
  String get retake => 'Retake';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get preparingBiometricScan => 'Preparing biometric scan...';

  @override
  String get encryptingFaceTemplate => 'Encrypting face template...';

  @override
  String get matchingFacialBiometric =>
      'Matching facial biometric with Face++...';

  @override
  String get storingEncryptedRecord => 'Storing encrypted record...';

  @override
  String get authSuccessful => 'Authentication Successful!';

  @override
  String get verificationFailed => 'Verification Failed';

  @override
  String get tryAgain => 'Try Again';

  @override
  String remainingAttempts(int count) {
    return 'Remaining attempts: $count';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navCommunity => 'Community';

  @override
  String get navSell => 'Sell';

  @override
  String get navMarketplace => 'Marketplace';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeGreeting => 'Hello, Farmer';

  @override
  String get homeLocation => 'Set your location';

  @override
  String get homeWeatherTitle => 'Today\'s Weather';

  @override
  String get homeServicesTitle => 'AI Crop Analysis';

  @override
  String get homeSupportedCrops => 'Supported Crops';

  @override
  String get homeQuickServices => 'Quick Services';

  @override
  String get qualityDetection => 'Quality Detection';

  @override
  String get qualityDetectionDesc => 'Check freshness and crop quality';

  @override
  String get diseaseDetection => 'Disease Detection';

  @override
  String get diseaseDetectionDesc => 'Identify crop diseases and infections';

  @override
  String get leafDiseaseDetection => 'Leaf Disease Detection';

  @override
  String get leafDiseaseDetectionDesc =>
      'Scan leaf photo for instant AI diagnosis, symptoms & remedies';

  @override
  String get cropMango => 'Mango';

  @override
  String get cropBanana => 'Banana';

  @override
  String get cropTomato => 'Tomato';

  @override
  String get cropPotato => 'Potato';

  @override
  String get serviceWeather => 'Weather';

  @override
  String get serviceMandiPrices => 'Mandi Prices';

  @override
  String get serviceAIAssistant => 'AI Assistant';

  @override
  String get serviceLabour => 'Find Labour';

  @override
  String get weatherLoading => 'Loading weather data...';

  @override
  String get weatherUnavailable => 'Weather data unavailable';

  @override
  String get weatherSetLocation => 'Set your location for weather';

  @override
  String get weatherRetry => 'Retry';

  @override
  String get weatherAdvisory => 'Farming Advisory';

  @override
  String get myProfile => 'My Profile';

  @override
  String get myAiReports => 'My AI Reports';

  @override
  String get myListings => 'My Listings';

  @override
  String get savedProducts => 'Saved Products';

  @override
  String get myConversations => 'My Conversations';

  @override
  String get language => 'Language';

  @override
  String get settings => 'Settings';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get featureComingSoonDesc =>
      'This feature is being developed and will be available soon.';
}
