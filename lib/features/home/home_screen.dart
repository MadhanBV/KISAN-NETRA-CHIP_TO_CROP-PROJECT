import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/feature_placeholder_screen.dart';
import '../../shared/widgets/section_header.dart';
import '../mandi/screens/mandi_prices_screen.dart';
import '../crop_disease/screens/leaf_disease_scan_screen.dart';
import '../crop_disease/screens/crop_quality_scan_screen.dart';
import '../crop_disease/screens/crop_disease_scan_screen.dart';
import '../ai_assistant/screens/ai_assistant_screen.dart';
import '../ai_assistant/services/voice_service.dart';
import '../mandi/services/location_service.dart';
import '../weather/models/weather_data.dart';
import '../weather/screens/weather_detail_screen.dart';
import '../weather/services/weather_api_service.dart';
import 'widgets/ai_service_card.dart';
import 'widgets/crop_tile.dart';
import 'widgets/home_header.dart';
import 'widgets/leaf_disease_card.dart';
import 'widgets/quick_service_button.dart';
import 'widgets/weather_card.dart';

/// Clean, production-grade Main Home Screen of CHIP TO CROP (Kisan Netra).
/// Implements the exact UI/UX design from the reference application:
/// 1. Top Header: User avatar, "Hello", bold name, location, and "AI Bot" pill.
/// 2. Hero Weather & Spraying Advisory Card: Overcast clouds graphic, temperature,
///    rain advisory, speaker icon, and dual spraying condition pills.
/// 3. Flagship AI Analysis Cards: Disease Detection & Quality Detection with
///    organic illustrations in the bottom-right corners.
/// 4. Supported Crops: Circular icon buttons.
/// 5. Quick Services: Clean circular action icons.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherApiService _weatherService = WeatherApiService();
  final VoiceService _voiceService = VoiceService();
  AgriculturalWeather? _weather;
  bool _isLoadingWeather = false;

  @override
  void initState() {
    super.initState();
    _loadInitialWeather();
  }

  Future<void> _loadInitialWeather() async {
    // Check cached weather first for instant load
    final cached = await _weatherService.getCachedWeather();
    if (mounted && cached != null) {
      setState(() => _weather = cached);
    }

    setState(() => _isLoadingWeather = _weather == null);

    try {
      final live = await _weatherService.getWeather();
      if (mounted) {
        setState(() {
          _weather = live;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWeather = false);
      }
    }
  }

  Future<void> _speakWeatherAdvisory() async {
    if (_weather == null) return;
    final w = _weather!;
    final advisory = 'Weather for ${w.cityName}: ${w.tempC.round()} degrees, ${w.conditionText}. '
        'Spraying condition is ${w.sprayingCondition}. ${w.sprayAdvisory}';
    await _voiceService.speak(advisory, languageCode: 'en');
  }

  void _navigateToWeather() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WeatherDetailScreen(initialWeather: _weather),
      ),
    ).then((_) {
      // Refresh home card if location changed
      if (_weatherService.currentWeather != null) {
        setState(() => _weather = _weatherService.currentWeather);
      }
    });
  }

  void _showLocationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Farm Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Get hyper-local weather alerts, rainfall chances, and pesticide spraying conditions tailored to your farm.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Option 1: Live GPS Detection
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF0F4D33), width: 1.5),
                ),
                tileColor: const Color(0xFFE8F5E9).withValues(alpha: 0.5),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F4D33),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
                ),
                title: const Text(
                  'Use Current GPS Location',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: Color(0xFF0F4D33)),
                ),
                subtitle: const Text(
                  'Auto-detect location using phone GPS sensor',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF0F4D33)),
                onTap: () {
                  Navigator.pop(ctx);
                  _detectCurrentGpsLocation();
                },
              ),

              const SizedBox(height: 12),

              // Option 2: Search by City / Village Name
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                tileColor: const Color(0xFFF9FAFB),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 20),
                ),
                title: const Text(
                  'Search Village / City Name',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  'e.g. Bengaluru, Mysuru, Hassan, Pune, Belagavi',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCitySearchDialog();
                },
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _detectCurrentGpsLocation() async {
    setState(() => _isLoadingWeather = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Detecting live farm GPS location...'),
          ],
        ),
        duration: Duration(seconds: 4),
      ),
    );

    try {
      final loc = await LocationService.getCurrentFarmerLocation();
      if (loc.success && loc.latitude != null && loc.longitude != null) {
        final live = await _weatherService.getWeather(
          latitude: loc.latitude,
          longitude: loc.longitude,
          forceRefresh: true,
        );
        if (mounted) {
          setState(() {
            _weather = live;
            _isLoadingWeather = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Farm weather updated for ${live.cityName}!'),
              backgroundColor: const Color(0xFF1B8755),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingWeather = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.errorMessage ?? 'Could not detect GPS location. Please choose village name.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWeather = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating weather: $e')),
        );
      }
    }
  }

  Future<void> _showCitySearchDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Search Farm Location', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your village, taluk, or city name for hyper-local agricultural weather:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Bengaluru, Mysuru, Hassan, Pune',
                filled: true,
                fillColor: const Color(0xFFF7F9F7),
                prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF0F4D33)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  Navigator.pop(ctx);
                  _searchAndSetLocation(val.trim());
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F4D33),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                _searchAndSetLocation(controller.text.trim());
              }
            },
            child: const Text('Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _searchAndSetLocation(String query) async {
    setState(() => _isLoadingWeather = true);
    try {
      final live = await _weatherService.getWeather(
        locationQuery: query,
        forceRefresh: true,
      );
      if (mounted) {
        setState(() {
          _weather = live;
          _isLoadingWeather = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Weather loaded for ${live.cityName}, ${live.region}!'),
            backgroundColor: const Color(0xFF1B8755),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWeather = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not find weather for "$query". Please check spelling.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7), // Soft clean off-white background from reference
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Reference App Header
            SliverToBoxAdapter(
              child: HomeHeader(
                locationName: _weather != null
                    ? '${_weather!.cityName}, ${_weather!.region}'
                    : null,
                onLocationTap: _showLocationSheet,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 2. Reference Weather & Spraying Advisory Card
            SliverToBoxAdapter(
              child: WeatherCard(
                state: _isLoadingWeather
                    ? WeatherState.loading
                    : (_weather != null ? WeatherState.loaded : WeatherState.locationRequired),
                weather: _weather,
                onSetLocation: _showLocationSheet,
                onTap: _navigateToWeather,
                onSpeak: _speakWeatherAdvisory,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 18)),

            // 3. AI Crop Analysis – Section Header
            SliverToBoxAdapter(
              child: SectionHeader(
                title: l10n?.homeServicesTitle ?? AppStrings.homeServicesTitle,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // Flagship Hero Card: Crop Plant Leaf Disease Detection
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: LeafDiseaseCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LeafDiseaseScanScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Two prominent AI Service Cards (Exact reference design with bottom-right organic illustration)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    AiServiceCard(
                      title: l10n?.diseaseDetection ?? AppStrings.diseaseDetection,
                      description:
                          l10n?.diseaseDetectionDesc ?? AppStrings.diseaseDetectionDesc,
                      icon: Icons.eco_outlined,
                      accentColor: AppColors.diseaseCardAccent,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CropDiseaseScanScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    AiServiceCard(
                      title: l10n?.qualityDetection ?? AppStrings.qualityDetection,
                      description:
                          l10n?.qualityDetectionDesc ?? AppStrings.qualityDetectionDesc,
                      icon: Icons.document_scanner_outlined,
                      accentColor: AppColors.qualityCardAccent,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CropQualityScanScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 4. Supported Crops (Circular icon buttons from reference design)
            SliverToBoxAdapter(
              child: SectionHeader(
                title: l10n?.homeSupportedCrops ?? AppStrings.homeSupportedCrops,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CropTile(
                        name: l10n?.cropMango ?? AppStrings.cropMango,
                        emoji: '🥭',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MandiPricesScreen(
                                initialCommodity: 'Mango',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: CropTile(
                        name: l10n?.cropBanana ?? AppStrings.cropBanana,
                        emoji: '🍌',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MandiPricesScreen(
                                initialCommodity: 'Banana',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: CropTile(
                        name: l10n?.cropTomato ?? AppStrings.cropTomato,
                        emoji: '🍅',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MandiPricesScreen(
                                initialCommodity: 'Tomato',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: CropTile(
                        name: l10n?.cropPotato ?? AppStrings.cropPotato,
                        emoji: '🥔',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MandiPricesScreen(
                                initialCommodity: 'Potato',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 5. Quick Services (Circular action icons matching reference design)
            SliverToBoxAdapter(
              child: SectionHeader(
                title: l10n?.homeQuickServices ?? AppStrings.homeQuickServices,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: QuickServiceButton(
                        label: l10n?.serviceWeather ?? AppStrings.serviceWeather,
                        icon: Icons.wb_sunny_outlined,
                        iconColor: AppColors.skyBlue,
                        onTap: _navigateToWeather,
                      ),
                    ),
                    Expanded(
                      child: QuickServiceButton(
                        label: l10n?.serviceMandiPrices ?? AppStrings.serviceMandiPrices,
                        icon: Icons.bar_chart_rounded,
                        iconColor: AppColors.warmAmber,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MandiPricesScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: QuickServiceButton(
                        label: l10n?.serviceAIAssistant ?? AppStrings.serviceAIAssistant,
                        icon: Icons.smart_toy_outlined,
                        iconColor: AppColors.freshGreen,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AiAssistantScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: QuickServiceButton(
                        label: l10n?.serviceLabour ?? AppStrings.serviceLabour,
                        icon: Icons.people_outline_rounded,
                        iconColor: AppColors.earthBrown,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FeaturePlaceholderScreen(
                                title: l10n?.serviceLabour ?? AppStrings.serviceLabour,
                                description: 'Find agricultural workers near you.',
                                icon: Icons.people_outline_rounded,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Clean bottom spacing for navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
