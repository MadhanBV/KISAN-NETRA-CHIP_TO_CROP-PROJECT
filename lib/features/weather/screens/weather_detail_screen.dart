import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../ai_assistant/services/voice_service.dart';
import '../../mandi/services/location_service.dart';
import '../models/weather_data.dart';
import '../services/weather_api_service.dart';

class WeatherDetailScreen extends StatefulWidget {
  final AgriculturalWeather? initialWeather;

  const WeatherDetailScreen({super.key, this.initialWeather});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  final WeatherApiService _weatherService = WeatherApiService();
  final VoiceService _voiceService = VoiceService();

  AgriculturalWeather? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPlayingVoice = false;

  @override
  void initState() {
    super.initState();
    _weather = widget.initialWeather ?? _weatherService.currentWeather;
    _voiceService.speakingNotifier.addListener(_onVoiceChanged);

    if (_weather == null) {
      _loadWeather();
    }
  }

  void _onVoiceChanged() {
    if (mounted) {
      setState(() {
        _isPlayingVoice = _voiceService.speakingNotifier.value;
      });
    }
  }

  @override
  void dispose() {
    _voiceService.speakingNotifier.removeListener(_onVoiceChanged);
    _voiceService.stop();
    super.dispose();
  }

  Future<void> _loadWeather({String? query, bool force = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _weatherService.getWeather(
        locationQuery: query,
        forceRefresh: force,
      );
      if (mounted) {
        setState(() {
          _weather = data;
          _isLoading = false;
        });
        if (force) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Farm weather updated for ${data.cityName}, ${data.region}!'),
              backgroundColor: const Color(0xFF1B8755),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not fetch weather updates. Please check your internet connection.';
        });
      }
    }
  }

  Future<void> _refreshGpsLocation() async {
    setState(() => _isLoading = true);
    final loc = await LocationService.getCurrentFarmerLocation();
    if (loc.success && loc.latitude != null && loc.longitude != null) {
      await _loadWeather(query: '${loc.latitude},${loc.longitude}', force: true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.errorMessage ?? 'Unable to acquire GPS location.')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Location', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your village, taluk, or city name for hyper-local agricultural weather:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Pune, Hassan, Nashik, Mysuru',
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final q = controller.text.trim();
              if (q.isNotEmpty) {
                Navigator.pop(ctx);
                _loadWeather(query: q, force: true);
              }
            },
            child: const Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleSpeakAdvisory() async {
    if (_weather == null) return;
    if (_isPlayingVoice) {
      await _voiceService.stop();
      setState(() => _isPlayingVoice = false);
      return;
    }

    final text = 'Weather report for ${_weather!.cityName}. '
        'Temperature is ${_weather!.tempC.round()} degrees Celsius, condition is ${_weather!.conditionText}. '
        'Humidity is ${_weather!.humidity} percent. Wind speed is ${_weather!.windKph.toStringAsFixed(1)} kilometers per hour. '
        'Spraying condition is ${_weather!.sprayingCondition}. ${_weather!.sprayAdvisory}';

    await _voiceService.speak(text, languageCode: 'en');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4D33),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _weather?.cityName ?? 'Agricultural Weather',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            if (_weather != null && _weather!.region.isNotEmpty)
              Text(
                '${_weather!.region}, ${_weather!.country}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: Colors.white, size: 22),
            tooltip: 'Use GPS',
            onPressed: _refreshGpsLocation,
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
            tooltip: 'Search City',
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: _isLoading && _weather == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _loadWeather(force: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Top Hero Weather Card
                    _buildHeroWeatherCard(),

                    const SizedBox(height: 16),

                    // Spraying Advisory (Crucial for farmers)
                    if (_weather != null) _buildSprayingAdvisoryCard(),

                    const SizedBox(height: 16),

                    // Key Agricultural Parameters
                    if (_weather != null) _buildAgriculturalParametersGrid(),

                    const SizedBox(height: 20),

                    // Hourly Forecast Slider
                    if (_weather != null && _weather!.hourly.isNotEmpty) _buildHourlySection(),

                    const SizedBox(height: 20),

                    // 3-Day Forecast
                    if (_weather != null && _weather!.daily.isNotEmpty) _buildDailySection(),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroWeatherCard() {
    if (_weather == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            _errorMessage ?? 'No weather data available.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final w = _weather!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F4D33),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${w.tempC.round()}°',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.0,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'C',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    w.conditionText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Feels like ${w.feelsLikeC.round()}°C',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFB5E4CC),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  if (w.conditionIcon.isNotEmpty)
                    Image.network(
                      w.conditionIcon,
                      width: 80,
                      height: 80,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.cloud_outlined,
                        size: 70,
                        color: Colors.white70,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Audio advisory button
                  GestureDetector(
                    onTap: _toggleSpeakAdvisory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPlayingVoice ? Icons.stop_rounded : Icons.volume_up_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isPlayingVoice ? 'Stop' : 'Listen',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickParam(Icons.water_drop_outlined, '${w.humidity}%', 'Humidity'),
                Container(width: 1, height: 28, color: Colors.white24),
                _buildQuickParam(Icons.air_rounded, '${w.windKph.toStringAsFixed(1)} km/h', 'Wind (${w.windDir})'),
                Container(width: 1, height: 28, color: Colors.white24),
                _buildQuickParam(Icons.grain_rounded, '${w.rainChance}%', 'Rain Chance'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickParam(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF98DFBF), size: 16),
            const SizedBox(width: 5),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFB5E4CC), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildSprayingAdvisoryCard() {
    final w = _weather!;
    final isFavorable = w.sprayingCondition == 'Favorable';
    final isModerate = w.sprayingCondition == 'Moderate';

    final badgeColor = isFavorable
        ? const Color(0xFF1B8755)
        : isModerate
            ? const Color(0xFFD97706)
            : const Color(0xFFDC2626);

    final bgColor = isFavorable
        ? const Color(0xFFE8F5E9)
        : isModerate
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFFEE2E2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.sanitizer_rounded, color: badgeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pesticide & Spraying Advisory',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Agricultural decision guide for spraying',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor, width: 1),
                  ),
                  child: Text(
                    w.sprayingCondition,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              w.sprayAdvisory,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgriculturalParametersGrid() {
    final w = _weather!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agricultural Weather Metrics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _buildMetricCard(
                icon: Icons.water_drop_outlined,
                iconColor: const Color(0xFF2563EB),
                label: 'Relative Humidity',
                value: '${w.humidity}%',
                subtitle: w.humidity > 80 ? 'High fungal risk' : 'Normal moisture',
                subtitleColor: w.humidity > 80 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
              ),
              _buildMetricCard(
                icon: Icons.air_rounded,
                iconColor: const Color(0xFF0D9488),
                label: 'Wind & Drift',
                value: '${w.windKph.toStringAsFixed(1)} km/h',
                subtitle: 'Direction: ${w.windDir}',
                subtitleColor: AppColors.textSecondary,
              ),
              _buildMetricCard(
                icon: Icons.umbrella_outlined,
                iconColor: const Color(0xFF4F46E5),
                label: 'Precipitation',
                value: '${w.precipMm} mm',
                subtitle: 'Chance: ${w.rainChance}%',
                subtitleColor: AppColors.textSecondary,
              ),
              _buildMetricCard(
                icon: Icons.wb_sunny_outlined,
                iconColor: const Color(0xFFEA580C),
                label: 'UV Index',
                value: w.uvIndex.toStringAsFixed(1),
                subtitle: w.uvIndex >= 8 ? 'Very high radiation' : 'Moderate sun',
                subtitleColor: w.uvIndex >= 8 ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
              ),
              _buildMetricCard(
                icon: Icons.thermostat_outlined,
                iconColor: const Color(0xFF059669),
                label: 'Dew Point',
                value: '${w.dewPointC.toStringAsFixed(1)}°C',
                subtitle: 'Leaf moisture index',
                subtitleColor: AppColors.textSecondary,
              ),
              _buildMetricCard(
                icon: Icons.schedule_rounded,
                iconColor: const Color(0xFF7C3AED),
                label: 'Best Spray Time',
                value: w.sprayingCondition == 'Favorable' ? 'Now / Morning' : 'Postpone',
                subtitle: 'Avoid midday heat',
                subtitleColor: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: subtitleColor),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHourlySection() {
    final w = _weather!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Hourly Forecast (Next 12 Hours)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 124,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: w.hourly.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final h = w.hourly[i];
              return Container(
                width: 82,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      h.time,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    if (h.conditionIcon.isNotEmpty)
                      Image.network(
                        h.conditionIcon,
                        width: 32,
                        height: 32,
                        errorBuilder: (_, __, ___) => const Icon(Icons.wb_cloudy_outlined, size: 24, color: AppColors.primary),
                      ),
                    Text(
                      '${h.tempC.round()}°',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.water_drop_outlined, size: 10, color: Color(0xFF2563EB)),
                        const SizedBox(width: 2),
                        Text(
                          '${h.rainChance}%',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailySection() {
    final w = _weather!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3-Day Agricultural Outlook',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: w.daily.length,
              separatorBuilder: (_, __) => const Divider(height: 24, color: AppColors.border),
              itemBuilder: (ctx, i) {
                final d = w.daily[i];
                return Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        i == 0 ? 'Today' : d.dayName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (d.conditionIcon.isNotEmpty)
                      Image.network(
                        d.conditionIcon,
                        width: 34,
                        height: 34,
                        errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny_outlined, size: 24),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.conditionText,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.water_drop_outlined, size: 11, color: Color(0xFF2563EB)),
                              const SizedBox(width: 3),
                              Text(
                                '${d.rainChance}% rain (${d.totalPrecipMm} mm)',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${d.maxTempC.round()}° / ${d.minTempC.round()}°',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
