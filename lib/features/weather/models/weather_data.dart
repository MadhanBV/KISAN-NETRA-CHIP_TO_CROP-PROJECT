/// Rich agricultural weather model powered by WeatherAPI.com
class AgriculturalWeather {
  final String cityName;
  final String region;
  final String country;
  final double tempC;
  final double feelsLikeC;
  final String conditionText;
  final String conditionIcon;
  final int humidity;
  final double windKph;
  final String windDir;
  final double precipMm;
  final int rainChance;
  final double uvIndex;
  final double dewPointC;
  final String sprayingCondition; // 'Favorable', 'Moderate', 'Unfavorable'
  final String sprayAdvisory;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;
  final DateTime lastUpdated;

  const AgriculturalWeather({
    required this.cityName,
    required this.region,
    required this.country,
    required this.tempC,
    required this.feelsLikeC,
    required this.conditionText,
    required this.conditionIcon,
    required this.humidity,
    required this.windKph,
    required this.windDir,
    required this.precipMm,
    required this.rainChance,
    required this.uvIndex,
    required this.dewPointC,
    required this.sprayingCondition,
    required this.sprayAdvisory,
    required this.hourly,
    required this.daily,
    required this.lastUpdated,
  });

  factory AgriculturalWeather.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>? ?? {};
    final cur = json['current'] as Map<String, dynamic>? ?? {};
    final cond = cur['condition'] as Map<String, dynamic>? ?? {};
    final forecast = json['forecast'] as Map<String, dynamic>? ?? {};
    final forecastDays = (forecast['forecastday'] as List?) ?? [];

    final temp = (cur['temp_c'] as num?)?.toDouble() ?? 24.0;
    final feelsLike = (cur['feelslike_c'] as num?)?.toDouble() ?? temp;
    final humidityVal = (cur['humidity'] as num?)?.toInt() ?? 65;
    final windSpeed = (cur['wind_kph'] as num?)?.toDouble() ?? 8.0;
    final windDirection = cur['wind_dir']?.toString() ?? 'N';
    final precip = (cur['precip_mm'] as num?)?.toDouble() ?? 0.0;
    final uv = (cur['uv'] as num?)?.toDouble() ?? 5.0;
    final dew = (cur['dewpoint_c'] as num?)?.toDouble() ?? 18.0;

    // Extract rain chance from today's forecast
    int chanceOfRain = 0;
    if (forecastDays.isNotEmpty) {
      final todayDay = forecastDays[0]['day'] as Map<String, dynamic>?;
      if (todayDay != null) {
        chanceOfRain = (todayDay['daily_chance_of_rain'] as num?)?.toInt() ?? 0;
      }
    }

    // Determine spraying condition based on agricultural criteria:
    // Ideal spraying: Wind < 12 km/h, Rain chance < 30%, Humidity 40-75%
    // Unfavorable: Wind > 18 km/h (severe drift) or Rain chance > 50% or precip > 1.0mm
    String sprayCond;
    String sprayAdv;
    if (precip > 1.0 || chanceOfRain >= 50) {
      sprayCond = 'Unfavorable';
      sprayAdv = 'High chance of rain. Avoid spraying chemicals to prevent wash-off.';
    } else if (windSpeed > 16.0) {
      sprayCond = 'Unfavorable';
      sprayAdv = 'Wind speed (${windSpeed.toStringAsFixed(1)} km/h) is too high. High chemical drift risk.';
    } else if (humidityVal > 85) {
      sprayCond = 'Moderate';
      sprayAdv = 'High humidity ($humidityVal%). Watch for fungal spread; spray during drier daylight hours.';
    } else if (windSpeed > 12.0 || chanceOfRain >= 30) {
      sprayCond = 'Moderate';
      sprayAdv = 'Moderate conditions. Spray during early morning or late afternoon.';
    } else {
      sprayCond = 'Favorable';
      sprayAdv = 'Optimal conditions! Low wind (${windSpeed.toStringAsFixed(1)} km/h) and no rain expected.';
    }

    // Parse Hourly
    final List<HourlyWeather> hourlyList = [];
    if (forecastDays.isNotEmpty) {
      final hours = (forecastDays[0]['hour'] as List?) ?? [];
      final currentHour = DateTime.now().hour;
      for (final h in hours) {
        if (h is Map<String, dynamic>) {
          final timeStr = h['time']?.toString() ?? '';
          final hourNum = DateTime.tryParse(timeStr)?.hour ?? 0;
          // Filter to show from current hour onwards, up to 12 hours
          if (hourNum >= currentHour && hourlyList.length < 12) {
            hourlyList.add(HourlyWeather.fromJson(h));
          }
        }
      }
    }

    // Parse 3-day forecast
    final List<DailyWeather> dailyList = [];
    for (final d in forecastDays) {
      if (d is Map<String, dynamic>) {
        dailyList.add(DailyWeather.fromJson(d));
      }
    }

    var iconUrl = cond['icon']?.toString() ?? '';
    if (iconUrl.startsWith('//')) {
      iconUrl = 'https:$iconUrl';
    }

    return AgriculturalWeather(
      cityName: loc['name']?.toString() ?? 'Local Farm',
      region: loc['region']?.toString() ?? '',
      country: loc['country']?.toString() ?? 'India',
      tempC: temp,
      feelsLikeC: feelsLike,
      conditionText: cond['text']?.toString() ?? 'Clear',
      conditionIcon: iconUrl,
      humidity: humidityVal,
      windKph: windSpeed,
      windDir: windDirection,
      precipMm: precip,
      rainChance: chanceOfRain,
      uvIndex: uv,
      dewPointC: dew,
      sprayingCondition: sprayCond,
      sprayAdvisory: sprayAdv,
      hourly: hourlyList,
      daily: dailyList,
      lastUpdated: DateTime.now(),
    );
  }
}

class HourlyWeather {
  final String time;
  final double tempC;
  final int rainChance;
  final int humidity;
  final double windKph;
  final String conditionText;
  final String conditionIcon;

  const HourlyWeather({
    required this.time,
    required this.tempC,
    required this.rainChance,
    required this.humidity,
    required this.windKph,
    required this.conditionText,
    required this.conditionIcon,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    final cond = json['condition'] as Map<String, dynamic>? ?? {};
    var iconUrl = cond['icon']?.toString() ?? '';
    if (iconUrl.startsWith('//')) {
      iconUrl = 'https:$iconUrl';
    }

    final rawTime = json['time']?.toString() ?? '';
    String displayTime = rawTime;
    final dt = DateTime.tryParse(rawTime);
    if (dt != null) {
      final hour = dt.hour;
      final period = hour >= 12 ? 'PM' : 'AM';
      final h12 = hour % 12 == 0 ? 12 : hour % 12;
      displayTime = '$h12 $period';
    }

    return HourlyWeather(
      time: displayTime,
      tempC: (json['temp_c'] as num?)?.toDouble() ?? 24.0,
      rainChance: (json['chance_of_rain'] as num?)?.toInt() ?? 0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 60,
      windKph: (json['wind_kph'] as num?)?.toDouble() ?? 5.0,
      conditionText: cond['text']?.toString() ?? 'Clear',
      conditionIcon: iconUrl,
    );
  }
}

class DailyWeather {
  final String date;
  final String dayName;
  final double maxTempC;
  final double minTempC;
  final int rainChance;
  final double totalPrecipMm;
  final int avgHumidity;
  final double maxWindKph;
  final String conditionText;
  final String conditionIcon;

  const DailyWeather({
    required this.date,
    required this.dayName,
    required this.maxTempC,
    required this.minTempC,
    required this.rainChance,
    required this.totalPrecipMm,
    required this.avgHumidity,
    required this.maxWindKph,
    required this.conditionText,
    required this.conditionIcon,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    final day = json['day'] as Map<String, dynamic>? ?? {};
    final cond = day['condition'] as Map<String, dynamic>? ?? {};
    final dateStr = json['date']?.toString() ?? '';

    var iconUrl = cond['icon']?.toString() ?? '';
    if (iconUrl.startsWith('//')) {
      iconUrl = 'https:$iconUrl';
    }

    String dayName = 'Day';
    final dt = DateTime.tryParse(dateStr);
    if (dt != null) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      dayName = weekdays[dt.weekday - 1];
    }

    return DailyWeather(
      date: dateStr,
      dayName: dayName,
      maxTempC: (day['maxtemp_c'] as num?)?.toDouble() ?? 28.0,
      minTempC: (day['mintemp_c'] as num?)?.toDouble() ?? 18.0,
      rainChance: (day['daily_chance_of_rain'] as num?)?.toInt() ?? 0,
      totalPrecipMm: (day['totalprecip_mm'] as num?)?.toDouble() ?? 0.0,
      avgHumidity: (day['avghumidity'] as num?)?.toInt() ?? 70,
      maxWindKph: (day['maxwind_kph'] as num?)?.toDouble() ?? 10.0,
      conditionText: cond['text']?.toString() ?? 'Partly Cloudy',
      conditionIcon: iconUrl,
    );
  }
}

