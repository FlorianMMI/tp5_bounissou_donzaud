


import 'package:tp5_bounissou_donzaud/services/Weather_Data.dart';

void main(List<String> args) {
  WeatherService weatherService = WeatherService();
  weatherService.fetchWeatherData("Limoges");
}