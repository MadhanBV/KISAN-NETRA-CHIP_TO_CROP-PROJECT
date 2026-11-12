/// Centralized copy strings for CHIP TO CROP.
/// Organised to easily allow translation or updates in the future.
class AppStrings {
  AppStrings._();

  static const String appName = 'CHIP TO CROP';

  // Navigation actions
  static const String skip = 'Skip';
  static const String next = 'Next';
  static const String getStarted = 'Get Started';

  // Onboarding Screen 1
  static const String onboarding1Title = 'Know Your Crop Health';
  static const String onboarding1Description =
      'Detect crop quality, diseases and infections with a simple scan.';

  // Onboarding Screen 2
  static const String onboarding2Title = 'Grow Together';
  static const String onboarding2Description =
      'Connect with farmers, share knowledge and buy or sell agricultural products.';

  // Onboarding Screen 3
  static const String onboarding3Title = 'Farm Smarter Every Day';
  static const String onboarding3Description =
      'Stay updated with live weather and get guidance for better farming decisions.';

  // Placeholder Screen
  static const String placeholderTitle = 'Welcome to CHIP TO CROP';
  static const String placeholderSubtitle =
      'Next module will be connected here.';

  // Bottom Navigation
  static const String navHome = 'Home';
  static const String navCommunity = 'Community';
  static const String navSell = 'Sell';
  static const String navMarketplace = 'Marketplace';
  static const String navProfile = 'Profile';

  // Home Screen
  static const String homeGreeting = 'Hello, Farmer';
  static const String homeLocation = 'Set your location';
  static const String homeWeatherTitle = 'Today\'s Weather';
  static const String homeServicesTitle = 'AI Crop Analysis';
  static const String homeSupportedCrops = 'Supported Crops';
  static const String homeQuickServices = 'Quick Services';

  // AI Services
  static const String leafDiseaseDetection = 'Leaf Disease Detection';
  static const String leafDiseaseDetectionDesc =
      'Scan leaf photo for instant AI diagnosis, symptoms & remedies';

  static const String qualityDetection = 'Quality Detection';
  static const String qualityDetectionDesc = 'Check freshness and crop quality';
  static const String diseaseDetection = 'Disease Detection';
  static const String diseaseDetectionDesc =
      'Identify crop diseases and infections';

  // Supported Crops
  static const String cropMango = 'Mango';
  static const String cropBanana = 'Banana';
  static const String cropTomato = 'Tomato';
  static const String cropPotato = 'Potato';

  // Quick Services
  static const String serviceWeather = 'Weather';
  static const String serviceMandiPrices = 'Mandi Prices';
  static const String serviceAIAssistant = 'AI Assistant';
  static const String serviceLabour = 'Find Labour';

  // Weather
  static const String weatherLoading = 'Loading weather data...';
  static const String weatherUnavailable = 'Weather data unavailable';
  static const String weatherSetLocation = 'Set your location for weather';
  static const String weatherRetry = 'Retry';
  static const String weatherAdvisory = 'Farming Advisory';

  // Feature placeholders
  static const String comingSoon = 'Coming Soon';
  static const String featureComingSoonDesc =
      'This feature is being developed and will be available soon.';

  // Mandi Prices & Markets
  static const String mandiPricesTitle = 'Mandi Prices';
  static const String mandiPricesSubtitle =
      'Live wholesale market prices from Government Mandis (Agmarknet)';
  static const String useMyLocation = 'Use Current Location';
  static const String changeLocation = 'Change Location';
  static const String selectState = 'Select State';
  static const String selectDistrict = 'Select District';
  static const String searchCommodity = 'Search commodity...';
  static const String modalPrice = 'Modal Price';
  static const String minPrice = 'Min';
  static const String maxPrice = 'Max';
  static const String perQuintal = '₹ / Quintal';
  static const String distanceAway = 'away';
  static const String distanceUnavailable = 'Distance unverified';
  static const String allInDistrict = 'All in District';
  static const String nearestMarket = 'Nearest';
  static const String highestPrice = 'Highest Price';
  static const String lowestPrice = 'Lowest Price';
  static const String latestDate = 'Latest Date';
  static const String wholesaleDisclaimer =
      'Reported wholesale market reference prices from Agmarknet. Actual transactions may vary by quality and lot size.';
  static const String noMandiFound =
      'No mandi prices found for the selected criteria. Try changing commodity, location, or expanding search radius.';
}
