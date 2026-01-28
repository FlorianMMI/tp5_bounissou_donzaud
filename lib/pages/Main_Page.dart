import 'package:flutter/material.dart';
import 'package:tp5_bounissou_donzaud/services/weather_data.dart';
import 'package:tp5_bounissou_donzaud/widgets/glass_container.dart';
import 'package:tp5_bounissou_donzaud/widgets/weather_info_card.dart';
import 'package:tp5_bounissou_donzaud/widgets/video_weather_background.dart';
import 'package:tp5_bounissou_donzaud/models/weather_model.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  WeatherModel? _weather; // Modèle simplifié des données météo
  bool _isLoading = true;
  String _cityName = "Chargement...";
  double? _currentLat; // Latitude actuelle
  double? _currentLon; // Longitude actuelle
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _loadWeatherData();
  }

  /// Charge les données météo depuis l'API en utilisant la géolocalisation
  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Récupère les données météo via GPS
      final data = await _weatherService.fetchWeatherData("Localisation");
      
      // Récupère les coordonnées depuis les données de réponse
      _currentLat = data['latitude']?.toDouble();
      _currentLon = data['longitude']?.toDouble();
            
      
      setState(() {
        _weather = WeatherModel.fromJson(data); // Conversion simplifiée
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _cityName = "Erreur de localisation";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red.withOpacity(0.8),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: _loadWeatherData,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoWeatherBackground(
        cloudCover: _weather?.cloudCover ?? 50,
        precipitation: _weather?.precipitation ?? 0,
        temperature: _weather?.currentTemp ?? 15,
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Récupération de votre position...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWeatherData,
                  color: Colors.white,
                  backgroundColor: Colors.blue.shade900,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 30),
                            _buildMainTemperatureCard(),
                            const SizedBox(height: 30),
                            _buildWeatherGrid(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// En-tête avec nom de ville et bouton refresh
  Widget _buildHeader() {
    return GlassContainer(
      blur: 25,
      opacity: 0.3,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(
                _cityName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: _loadWeatherData,
          ),
        ],
      ),
    );
  }

  /// Carte principale affichant la température actuelle et les min/max
  Widget _buildMainTemperatureCard() {
    if (_weather == null) return const SizedBox();

    return GlassContainer(
      blur: 30,
      opacity: 0.25,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Emoji basé sur la couverture nuageuse et pluie
          Text(
            _weather!.weatherEmoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 20),
          // Température actuelle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _weather!.currentTemp.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              const Text(
                '°C',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Température ressentie
          Text(
            'Ressenti ${_weather!.apparentTemp.toStringAsFixed(1)}°C',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          // Températures min et max du jour
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Icon(Icons.arrow_upward, color: Colors.white70, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    '${_weather!.maxTemp.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Max',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Container(
                height: 50,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              Column(
                children: [
                  const Icon(Icons.arrow_downward, color: Colors.white70, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    '${_weather!.minTemp.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Min',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Grille des informations météo détaillées (humidité, vent, pression...)
  Widget _buildWeatherGrid() {
    if (_weather == null) return const SizedBox();

    return Column(
      children: [
        // Ligne 1: Humidité et Pluie
        Row(
          children: [
            Expanded(
              child: WeatherInfoCard(
                icon: Icons.water_drop,
                title: 'Humidité',
                value: _weather!.humidity.toStringAsFixed(0),
                unit: '%',
                iconColor: Colors.lightBlue.shade200,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WeatherInfoCard(
                icon: Icons.umbrella,
                title: 'Pluie',
                value: _weather!.precipitation.toStringAsFixed(1),
                unit: 'mm',
                iconColor: Colors.blue.shade300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Ligne 2: Probabilité de pluie et Vent
        Row(
          children: [
            Expanded(
              child: WeatherInfoCard(
                icon: Icons.cloud,
                title: 'Probabilité',
                value: _weather!.precipProbability.toString(),
                unit: '%',
                iconColor: Colors.grey.shade300,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WeatherInfoCard(
                icon: Icons.air,
                title: 'Vent',
                value: _weather!.windSpeed.toStringAsFixed(1),
                unit: 'km/h',
                iconColor: Colors.cyan.shade200,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Ligne 3: Pression atmosphérique et UV Index
        Row(
          children: [
            Expanded(
              child: WeatherInfoCard(
                icon: Icons.speed,
                title: 'Pression',
                value: _weather!.pressure.toStringAsFixed(0),
                unit: 'hPa',
                iconColor: Colors.orange.shade200,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WeatherInfoCard(
                icon: Icons.wb_sunny,
                title: 'UV Index',
                value: _weather!.uvIndex.toStringAsFixed(1),
                iconColor: Colors.amber.shade300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Ligne 4: Visibilité et Couverture nuageuse
        Row(
          children: [
            Expanded(
              child: WeatherInfoCard(
                icon: Icons.visibility,
                title: 'Visibilité',
                value: _weather!.visibility.toStringAsFixed(1),
                unit: 'km',
                iconColor: Colors.purple.shade200,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WeatherInfoCard(
                icon: Icons.cloud_outlined,
                title: 'Couverture',
                value: _weather!.cloudCover.toString(),
                unit: '%',
                iconColor: Colors.indigo.shade200,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
