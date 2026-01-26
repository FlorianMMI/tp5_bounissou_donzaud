import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class WeatherService {

  final Dio _dio = Dio();
  
  Future<void> fetchWeatherData(String city) async {

    LocationPermission permission;

    permission = await Geolocator.checkPermission();
     if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
    }
    
    double lat;
    double lon;

    if(city == "Localisation"){
      final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
      );

      Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
      lat = position.latitude;
      lon = position.longitude;
    } else { 
      List<Location> locations = await locationFromAddress(city);
      lat = locations[0].latitude;
      lon = locations[0].longitude; 
    }

    

    try{
      final response = await _dio.get('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,sunset,sunrise&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,precipitation,rain,surface_pressure,visibility,uv_index,cloud_cover,wind_speed_10m&current=temperature_2m,apparent_temperature');
      if(response.statusCode == 200){
      return response.data;
      } else {
        throw Exception('Failed to load weather data');
      }


    } catch (e) {
      throw Exception('Failed to load weather data : $e');
    }

  }


}