/// Modèle simplifié pour les données météo
class WeatherModel {
  // Températures
  final double currentTemp;
  final double apparentTemp;
  final double maxTemp;
  final double minTemp;

  // Informations météo
  final double humidity;
  final double precipitation;
  final int precipProbability;
  final double windSpeed;
  final double pressure;
  final double uvIndex;
  final double visibility;
  final int cloudCover;

  WeatherModel({
    required this.currentTemp,
    required this.apparentTemp,
    required this.maxTemp,
    required this.minTemp,
    required this.humidity,
    required this.precipitation,
    required this.precipProbability,
    required this.windSpeed,
    required this.pressure,
    required this.uvIndex,
    required this.visibility,
    required this.cloudCover,
  });

  /// Crée un modèle à partir des données brutes de l'API
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      currentTemp: json['current']?['temperature_2m']?.toDouble() ?? 0.0,
      apparentTemp: json['current']?['apparent_temperature']?.toDouble() ?? 0.0,
      maxTemp: json['daily']?['temperature_2m_max']?[0]?.toDouble() ?? 0.0,
      minTemp: json['daily']?['temperature_2m_min']?[0]?.toDouble() ?? 0.0,
      humidity: json['hourly']?['relative_humidity_2m']?[0]?.toDouble() ?? 0.0,
      precipitation: json['hourly']?['precipitation']?[0]?.toDouble() ?? 0.0,
      precipProbability: json['hourly']?['precipitation_probability']?[0]?.toInt() ?? 0,
      windSpeed: json['hourly']?['wind_speed_10m']?[0]?.toDouble() ?? 0.0,
      pressure: json['hourly']?['surface_pressure']?[0]?.toDouble() ?? 0.0,
      uvIndex: json['hourly']?['uv_index']?[0]?.toDouble() ?? 0.0,
      visibility: (json['hourly']?['visibility']?[0]?.toDouble() ?? 0.0) / 1000,
      cloudCover: json['hourly']?['cloud_cover']?[0]?.toInt() ?? 0,
    );
  }

  /// Retourne l'emoji météo basé sur la couverture nuageuse et les précipitations
  String get weatherEmoji {
    if (precipitation > 0) return '🌧️';
    if (cloudCover < 20) return '☀️';
    if (cloudCover < 50) return '🌤️';
    if (cloudCover < 80) return '⛅';
    return '☁️';
  }
}
