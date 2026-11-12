// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'CHIP TO CROP';

  @override
  String get kisanNetra => 'কৃষক নেত্রা';

  @override
  String get chooseYourLanguage => 'আপনার ভাষা নির্বাচন করুন';

  @override
  String get selectPreferredLanguage => 'আপনার পছন্দের ভাষা নির্বাচন করুন';

  @override
  String get searchLanguage => 'ভাষা খুঁজুন...';

  @override
  String get continueAction => 'চালু রাখুন';

  @override
  String selectedLanguage(String language) {
    return 'নির্বাচিত: $language';
  }

  @override
  String allLanguages(int count) {
    return 'সমস্ত ভাষা ($count)';
  }

  @override
  String get skip => 'বাদ দিন';

  @override
  String get next => 'পরবর্তী';

  @override
  String get getStarted => 'শুরু করুন';

  @override
  String get onboarding1Title => 'আপনার ফসলের স্বাস্থ্য জানুন';

  @override
  String get onboarding1Desc =>
      'একটি সাধারণ স্ক্যানের মাধ্যমে ফসলের গুণমান, রোগ এবং সংক্রমণ সনাক্ত করুন।';

  @override
  String get onboarding2Title => 'একসাথে বেড়ে উঠুন';

  @override
  String get onboarding2Desc =>
      'কৃষকদের সাথে সংযোগ স্থাপন করুন, জ্ঞান ভাগ করুন এবং কৃষি পণ্য কিনুন বা বিক্রি করুন।';

  @override
  String get onboarding3Title => 'প্রতিদিন আরও ভালোভাবে খামার করুন';

  @override
  String get onboarding3Desc =>
      'সরাসরি আবহাওয়ার খবর জেনে কৃষিকাজের আরও ভালো সিদ্ধান্ত নেওয়ার জন্য নির্দেশনা পান।';

  @override
  String get welcomeToKisanNetra => 'কৃষক নেত্র-এ স্বাগতম।';

  @override
  String get authChoiceTagline =>
      'আপনার খামার। আপনার পরিচয়। আপনার ডিজিটাল সঙ্গী।';

  @override
  String get register => 'নিবন্ধন করুন';

  @override
  String get createNewAccount => 'নতুন কৃষক অ্যাকাউন্ট তৈরি করুন';

  @override
  String get login => 'লগইন করুন';

  @override
  String get alreadyHaveAccount => 'ইতিমধ্যে অ্যাকাউন্ট আছে? সাইন ইন করুন';

  @override
  String get secureBiometricAuth => 'সুরক্ষিত বায়োমেট্রিক ফেস অথেন্টিকেশন';

  @override
  String get farmerRegistration => 'কৃষক নিবন্ধন';

  @override
  String get enterMobileNumber => 'আপনার মোবাইল নম্বর লিখুন';

  @override
  String get registerMobileSubtitle =>
      'আপনার মোবাইল নম্বর আপনার কৃষক অ্যাকাউন্ট আইডি। ফেস অথেন্টিকেশন আপনার অ্যাকাউন্ট সুরক্ষিত করবে।';

  @override
  String get continueWithFace => 'ফেস রেজিস্ট্রেশন দিয়ে শুরু করুন';

  @override
  String get alreadyRegistered => 'ইতিমধ্যে নিবন্ধিত?';

  @override
  String get loginHere => 'এখানে লগইন করুন';

  @override
  String get enter10DigitMobile => '10-সংখ্যার মোবাইল নম্বর লিখুন';

  @override
  String get errorEnterMobile =>
      'অনুগ্রহ করে আপনার মোবাইল নম্বরটি প্রবেশ করুন।';

  @override
  String get errorValidMobile =>
      'অনুগ্রহ করে একটি বৈধ 10-সংখ্যার মোবাইল নম্বর প্রবেশ করুন।';

  @override
  String get welcomeBack => 'স্বাগতম';

  @override
  String get loginMobileSubtitle =>
      'ফেস স্ক্যানের মাধ্যমে আপনার পরিচয় যাচাই করতে আপনার নিবন্ধিত মোবাইল নম্বরটি প্রবেশ করুন।';

  @override
  String get verifyWithFace => 'ফেস দিয়ে যাচাই করুন';

  @override
  String get newToKisanNetra => 'কিষাণ নেত্রে নতুন?';

  @override
  String get registerNow => 'এখনই নিবন্ধন করুন';

  @override
  String get faceRegistration => 'ফেস রেজিস্ট্রেশন';

  @override
  String get faceVerification => 'ফেস ভেরিফিকেশন';

  @override
  String get positionFaceInFrame => 'সবুজ ফ্রেমে আপনার মুখ রাখুন';

  @override
  String get faceCapturedSuccess => 'মুখ ধরা হয়েছে • এআই স্ক্যানিং সম্পন্ন';

  @override
  String get keepHeadStraight =>
      'মাথা সোজা রাখুন এবং পর্যাপ্ত আলো নিশ্চিত করুন';

  @override
  String get cameraPermissionRequired => 'ক্যামেরার অনুমতির প্রয়োজন';

  @override
  String get cameraPermissionMessage =>
      'আপনার মুখ স্ক্যান করার জন্য আপনার ডিভাইসের সেটিংসে ক্যামেরা অ্যাক্সেস সক্ষম করুন।';

  @override
  String get reviewFacePhoto => 'ফেস ফটোগ্রাফ পর্যালোচনা করুন';

  @override
  String get confirmFaceForLogin => 'লগইনের জন্য মুখ নিশ্চিত করুন';

  @override
  String get ensureFaceVisible =>
      'নিশ্চিত করুন আপনার মুখ স্পষ্টভাবে দেখা যাচ্ছে।';

  @override
  String get biometricConsentText =>
      'আমি সুরক্ষিত প্রমাণীকরণের জন্য আমার মুখের স্ক্যান ব্যবহার করতে সম্মতি দিচ্ছি।';

  @override
  String get confirmAndRegister => 'নিশ্চিত করুন ও নিবন্ধন করুন';

  @override
  String get verifyFace => 'মুখ যাচাই করুন';

  @override
  String get retake => 'পুনরায় তুলুন';

  @override
  String get grantPermission => 'অনুমতি দিন';

  @override
  String get preparingBiometricScan =>
      'বায়োমেট্রিক স্ক্যান প্রস্তুত করা হচ্ছে...';

  @override
  String get encryptingFaceTemplate => 'মুখের টেমপ্লেট এনক্রিপ্ট করা হচ্ছে...';

  @override
  String get matchingFacialBiometric =>
      'ফেস++ এর সাথে মুখের বায়োমেট্রিক মেলানো হচ্ছে...';

  @override
  String get storingEncryptedRecord =>
      'এনক্রিপ্টেড রেকর্ড সংরক্ষণ করা হচ্ছে...';

  @override
  String get authSuccessful => 'প্রমাণীকরণ সফল!';

  @override
  String get verificationFailed => 'যাচাইকরণ ব্যর্থ';

  @override
  String get tryAgain => 'পুনরায় চেষ্টা করুন';

  @override
  String remainingAttempts(int count) {
    return 'অবশিষ্ট প্রচেষ্টা: $count';
  }

  @override
  String get navHome => 'হোম';

  @override
  String get navCommunity => 'কমিউনিটি';

  @override
  String get navSell => 'বিক্রি';

  @override
  String get navMarketplace => 'মার্কেটপ্লেস';

  @override
  String get navProfile => 'প্রোফাইল';

  @override
  String get homeGreeting => 'হ্যালো, কৃষক';

  @override
  String get homeLocation => 'আপনার অবস্থান সেট করুন';

  @override
  String get homeWeatherTitle => 'আজকের আবহাওয়া';

  @override
  String get homeServicesTitle => 'এআই শস্য বিশ্লেষণ';

  @override
  String get homeSupportedCrops => 'সমর্থিত শস্য';

  @override
  String get homeQuickServices => 'দ্রুত পরিষেবা';

  @override
  String get qualityDetection => 'গুণমান সনাক্তকরণ';

  @override
  String get qualityDetectionDesc => 'তাজা এবং শস্যের গুণমান পরীক্ষা করুন';

  @override
  String get diseaseDetection => 'রোগ সনাক্তকরণ';

  @override
  String get diseaseDetectionDesc => 'ফসল রোগ এবং সংক্রমণ সনাক্ত করুন';

  @override
  String get leafDiseaseDetection => 'Leaf Disease Detection';

  @override
  String get leafDiseaseDetectionDesc =>
      'Scan leaf photo for instant AI diagnosis, symptoms & remedies';

  @override
  String get cropMango => 'আম';

  @override
  String get cropBanana => 'কলা';

  @override
  String get cropTomato => 'টমেটো';

  @override
  String get cropPotato => 'আলু';

  @override
  String get serviceWeather => 'আবহাওয়া';

  @override
  String get serviceMandiPrices => 'মান্ডির দাম';

  @override
  String get serviceAIAssistant => 'এআই সহকারী';

  @override
  String get serviceLabour => 'শ্রমিক খুঁজুন';

  @override
  String get weatherLoading => 'আবহাওয়া ডেটা লোড হচ্ছে...';

  @override
  String get weatherUnavailable => 'আবহাওয়া ডেটা পাওয়া যাচ্ছে না';

  @override
  String get weatherSetLocation => 'আবহাওয়া জানার জন্য আপনার লোকেশন সেট করুন';

  @override
  String get weatherRetry => 'পুনরায় চেষ্টা করুন';

  @override
  String get weatherAdvisory => 'কৃষি বিষয়ক পরামর্শ';

  @override
  String get myProfile => 'আমার প্রোফাইল';

  @override
  String get myAiReports => 'আমার এআই রিপোর্ট';

  @override
  String get myListings => 'আমার তালিকা';

  @override
  String get savedProducts => 'সংরক্ষিত পণ্য';

  @override
  String get myConversations => 'আমার কথোপকথন';

  @override
  String get language => 'ভাষা';

  @override
  String get settings => 'সেটিংস';

  @override
  String get helpSupport => 'সাহায্য ও সমর্থন';

  @override
  String get comingSoon => 'শীঘ্রই আসছে';

  @override
  String get featureComingSoonDesc =>
      'এই বৈশিষ্ট্যটি তৈরি করা হচ্ছে এবং শীঘ্রই উপলব্ধ হবে।';
}
