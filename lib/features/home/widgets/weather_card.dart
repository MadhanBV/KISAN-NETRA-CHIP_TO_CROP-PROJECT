import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../l10n/app_localizations.dart';
import '../../weather/models/weather_data.dart';

/// Represents the current state of weather data availability.
enum WeatherState { loading, loaded, locationRequired, unavailable }

/// Production-grade weather and spraying advisory card
/// directly modeled after the clean, agricultural reference design.
class WeatherCard extends StatelessWidget {
  final WeatherState state;
  final AgriculturalWeather? weather;
  final VoidCallback? onRetry;
  final VoidCallback? onSetLocation;
  final VoidCallback? onTap;
  final VoidCallback? onSpeak;

  const WeatherCard({
    super.key,
    this.state = WeatherState.locationRequired,
    this.weather,
    this.onRetry,
    this.onSetLocation,
    this.onTap,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0F4D33), // Deep agricultural green from reference
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F4D33).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: _buildContent(l10n),
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations? l10n) {
    if (weather != null) {
      return _buildLoaded(weather!);
    }
    return switch (state) {
      WeatherState.loading => _buildLoading(),
      WeatherState.loaded => _buildLoaded(weather),
      WeatherState.locationRequired => _buildLocationRequired(l10n),
      WeatherState.unavailable => _buildUnavailable(l10n),
    };
  }

  Widget _buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.cloud_outlined, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              AppStrings.weatherLoading,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: 100,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoaded([AgriculturalWeather? data]) {
    final w = data ?? weather;
    final temp = w != null ? '${w.tempC.round()}°C' : '23°C';
    final condition = w != null ? w.conditionText : 'Overcast';
    final city = w != null ? w.cityName : 'Bengaluru';
    final rainStrip = w != null
        ? (w.rainChance > 0 ? '${w.rainChance}% rain chance • ${w.precipMm} mm' : 'No rain expected today')
        : 'Rain expected after 2 PM';
    final sprayCondition = w != null ? w.sprayingCondition : 'Favorable';
    final sprayTiming = w != null
        ? (w.sprayingCondition == 'Favorable' ? 'Now' : 'Wait')
        : 'Now';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: Clouds graphic + 23°C | Overcast + Speaker
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Stylized overlapping clouds icon
            if (w != null && w.conditionIcon.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  w.conditionIcon,
                  width: 44,
                  height: 44,
                  errorBuilder: (_, __, ___) => const _WeatherCloudIcon(),
                ),
              )
            else
              const _WeatherCloudIcon(),
            const SizedBox(width: 14),

            // Temperature & Condition
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        temp,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1.5, height: 18, color: Colors.white60),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          condition,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onSetLocation,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: Colors.white70),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            city,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.edit_location_alt_rounded, size: 12, color: Colors.white70),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Circular speaker icon (audio advisory button)
            GestureDetector(
              onTap: onSpeak,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                ),
                child: const Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Rain expectation strip
        Row(
          children: [
            const Icon(Icons.grain_rounded, color: Color(0xFF98DFBF), size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                rainStrip,
                style: const TextStyle(
                  color: Color(0xFFB5E4CC),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Bottom two white pills: Spraying condition & Spray after
        Row(
          children: [
            Expanded(
              child: _SprayPill(
                label: 'Spraying condition',
                value: sprayCondition,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SprayPill(
                label: 'Spray after',
                value: sprayTiming,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationRequired(AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: Clouds graphic + Title + Set Button
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _WeatherCloudIcon(),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weather & Farming Advisory',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n?.weatherSetLocation ?? AppStrings.weatherSetLocation,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // White 'Set' button pill
            GestureDetector(
              onTap: onSetLocation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Set',
                  style: TextStyle(
                    color: Color(0xFF0F4D33),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Rain expectation strip
        Row(
          children: const [
            Icon(Icons.grain_rounded, color: Color(0xFF98DFBF), size: 16),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Rain expected after 2 PM',
                style: TextStyle(
                  color: Color(0xFFB5E4CC),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Bottom two white pills: Spraying condition & Spray after
        Row(
          children: const [
            Expanded(
              child: _SprayPill(
                label: 'Spraying condition',
                value: 'Favorable',
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SprayPill(
                label: 'Spray after',
                value: 'Now',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnavailable(AppLocalizations? l10n) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.cloud_off_outlined, color: Colors.white70, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.weatherUnavailable ?? AppStrings.weatherUnavailable,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Check your connection and try again',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n?.weatherRetry ?? AppStrings.weatherRetry,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Stylized cloud vector graphic from reference design
class _WeatherCloudIcon extends StatelessWidget {
  const _WeatherCloudIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 44,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Grey background cloud circle
          Positioned(
            left: 0,
            top: 4,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFCBD5E1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Cyan accent circle
          Positioned(
            left: 18,
            top: 2,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFF38BDF8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // White foreground cloud circle
          Positioned(
            left: 10,
            bottom: 0,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// White pill card displaying spraying recommendation
class _SprayPill extends StatelessWidget {
  final String label;
  final String value;

  const _SprayPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Green checkmark circle
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFF0F4D33),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 6),

          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
