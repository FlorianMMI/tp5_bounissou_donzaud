import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  final Dio _dio = Dio();
  static const Duration _cacheDuration = Duration(minutes: 30);

  // Récupérer les données depuis le cache
  Future<Map<String, dynamic>?> _getCachedData(String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('weather_$city');
      final cachedTime = prefs.getInt('weather_${city}_time');

      if (cachedJson != null && cachedTime != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - cachedTime;
        if (cacheAge < _cacheDuration.inMilliseconds) {
          return json.decode(cachedJson);
        }
      }
    } catch (e) {
      print('Erreur lors de la lecture du cache: $e');
    }
    return null;
  }

  // Sauvegarder les données dans le cache
  Future<void> _saveCachedData(String city, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weather_$city', json.encode(data));
      await prefs.setInt('weather_${city}_time', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Erreur lors de la sauvegarde du cache: $e');
    }
  }

  Future<Map<String, dynamic>> fetchWeatherData(String city) async {
    // Vérifier le cache d'abord
    final cachedData = await _getCachedData(city);
    if (cachedData != null) {
      print('Données chargées depuis le cache pour $city');
      return cachedData;
    }
    // On demande la permission de localisation + on verifie qu'on l'a bien
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    //Initialisation des variables de latitude et longitude

    double lat;
    double lon;

    // Si on passe la variable "Localisation", on recupere la position actuelle sinon on utilise la geocoding pour recuperer les coordonnees de la ville

    if (city == "Localisation") {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      lat = position.latitude;
      lon = position.longitude;
    } else {
      try {
        
        
        // Utilisation de l'API Nominatim pour le geocoding
        final geoResponse = await _dio.get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'q': city,
            'format': 'json',
            'limit': 1,
          },
          options: Options(
            headers: {
              'User-Agent': 'WeatherApp/1.0',
            },
          ),
        );
                
        if (geoResponse.data == null || (geoResponse.data as List).isEmpty) {
          throw Exception('Impossible de trouver des coordonnées pour $city');
        }
        
        final location = (geoResponse.data as List)[0];
        lat = double.parse(location['lat']);
        lon = double.parse(location['lon']);
        
        
      } catch (e) {
        rethrow;
      }
    }

    // Récupération des données météo depuis l'API avec les coordonnées obtenues
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,sunset,sunrise&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,precipitation,rain,surface_pressure,visibility,uv_index,cloud_cover,wind_speed_10m&current=temperature_2m,apparent_temperature',
      );
      if (response.statusCode == 200) {
        final weatherData = response.data as Map<String, dynamic>;
        // Sauvegarder dans le cache
        await _saveCachedData(city, weatherData);
        return weatherData;
      } else {
        throw Exception('Failed to load weather data');
      }

      // Gestion des erreurs de requête
    } catch (e) {
      throw Exception('Failed to load weather data : $e');
    }
  }

  // Fonction pour récupérer uniquement la température actuelle pour la page de la liste des villes

  Future<String> fetchTempData(String city) async {
    // Vérifier le cache d'abord pour les températures aussi
    final cachedData = await _getCachedData(city);
    if (cachedData != null && 
        cachedData['current'] != null && 
        cachedData['current']['temperature_2m'] != null) {
      print('Température chargée depuis le cache pour $city');
      return cachedData['current']['temperature_2m'].toString();
    }

    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    //Initialisation des variables de latitude et longitude

    late double lat;
    late double lon;

    // Si on passe la variable "Localisation", on recupere la position actuelle sinon on utilise la geocoding pour recuperer les coordonnees de la ville

    if (city == "Localisation") {
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      lat = position.latitude;
      lon = position.longitude;
    } 

    else {
      try {        
        // Utilisation de l'API Nominatim pour le geocoding
        final geoResponse = await _dio.get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'q': city,
            'format': 'json',
            'limit': 1,
          },
          options: Options(
            headers: {
              'User-Agent': 'WeatherApp/1.0',
            },
          ),
        );
        
        
        
        if (geoResponse.data == null || (geoResponse.data as List).isEmpty) {
          throw Exception('Impossible de trouver des coordonnées pour $city');
        }
        
        final location = (geoResponse.data as List)[0];
        lat = double.parse(location['lat']);
        lon = double.parse(location['lon']);
        
        
      } catch (e) {
        
        rethrow;
      }
    }
    // Récupération des données météo depuis l'API avec les coordonnées obtenues
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,is_day&timezone=Europe%2FLondon',
      );
      

      if (response.statusCode == 200) {
        if (response.data == null ||
            response.data['current'] == null ||
            response.data['current']['temperature_2m'] == null) {
          
          throw Exception('Données météo incomplètes');
        }
        String data = response.data['current']['temperature_2m'].toString();
        
        // Sauvegarder les données complètes dans le cache pour une utilisation future
        await _saveCachedData(city, response.data);
        
        return data;
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }

      // Gestion des erreurs de requête
    } catch (e) {
      
      rethrow;
    }
  }
}
