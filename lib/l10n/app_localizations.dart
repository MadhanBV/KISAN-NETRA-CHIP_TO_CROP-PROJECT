import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_as.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_brx.dart';
import 'app_localizations_doi.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_kok.dart';
import 'app_localizations_ks.dart';
import 'app_localizations_mai.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mni.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ne.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_sa.dart';
import 'app_localizations_sat.dart';
import 'app_localizations_sd.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('as'),
    Locale('bn'),
    Locale('brx'),
    Locale('doi'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('kok'),
    Locale('ks'),
    Locale('mai'),
    Locale('ml'),
    Locale('mni'),
    Locale('mr'),
    Locale('ne'),
    Locale('or'),
    Locale('pa'),
    Locale('sa'),
    Locale('sat'),
    Locale('sd'),
    Locale('ta'),
    Locale('te'),
    Locale('ur'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'CHIP TO CROP'**
  String get appName;

  /// Application brand name
  ///
  /// In en, this message translates to:
  /// **'Kisan Netra'**
  String get kisanNetra;

  /// Heading on language selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get chooseYourLanguage;

  /// Subtitle on language selection screen
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectPreferredLanguage;

  /// Search field hint on language selection screen
  ///
  /// In en, this message translates to:
  /// **'Search language...'**
  String get searchLanguage;

  /// Generic continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Selected language indicator
  ///
  /// In en, this message translates to:
  /// **'Selected: {language}'**
  String selectedLanguage(String language);

  /// Header for languages list
  ///
  /// In en, this message translates to:
  /// **'All Languages ({count})'**
  String allLanguages(int count);

  /// Skip onboarding action
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Next step action
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Complete onboarding action
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// First onboarding title
  ///
  /// In en, this message translates to:
  /// **'Know Your Crop Health'**
  String get onboarding1Title;

  /// First onboarding description
  ///
  /// In en, this message translates to:
  /// **'Detect crop quality, diseases and infections with a simple scan.'**
  String get onboarding1Desc;

  /// Second onboarding title
  ///
  /// In en, this message translates to:
  /// **'Grow Together'**
  String get onboarding2Title;

  /// Second onboarding description
  ///
  /// In en, this message translates to:
  /// **'Connect with farmers, share knowledge and buy or sell agricultural products.'**
  String get onboarding2Desc;

  /// Third onboarding title
  ///
  /// In en, this message translates to:
  /// **'Farm Smarter Every Day'**
  String get onboarding3Title;

  /// Third onboarding description
  ///
  /// In en, this message translates to:
  /// **'Stay updated with live weather and get guidance for better farming decisions.'**
  String get onboarding3Desc;

  /// Auth choice heading
  ///
  /// In en, this message translates to:
  /// **'Welcome to Kisan Netra'**
  String get welcomeToKisanNetra;

  /// Auth choice subtitle
  ///
  /// In en, this message translates to:
  /// **'Your farm. Your identity. Your digital companion.'**
  String get authChoiceTagline;

  /// Register button
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get register;

  /// Register button subtitle
  ///
  /// In en, this message translates to:
  /// **'Create a new farmer account'**
  String get createNewAccount;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// Login button subtitle
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// Auth choice footer
  ///
  /// In en, this message translates to:
  /// **'Secure biometric face authentication'**
  String get secureBiometricAuth;

  /// Registration badge
  ///
  /// In en, this message translates to:
  /// **'FARMER REGISTRATION'**
  String get farmerRegistration;

  /// Mobile number title
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number'**
  String get enterMobileNumber;

  /// Registration mobile subtitle
  ///
  /// In en, this message translates to:
  /// **'Your mobile number is your farmer account ID. Face authentication will protect your account.'**
  String get registerMobileSubtitle;

  /// Continue with face button
  ///
  /// In en, this message translates to:
  /// **'CONTINUE WITH FACE REGISTRATION'**
  String get continueWithFace;

  /// Already registered prompt
  ///
  /// In en, this message translates to:
  /// **'Already registered? '**
  String get alreadyRegistered;

  /// Login link
  ///
  /// In en, this message translates to:
  /// **'Login here'**
  String get loginHere;

  /// Phone input placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter 10-digit mobile'**
  String get enter10DigitMobile;

  /// Phone validation empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your mobile number'**
  String get errorEnterMobile;

  /// Phone validation invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number'**
  String get errorValidMobile;

  /// Login title
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Login mobile subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your registered mobile number to verify your identity with face scan.'**
  String get loginMobileSubtitle;

  /// Verify with face button
  ///
  /// In en, this message translates to:
  /// **'VERIFY WITH FACE'**
  String get verifyWithFace;

  /// New user prompt
  ///
  /// In en, this message translates to:
  /// **'New to Kisan Netra? '**
  String get newToKisanNetra;

  /// Register now link
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get registerNow;

  /// Face registration header
  ///
  /// In en, this message translates to:
  /// **'Face Registration'**
  String get faceRegistration;

  /// Face verification header
  ///
  /// In en, this message translates to:
  /// **'Face Verification'**
  String get faceVerification;

  /// Reticle guidance text
  ///
  /// In en, this message translates to:
  /// **'Position your face inside the green frame'**
  String get positionFaceInFrame;

  /// Post-capture status badge
  ///
  /// In en, this message translates to:
  /// **'Face Captured • AI Scanning Complete'**
  String get faceCapturedSuccess;

  /// Capture tip
  ///
  /// In en, this message translates to:
  /// **'Keep head straight & ensure even lighting'**
  String get keepHeadStraight;

  /// Permission denied title
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get cameraPermissionRequired;

  /// Permission denied explanation
  ///
  /// In en, this message translates to:
  /// **'Please enable camera access in your device settings to scan your face.'**
  String get cameraPermissionMessage;

  /// Review header register
  ///
  /// In en, this message translates to:
  /// **'Review Face Photograph'**
  String get reviewFacePhoto;

  /// Review header login
  ///
  /// In en, this message translates to:
  /// **'Confirm Face for Login'**
  String get confirmFaceForLogin;

  /// Review subtitle
  ///
  /// In en, this message translates to:
  /// **'Ensure your face is clearly visible.'**
  String get ensureFaceVisible;

  /// Consent statement
  ///
  /// In en, this message translates to:
  /// **'I consent to using my face scan for secure authentication.'**
  String get biometricConsentText;

  /// Confirm registration button
  ///
  /// In en, this message translates to:
  /// **'CONFIRM & REGISTER'**
  String get confirmAndRegister;

  /// Confirm login button
  ///
  /// In en, this message translates to:
  /// **'VERIFY FACE'**
  String get verifyFace;

  /// Retake button
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// Button to request permission
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// Dialog step preparing
  ///
  /// In en, this message translates to:
  /// **'Preparing biometric scan...'**
  String get preparingBiometricScan;

  /// Dialog step encrypting
  ///
  /// In en, this message translates to:
  /// **'Encrypting face template...'**
  String get encryptingFaceTemplate;

  /// Dialog step matching
  ///
  /// In en, this message translates to:
  /// **'Matching facial biometric with Face++...'**
  String get matchingFacialBiometric;

  /// Dialog step storing
  ///
  /// In en, this message translates to:
  /// **'Storing encrypted record...'**
  String get storingEncryptedRecord;

  /// Dialog step success
  ///
  /// In en, this message translates to:
  /// **'Authentication Successful!'**
  String get authSuccessful;

  /// Dialog step failure
  ///
  /// In en, this message translates to:
  /// **'Verification Failed'**
  String get verificationFailed;

  /// Dialog retry button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Remaining login attempts indicator
  ///
  /// In en, this message translates to:
  /// **'Remaining attempts: {count}'**
  String remainingAttempts(int count);

  /// Bottom nav home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav community
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// Bottom nav sell
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get navSell;

  /// Bottom nav marketplace
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get navMarketplace;

  /// Bottom nav profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Home greeting
  ///
  /// In en, this message translates to:
  /// **'Hello, Farmer'**
  String get homeGreeting;

  /// Home location placeholder
  ///
  /// In en, this message translates to:
  /// **'Set your location'**
  String get homeLocation;

  /// Home weather section
  ///
  /// In en, this message translates to:
  /// **'Today\'s Weather'**
  String get homeWeatherTitle;

  /// Home AI services section
  ///
  /// In en, this message translates to:
  /// **'AI Crop Analysis'**
  String get homeServicesTitle;

  /// Home supported crops section
  ///
  /// In en, this message translates to:
  /// **'Supported Crops'**
  String get homeSupportedCrops;

  /// Home quick services section
  ///
  /// In en, this message translates to:
  /// **'Quick Services'**
  String get homeQuickServices;

  /// Service quality title
  ///
  /// In en, this message translates to:
  /// **'Quality Detection'**
  String get qualityDetection;

  /// Service quality desc
  ///
  /// In en, this message translates to:
  /// **'Check freshness and crop quality'**
  String get qualityDetectionDesc;

  /// Service disease title
  ///
  /// In en, this message translates to:
  /// **'Disease Detection'**
  String get diseaseDetection;

  /// Service disease desc
  ///
  /// In en, this message translates to:
  /// **'Identify crop diseases and infections'**
  String get diseaseDetectionDesc;

  /// Leaf disease detection title
  ///
  /// In en, this message translates to:
  /// **'Leaf Disease Detection'**
  String get leafDiseaseDetection;

  /// Leaf disease detection desc
  ///
  /// In en, this message translates to:
  /// **'Scan leaf photo for instant AI diagnosis, symptoms & remedies'**
  String get leafDiseaseDetectionDesc;

  /// Crop mango
  ///
  /// In en, this message translates to:
  /// **'Mango'**
  String get cropMango;

  /// Crop banana
  ///
  /// In en, this message translates to:
  /// **'Banana'**
  String get cropBanana;

  /// Crop tomato
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get cropTomato;

  /// Crop potato
  ///
  /// In en, this message translates to:
  /// **'Potato'**
  String get cropPotato;

  /// Quick service weather
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get serviceWeather;

  /// Quick service mandi
  ///
  /// In en, this message translates to:
  /// **'Mandi Prices'**
  String get serviceMandiPrices;

  /// Quick service assistant
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get serviceAIAssistant;

  /// Quick service labour
  ///
  /// In en, this message translates to:
  /// **'Find Labour'**
  String get serviceLabour;

  /// Weather loading
  ///
  /// In en, this message translates to:
  /// **'Loading weather data...'**
  String get weatherLoading;

  /// Weather unavailable
  ///
  /// In en, this message translates to:
  /// **'Weather data unavailable'**
  String get weatherUnavailable;

  /// Weather set location prompt
  ///
  /// In en, this message translates to:
  /// **'Set your location for weather'**
  String get weatherSetLocation;

  /// Weather retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get weatherRetry;

  /// Weather advisory title
  ///
  /// In en, this message translates to:
  /// **'Farming Advisory'**
  String get weatherAdvisory;

  /// Profile menu item
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Profile menu item
  ///
  /// In en, this message translates to:
  /// **'My AI Reports'**
  String get myAiReports;

  /// Profile menu item
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// Profile menu item
  ///
  /// In en, this message translates to:
  /// **'Saved Products'**
  String get savedProducts;

  /// Profile menu item
  ///
  /// In en, this message translates to:
  /// **'My Conversations'**
  String get myConversations;

  /// Profile menu item language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Profile menu item settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Profile menu item help
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// Placeholder title
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Placeholder subtitle
  ///
  /// In en, this message translates to:
  /// **'This feature is being developed and will be available soon.'**
  String get featureComingSoonDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'as',
    'bn',
    'brx',
    'doi',
    'en',
    'gu',
    'hi',
    'kn',
    'kok',
    'ks',
    'mai',
    'ml',
    'mni',
    'mr',
    'ne',
    'or',
    'pa',
    'sa',
    'sat',
    'sd',
    'ta',
    'te',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'as':
      return AppLocalizationsAs();
    case 'bn':
      return AppLocalizationsBn();
    case 'brx':
      return AppLocalizationsBrx();
    case 'doi':
      return AppLocalizationsDoi();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'kok':
      return AppLocalizationsKok();
    case 'ks':
      return AppLocalizationsKs();
    case 'mai':
      return AppLocalizationsMai();
    case 'ml':
      return AppLocalizationsMl();
    case 'mni':
      return AppLocalizationsMni();
    case 'mr':
      return AppLocalizationsMr();
    case 'ne':
      return AppLocalizationsNe();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'sa':
      return AppLocalizationsSa();
    case 'sat':
      return AppLocalizationsSat();
    case 'sd':
      return AppLocalizationsSd();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
