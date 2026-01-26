import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class WeatherService {

  final Dio _dio = Dio();
  
  Future<void> fetchWeatherData(String city) async {
    
    // if(city == "Localisation"){
    //   final LocationSettings locationSettings = LocationSettings(
    //   accuracy: LocationAccuracy.high,
    //   distanceFilter: 100,
    //   );

    //   Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    //   print('position: $position');
    // }

    List<Location> locations = await locationFromAddress(city);
    double lat = locations[0].latitude;
    double lon = locations[0].longitude;

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