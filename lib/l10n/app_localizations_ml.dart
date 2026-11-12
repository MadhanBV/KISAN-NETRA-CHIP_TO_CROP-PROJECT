// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appName => 'CHIP TO CROP';

  @override
  String get kisanNetra => 'കിസാൻ നേത്ര';

  @override
  String get chooseYourLanguage => 'നിങ്ങളുടെ ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get selectPreferredLanguage =>
      'നിങ്ങൾക്ക് ഇഷ്ടമുള്ള ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get searchLanguage => 'ഭാഷ തിരയുക...';

  @override
  String get continueAction => 'തുടരുക';

  @override
  String selectedLanguage(String language) {
    return 'തിരഞ്ഞെടുത്തത്: $language';
  }

  @override
  String allLanguages(int count) {
    return 'എല്ലാ ഭാഷകളും ($count)';
  }

  @override
  String get skip => 'ഒഴിവാക്കുക';

  @override
  String get next => 'അടുത്തത്';

  @override
  String get getStarted => 'തുടങ്ങുക';

  @override
  String get onboarding1Title => 'വിളകളുടെ ആരോഗ്യം അറിയുക';

  @override
  String get onboarding1Desc =>
      'ലളിതമായ സ്കാനിംഗിലൂടെ വിളകളുടെ ഗുണനിലവാരം, രോഗങ്ങൾ, അണുബാധകൾ എന്നിവ കണ്ടെത്തുക.';

  @override
  String get onboarding2Title => 'ഒന്നിച്ച് വളരുക';

  @override
  String get onboarding2Desc =>
      'കർഷകരുമായി ബന്ധം സ്ഥാപിക്കുക, അറിവ് പങ്കിടുക, കാർഷിക ഉൽപന്നങ്ങൾ വാങ്ങുക അല്ലെങ്കിൽ വിൽക്കുക.';

  @override
  String get onboarding3Title => 'ഓരോ ദിവസവും മികച്ച രീതിയിൽ കൃഷി ചെയ്യുക';

  @override
  String get onboarding3Desc =>
      'തത്സമയ കാലാവസ്ഥാ വിവരങ്ങൾ അറിയുകയും മികച്ച കൃഷി തീരുമാനങ്ങൾ എടുക്കുന്നതിന് ആവശ്യമായ മാർഗ്ഗനിർദ്ദേശങ്ങൾ നേടുകയും ചെയ്യുക.';

  @override
  String get welcomeToKisanNetra => 'കിസാൻ നേത്രയിലേക്ക് സ്വാഗതം';

  @override
  String get authChoiceTagline =>
      'നിങ്ങളുടെ കൃഷിയിടം. നിങ്ങളുടെ വ്യക്തിത്വം. നിങ്ങളുടെ ഡിജിറ്റൽ കൂട്ടുകാരി.';

  @override
  String get register => 'രജിസ്റ്റർ ചെയ്യുക';

  @override
  String get createNewAccount => 'ഒരു പുതിയ കർഷക അക്കൗണ്ട് ഉണ്ടാക്കുക';

  @override
  String get login => 'ലോഗിൻ ചെയ്യുക';

  @override
  String get alreadyHaveAccount =>
      'നിങ്ങൾക്ക് ഇതിനകം അക്കൗണ്ട് ഉണ്ടോ? സൈൻ ഇൻ ചെയ്യുക';

  @override
  String get secureBiometricAuth => 'സുരക്ഷിതമായ ബയോമെട്രിക് മുഖം തിരിച്ചറിയൽ';

  @override
  String get farmerRegistration => 'കർഷക രജിസ്ട്രേഷൻ';

  @override
  String get enterMobileNumber => 'നിങ്ങളുടെ മൊബൈൽ നമ്പർ നൽകുക';

  @override
  String get registerMobileSubtitle =>
      'നിങ്ങളുടെ മൊബൈൽ നമ്പർ നിങ്ങളുടെ കർഷക അക്കൗണ്ട് ഐഡിയാണ്. മുഖം തിരിച്ചറിയൽ നിങ്ങളുടെ അക്കൗണ്ടിനെ സംരക്ഷിക്കും.';

  @override
  String get continueWithFace => 'മുഖം തിരിച്ചറിയൽ തുടർന്ന് ചെയ്യുക';

  @override
  String get alreadyRegistered => 'മുൻപേ രജിസ്റ്റർ ചെയ്തതാണോ?';

  @override
  String get loginHere => 'ഇവിടെ ലോഗിൻ ചെയ്യുക';

  @override
  String get enter10DigitMobile => '10 അക്ക മൊബൈൽ നമ്പർ നൽകുക';

  @override
  String get errorEnterMobile => 'നിങ്ങളുടെ മൊബൈൽ നമ്പർ നൽകുക';

  @override
  String get errorValidMobile => 'സാധുവായ 10 അക്ക മൊബൈൽ നമ്പർ നൽകുക';

  @override
  String get welcomeBack => 'വീണ്ടും സ്വാഗതം';

  @override
  String get loginMobileSubtitle =>
      'നിങ്ങളുടെ മുഖം സ്കാൻ ഉപയോഗിച്ച് തിരിച്ചറിയാൻ രജിസ്റ്റർ ചെയ്ത മൊബൈൽ നമ്പർ നൽകുക.';

  @override
  String get verifyWithFace => 'മുഖം ഉപയോഗിച്ച് സ്ഥിരീകരിക്കുക';

  @override
  String get newToKisanNetra => 'കിസാൻ നേത്രയിലേക്ക് പുതിയതായി വന്നതാണോ?';

  @override
  String get registerNow => 'ഇപ്പോൾ രജിസ്റ്റർ ചെയ്യുക';

  @override
  String get faceRegistration => 'മുഖം രജിസ്ട്രേഷൻ';

  @override
  String get faceVerification => 'മുഖം സ്ഥിരീകരണം';

  @override
  String get positionFaceInFrame =>
      'നിങ്ങളുടെ മുഖം പച്ച ഫ്രെയിമിനുള്ളിൽ വയ്ക്കുക';

  @override
  String get faceCapturedSuccess => 'മുഖം പകർത്തി • AI സ്കാനിംഗ് പൂർത്തിയായി';

  @override
  String get keepHeadStraight =>
      'തല നേരെയാക്കി വെക്കുകയും വെളിച്ചം ഒരുപോലെ ലഭിക്കുന്നുണ്ടെന്ന് ഉറപ്പാക്കുകയും ചെയ്യുക';

  @override
  String get cameraPermissionRequired => 'ക്യാമറ അനുമതി ആവശ്യമാണ്';

  @override
  String get cameraPermissionMessage =>
      'നിങ്ങളുടെ മുഖം സ്കാൻ ചെയ്യാൻ നിങ്ങളുടെ ഉപകരണത്തിന്റെ ക്രമീകരണങ്ങളിൽ ക്യാമറ ആക്സസ് പ്രവർത്തനക്ഷമമാക്കുക.';

  @override
  String get reviewFacePhoto => 'മുഖത്തിന്റെ ഫോട്ടോ അവലോകനം ചെയ്യുക';

  @override
  String get confirmFaceForLogin => 'ലോഗിൻ ചെയ്യുന്നതിന് മുഖം സ്ഥിരീകരിക്കുക';

  @override
  String get ensureFaceVisible =>
      'നിങ്ങളുടെ മുഖം വ്യക്തമായി കാണുന്നുണ്ടെന്ന് ഉറപ്പാക്കുക.';

  @override
  String get biometricConsentText =>
      'സുരക്ഷിതമായ പ്രാമാണീകരണത്തിനായി എന്റെ മുഖം സ്കാൻ ഉപയോഗിക്കാൻ ഞാൻ സമ്മതിക്കുന്നു.';

  @override
  String get confirmAndRegister => 'സ്ഥിരീകരിക്കുക & രജിസ്റ്റർ ചെയ്യുക';

  @override
  String get verifyFace => 'മുഖം പരിശോധിക്കുക';

  @override
  String get retake => 'വീണ്ടും എടുക്കുക';

  @override
  String get grantPermission => 'അനുമതി നൽകുക';

  @override
  String get preparingBiometricScan => 'ബയോമെട്രിക് സ്കാൻ തയ്യാറാക്കുന്നു...';

  @override
  String get encryptingFaceTemplate => 'മുഖം എൻക്രിപ്റ്റ് ചെയ്യുന്നു...';

  @override
  String get matchingFacialBiometric =>
      'ഫേസ്++ ഉപയോഗിച്ച് മുഖം ബയോമെട്രിക് പൊരുത്തപ്പെടുത്തുന്നു...';

  @override
  String get storingEncryptedRecord =>
      'എൻക്രിപ്റ്റ് ചെയ്ത രേഖ സംഭരിക്കുന്നു...';

  @override
  String get authSuccessful => 'പ്രമാണീകരണം വിജയകരമായി പൂർത്തിയായി!';

  @override
  String get verificationFailed => 'പരിശോധന പരാജയപ്പെട്ടു';

  @override
  String get tryAgain => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String remainingAttempts(int count) {
    return 'ബാക്കിയുള്ള ശ്രമങ്ങൾ: $count';
  }

  @override
  String get navHome => 'ഹോം';

  @override
  String get navCommunity => 'കമ്മ്യൂണിറ്റി';

  @override
  String get navSell => 'വിൽക്കുക';

  @override
  String get navMarketplace => 'മാർക്കറ്റ്പ്ലേസ്';

  @override
  String get navProfile => 'പ്രൊഫൈൽ';

  @override
  String get homeGreeting => 'ഹലോ, കർഷക';

  @override
  String get homeLocation => 'നിങ്ങളുടെ സ്ഥാനം സജ്ജമാക്കുക';

  @override
  String get homeWeatherTitle => 'ഇന്നത്തെ കാലാവസ്ഥ';

  @override
  String get homeServicesTitle => 'AI വിള വിശകലനം';

  @override
  String get homeSupportedCrops => 'പിന്തുണയ്ക്കുന്ന വിളകൾ';

  @override
  String get homeQuickServices => 'ദ്രുത സേവനങ്ങൾ';

  @override
  String get qualityDetection => 'ഗുണനിലവാര കണ്ടെത്തൽ';

  @override
  String get qualityDetectionDesc =>
      'പുതുമയും വിളയുടെ ഗുണനിലവാരവും പരിശോധിക്കുക';

  @override
  String get diseaseDetection => 'രോഗ നിർണയം';

  @override
  String get diseaseDetectionDesc => 'വിള രോഗങ്ങളും അണുബാധകളും തിരിച്ചറിയുക';

  @override
  String get leafDiseaseDetection => 'Leaf Disease Detection';

  @override
  String get leafDiseaseDetectionDesc =>
      'Scan leaf photo for instant AI diagnosis, symptoms & remedies';

  @override
  String get cropMango => 'മാങ്ങ';

  @override
  String get cropBanana => 'വാഴപ്പഴം';

  @override
  String get cropTomato => 'തക്കാളി';

  @override
  String get cropPotato => 'ഉരുളക്കിഴങ്ങ്';

  @override
  String get serviceWeather => 'കാലാവസ്ഥ';

  @override
  String get serviceMandiPrices => 'മണ്ഡി വിലകൾ';

  @override
  String get serviceAIAssistant => 'AI അസിസ്റ്റന്റ്';

  @override
  String get serviceLabour => 'തൊഴിലാളിയെ കണ്ടെത്തുക';

  @override
  String get weatherLoading => 'കാലാവസ്ഥാ ഡാറ്റ ലോഡ് ചെയ്യുന്നു...';

  @override
  String get weatherUnavailable => 'കാലാവസ്ഥാ ഡാറ്റ ലഭ്യമല്ല';

  @override
  String get weatherSetLocation =>
      'കാലാവസ്ഥയ്ക്കായി നിങ്ങളുടെ ലൊക്കേഷൻ സജ്ജമാക്കുക';

  @override
  String get weatherRetry => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get weatherAdvisory => 'കൃഷി ഉപദേശം';

  @override
  String get myProfile => 'എൻ്റെ പ്രൊഫൈൽ';

  @override
  String get myAiReports => 'എൻ്റെ AI റിപ്പോർട്ടുകൾ';

  @override
  String get myListings => 'എൻ്റെ ലിസ്റ്റിംഗുകൾ';

  @override
  String get savedProducts => 'സേവ് ചെയ്ത ഉൽപ്പന്നങ്ങൾ';

  @override
  String get myConversations => 'എൻ്റെ സംഭാഷണങ്ങൾ';

  @override
  String get language => 'ഭാഷ';

  @override
  String get settings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get helpSupport => 'സഹായവും പിന്തുണയും';

  @override
  String get comingSoon => 'ഉടൻ വരുന്നു';

  @override
  String get featureComingSoonDesc =>
      'ഈ ഫീച്ചർ വികസിപ്പിച്ചുകൊണ്ടിരിക്കുകയാണ്, ഉടൻ ലഭ്യമാകും.';
}
