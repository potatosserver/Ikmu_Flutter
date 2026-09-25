// 天氣服務
// 串接 Open-Meteo API (https://open-meteo.com/)
// 對應 kaohsiung_live_bus 實作

import 'package:dio/dio.dart';

import '../../constants/location_constants.dart';

/// Open-Meteo 天氣回應模型
class WeatherData {
  WeatherData({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
    required this.timezone,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      relativeHumidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      isDay: (current['is_day'] as num).toInt() == 1,
      timezone: json['timezone'] as String? ?? 'Asia/Taipei',
    );
  }

  final double temperature;           // 氣溫 (°C)
  final double apparentTemperature;   // 體感溫度 (°C)
  final int relativeHumidity;         // 相對濕度 (%)
  final double windSpeed;             // 風速 (km/h)
  final int weatherCode;              // WMO 天氣代碼
  final bool isDay;                   // 是否白天
  final String timezone;              // 時區

  /// 取得天氣描述 (中文)
  String get description => _getWeatherDescription(weatherCode);

  /// 取得天氣圖示 (Emoji)
  String get icon => _getWeatherIcon(weatherCode, isDay);

  /// 格式化顯示用溫度
  String get temperatureDisplay => '${temperature.round()}°C';
  String get apparentTemperatureDisplay => '${apparentTemperature.round()}°C';
  String get humidityDisplay => '$relativeHumidity%';
  String get windSpeedDisplay => '${windSpeed.round()} km/h';

  // ===========================================
  // WMO 天氣代碼對照 (對齊 kaohsiung_live_bus)
  // ===========================================
  static String _getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return '晴朗';
      case 1:
        return '主要晴朗';
      case 2:
        return '局部多雲';
      case 3:
        return '多雲';
      case 45:
        return '霧';
      case 48:
        return '結霜霧';
      case 51:
        return '毛毛雨：小雨';
      case 53:
        return '毛毛雨：中雨';
      case 55:
        return '毛毛雨：大雨';
      case 56:
        return '凍毛毛雨：小雨';
      case 57:
        return '凍毛毛雨：大雨';
      case 61:
        return '小雨';
      case 63:
        return '中雨';
      case 65:
        return '大雨';
      case 66:
        return '凍雨：小雨';
      case 67:
        return '凍雨：大雨';
      case 71:
        return '小雪';
      case 73:
        return '中雪';
      case 75:
        return '大雪';
      case 77:
        return '雪粒';
      case 80:
        return '陣雨：小雨';
      case 81:
        return '陣雨：中雨';
      case 82:
        return '陣雨：大雨';
      case 85:
        return '陣雪：小雪';
      case 86:
        return '陣雪：大雪';
      case 95:
        return '雷暴';
      case 96:
        return '雷暴伴隨小冰雹';
      case 99:
        return '雷暴伴隨大冰雹';
      default:
        return '未知天氣';
    }
  }

  static String _getWeatherIcon(int code, bool isDay) {
    switch (code) {
      case 0:
        return isDay ? '☀️' : '🌙';
      case 1:
        return isDay ? '🌤️' : '☁️';
      case 2:
        return isDay ? '⛅' : '☁️';
      case 3:
        return '☁️';
      case 45:
      case 48:
        return '🌫️';
      case 51:
      case 53:
      case 55:
        return '🌧️';
      case 56:
      case 57:
        return '🌨️';
      case 61:
      case 63:
        return '🌧️';
      case 65:
        return '☔';
      case 66:
      case 67:
        return '🧊🌧️';
      case 71:
      case 73:
      case 75:
        return '❄️';
      case 77:
        return '🌨️';
      case 80:
      case 81:
      case 82:
        return '⛈️';
      case 85:
      case 86:
        return '🌨️';
      case 95:
      case 96:
      case 99:
        return '⚡';
      default:
        return '❓';
    }
  }
}

/// 天氣服務
class WeatherService {
  WeatherService({Dio? dio}) : _dio = dio ?? Dio();

  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  final Dio _dio;

  /// 取得當前天氣
  Future<WeatherData> fetchCurrentWeather() async {
    final params = {
      'latitude': KmuLocation.latitude.toString(),
      'longitude': KmuLocation.longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m',
      'timezone': 'Asia/Taipei',
      'forecast_days': '1',
    };

    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: params,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        return WeatherData.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('網路錯誤: ${e.message}');
    }
  }
}