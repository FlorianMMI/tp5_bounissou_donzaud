import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class WeatherService {
  final Dio _dio = Dio();

  /// Récupère les données météo à partir d'une ville
  Future<Map<String, dynamic>> fetchWeatherData(String city) async {
    List<Location> locations = await locationFromAddress(city);
    double lat = locations[0].latitude;
    double lon = locations[0].longitude;

    return _fetchWeatherFromCoordinates(lat, lon);
  }

  /// Récupère les données météo à partir de la position GPS de l'utilisateur
  Future<Map<String, dynamic>> fetchWeatherDataByLocation() async {
    // Vérifie si les services de localisation sont activés
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Les services de localisation sont désactivés');
    }

    // Vérifie les permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission de localisation refusée');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission de localisation refusée définitivement');
    }

    // Récupère la position actuelle
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    return _fetchWeatherFromCoordinates(position.latitude, position.longitude);
  }

  /// Récupère le nom de la ville à partir des coordonnées GPS
  Future<String> getCityNameFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        return placemarks[0].locality ?? placemarks[0].subAdministrativeArea ?? 'Position actuelle';
      }
      return 'Position actuelle';
    } catch (e) {
      return 'Position actuelle';
    }
  }

  /// Méthode privée pour récupérer les données météo depuis des coordonnées
  Future<Map<String, dynamic>> _fetchWeatherFromCoordinates(
      double lat, double lon) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,sunset,sunrise&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,precipitation,rain,surface_pressure,visibility,uv_index,cloud_cover,wind_speed_10m&current=temperature_2m,apparent_temperature',
      );
      
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Failed to load weather data : $e');
    }
  }
}