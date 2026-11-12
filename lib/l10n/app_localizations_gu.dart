// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appName => 'CHIP TO CROP';

  @override
  String get kisanNetra => 'કિસાન નેત્ર';

  @override
  String get chooseYourLanguage => 'તમારી ભાષા પસંદ કરો';

  @override
  String get selectPreferredLanguage => 'તમારી મનપસંદ ભાષા પસંદ કરો';

  @override
  String get searchLanguage => 'ભાષા શોધો...';

  @override
  String get continueAction => 'ચાલુ રાખો';

  @override
  String selectedLanguage(String language) {
    return 'પસંદ કરેલ: $language';
  }

  @override
  String allLanguages(int count) {
    return 'બધી ભાષાઓ ($count)';
  }

  @override
  String get skip => 'છોડો';

  @override
  String get next => 'આગળ';

  @override
  String get getStarted => 'શરૂ કરો';

  @override
  String get onboarding1Title => 'તમારા પાકની તંદુરસ્તી જાણો';

  @override
  String get onboarding1Desc =>
      'સરળ સ્કેનથી પાકની ગુણવત્તા, રોગો અને ચેપ શોધો.';

  @override
  String get onboarding2Title => 'સાથે મળીને ઉગાડો';

  @override
  String get onboarding2Desc =>
      'ખેડૂતો સાથે જોડાઓ, જ્ઞાન શેર કરો અને કૃષિ ઉત્પાદનો ખરીદો અથવા વેચો.';

  @override
  String get onboarding3Title => 'દરરોજ વધુ સ્માર્ટ રીતે ખેતી કરો';

  @override
  String get onboarding3Desc =>
      'લાઇવ હવામાન સાથે અપડેટ રહો અને વધુ સારા ખેતીના નિર્ણયો માટે માર્ગદર્શન મેળવો.';

  @override
  String get welcomeToKisanNetra => 'કિસાન નેત્રમાં આપનું સ્વાગત છે.';

  @override
  String get authChoiceTagline => 'તમારું ખેતર. તમારી ઓળખ. તમારી ડિજિટલ સાથી.';

  @override
  String get register => 'નોંધણી કરાવો';

  @override
  String get createNewAccount => 'નવું ખેડૂત ખાતું બનાવો';

  @override
  String get login => 'લોગિન કરો';

  @override
  String get alreadyHaveAccount => 'પહેલેથી જ ખાતું છે? સાઇન ઇન કરો';

  @override
  String get secureBiometricAuth => 'સુરક્ષિત બાયોમેટ્રિક ચહેરાનું પ્રમાણીકરણ';

  @override
  String get farmerRegistration => 'ખેડૂત નોંધણી';

  @override
  String get enterMobileNumber => 'તમારો મોબાઇલ નંબર દાખલ કરો';

  @override
  String get registerMobileSubtitle =>
      'તમારો મોબાઇલ નંબર એ તમારું ખેડૂત ખાતું ID છે. ચહેરાનું પ્રમાણીકરણ તમારા ખાતાને સુરક્ષિત કરશે.';

  @override
  String get continueWithFace => 'ચહેરાની નોંધણી સાથે ચાલુ રાખો';

  @override
  String get alreadyRegistered => 'પહેલેથી જ નોંધણી કરાવી છે?';

  @override
  String get loginHere => 'અહીં લોગિન કરો';

  @override
  String get enter10DigitMobile => '10-અંકનો મોબાઇલ દાખલ કરો';

  @override
  String get errorEnterMobile => 'કૃપા કરીને તમારો મોબાઇલ નંબર દાખલ કરો.';

  @override
  String get errorValidMobile =>
      'કૃપા કરીને માન્ય 10-અંકનો મોબાઇલ નંબર દાખલ કરો.';

  @override
  String get welcomeBack => 'ફરીથી સ્વાગત છે.';

  @override
  String get loginMobileSubtitle =>
      'ફેસ સ્કેનથી તમારી ઓળખ ચકાસવા માટે તમારો નોંધાયેલ મોબાઇલ નંબર દાખલ કરો.';

  @override
  String get verifyWithFace => 'ફેસથી ચકાસો';

  @override
  String get newToKisanNetra => 'કિસાન નેત્રમાં નવા છો?';

  @override
  String get registerNow => 'હમણાં જ નોંધણી કરો';

  @override
  String get faceRegistration => 'ફેસ રજિસ્ટ્રેશન';

  @override
  String get faceVerification => 'ફેસ વેરિફિકેશન';

  @override
  String get positionFaceInFrame => 'લીલા ફ્રેમની અંદર તમારો ચહેરો રાખો';

  @override
  String get faceCapturedSuccess => 'ચહેરો કેપ્ચર થયો • AI સ્કેનિંગ પૂર્ણ થયું';

  @override
  String get keepHeadStraight => 'માથું સીધું રાખો અને સમાન પ્રકાશની ખાતરી કરો';

  @override
  String get cameraPermissionRequired => 'કેમેરા પરવાનગી જરૂરી છે';

  @override
  String get cameraPermissionMessage =>
      'તમારા ચહેરાને સ્કેન કરવા માટે કૃપા કરીને તમારા ઉપકરણ સેટિંગ્સમાં કેમેરા ઍક્સેસને સક્ષમ કરો.';

  @override
  String get reviewFacePhoto => 'ચહેરાના ફોટોગ્રાફની સમીક્ષા કરો';

  @override
  String get confirmFaceForLogin =>
      'ચોક્કસ કરો કે લૉગિન માટે તમારો ચહેરો દેખાય છે.';

  @override
  String get ensureFaceVisible =>
      'ખાતરી કરો કે તમારો ચહેરો સ્પષ્ટ રીતે દેખાય છે.';

  @override
  String get biometricConsentText =>
      'હું સુરક્ષિત પ્રમાણીકરણ માટે મારા ચહેરાના સ્કેનનો ઉપયોગ કરવા માટે સંમત છું.';

  @override
  String get confirmAndRegister => 'ચોક્કસ કરો અને નોંધણી કરો';

  @override
  String get verifyFace => 'ચહેરો ચકાસો';

  @override
  String get retake => 'ફરીથી લોક કરો';

  @override
  String get grantPermission => 'પરવાનગી આપો';

  @override
  String get preparingBiometricScan =>
      'બાયોમેટ્રિક સ્કેન તૈયાર થઈ રહ્યું છે...';

  @override
  String get encryptingFaceTemplate =>
      'ચહેરાના ટેમ્પલેટને એન્ક્રિપ્ટ કરી રહ્યા છીએ...';

  @override
  String get matchingFacialBiometric =>
      'ચહેરાના બાયોમેટ્રિકને ફેસ++ સાથે મેચ કરી રહ્યા છીએ...';

  @override
  String get storingEncryptedRecord =>
      'એન્ક્રિપ્ટેડ રેકોર્ડ સ્ટોર કરી રહ્યા છીએ...';

  @override
  String get authSuccessful => 'પ્રમાણીકરણ સફળ થયું!';

  @override
  String get verificationFailed => 'ચકાસણી નિષ્ફળ ગઈ';

  @override
  String get tryAgain => 'ફરી પ્રયાસ કરો';

  @override
  String remainingAttempts(int count) {
    return 'બાકી પ્રયત્નો: $count';
  }

  @override
  String get navHome => 'હોમ';

  @override
  String get navCommunity => 'સમુદાય';

  @override
  String get navSell => 'વેચો';

  @override
  String get navMarketplace => 'માર્કેટપ્લેસ';

  @override
  String get navProfile => 'પ્રોફાઇલ';

  @override
  String get homeGreeting => 'નમસ્તે, ખેડૂત';

  @override
  String get homeLocation => 'તમારું સ્થાન સેટ કરો';

  @override
  String get homeWeatherTitle => 'આજનો હવામાન';

  @override
  String get homeServicesTitle => 'AI પાક વિશ્લેષણ';

  @override
  String get homeSupportedCrops => 'સપોર્ટેડ પાક';

  @override
  String get homeQuickServices => 'ઝડપી સેવાઓ';

  @override
  String get qualityDetection => 'ગુણવત્તા શોધ';

  @override
  String get qualityDetectionDesc => 'તાજગી અને પાકની ગુણવત્તા તપાસો';

  @override
  String get diseaseDetection => 'રોગ શોધ';

  @override
  String get diseaseDetectionDesc => 'પાકના રોગો અને ચેપને ઓળખો';

  @override
  String get leafDiseaseDetection => 'Leaf Disease Detection';

  @override
  String get leafDiseaseDetectionDesc =>
      'Scan leaf photo for instant AI diagnosis, symptoms & remedies';

  @override
  String get cropMango => 'કેરી';

  @override
  String get cropBanana => 'કેળા';

  @override
  String get cropTomato => 'ટામેટાં';

  @override
  String get cropPotato => 'બટાટા';

  @override
  String get serviceWeather => 'હવામાન';

  @override
  String get serviceMandiPrices => 'મંડી ભાવ';

  @override
  String get serviceAIAssistant => 'AI સહાયક';

  @override
  String get serviceLabour => 'મજૂર શોધો';

  @override
  String get weatherLoading => 'હવામાન ડેટા લોડ થઈ રહ્યો છે...';

  @override
  String get weatherUnavailable => 'હવામાન ડેટા ઉપલબ્ધ નથી';

  @override
  String get weatherSetLocation => 'હવામાન માટે તમારું સ્થાન સેટ કરો';

  @override
  String get weatherRetry => 'ફરી પ્રયાસ કરો';

  @override
  String get weatherAdvisory => 'ખેતી સલાહ';

  @override
  String get myProfile => 'મારી પ્રોફાઇલ';

  @override
  String get myAiReports => 'મારા AI અહેવાલો';

  @override
  String get myListings => 'મારી યાદીઓ';

  @override
  String get savedProducts => 'સાચવેલ ઉત્પાદનો';

  @override
  String get myConversations => 'મારી વાતચીતો';

  @override
  String get language => 'ભાષા';

  @override
  String get settings => 'સેટિંગ્સ';

  @override
  String get helpSupport => 'મદદ અને સહાય';

  @override
  String get comingSoon => 'ટૂંક સમયમાં આવી રહ્યું છે';

  @override
  String get featureComingSoonDesc =>
      'આ સુવિધા વિકસાવવામાં આવી રહી છે અને ટૂંક સમયમાં ઉપલબ્ધ થશે.';
}
