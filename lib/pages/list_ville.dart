import 'package:flutter/material.dart';
import 'package:tp5_bounissou_donzaud/widgets/Ville.dart';
import 'package:tp5_bounissou_donzaud/services/weather_data.dart';
import 'package:tp5_bounissou_donzaud/widgets/addville.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tp5_bounissou_donzaud/widgets/glass_container.dart';
import 'dart:ui';

class ListVille extends StatefulWidget {
  @override
  State<ListVille> createState() => _ListVilleState();
}

class _ListVilleState extends State<ListVille> {
  bool isLoading = false;
  String errorMessage = "";
  Map<String, String> villes = {};

  @override
  void initState() {
    super.initState();
    _loadVilles();
  }

  Future<void> _loadVilles() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      WeatherService weatherService = WeatherService();

      // Instancier "Localisation" par défaut et récupérer la température
      Map<String, String> tempVilles = {};
      final localisationTemp = await weatherService.fetchTempData(
        "Limoges",
      );
      tempVilles["Localisation"] = localisationTemp;

      // Récupérer les villes depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      List<String> savedVilles = prefs.getStringList('villes') ?? [];
      

      // Charger la température pour chaque ville sauvegardée
      for (String ville in savedVilles) {
        
        try {
          final temp = await weatherService.fetchTempData(ville);
          tempVilles[ville] = temp;
          
        } catch (e) {
          
          String errorMsg = e.toString();
          if (errorMsg.contains('Impossible de trouver')) {
            tempVilles[ville] = "?";
          } else if (errorMsg.contains('Données météo incomplètes')) {
            tempVilles[ville] = "--";
          } else {
            tempVilles[ville] = "Err";
          }
        }
      }
      

      setState(() {
        villes = tempVilles;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors du chargement des données météo : $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Choisir une ville',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
              Colors.blue.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Chargement des villes...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : errorMessage.isNotEmpty
                  ? Center(
                      child: GlassContainer(
                        blur: 20,
                        opacity: 0.2,
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline, size: 60, color: Colors.white),
                            SizedBox(height: 20),
                            Text(
                              errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadVilles,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue.shade700,
                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Réessayer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
                            children: villes.entries.map((entry) {
                              return Ville(
                                name: entry.key,
                                temp: entry.value,
                              );
                            }).toList(),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20.0),
                          child: GlassContainer(
                            blur: 20,
                            opacity: 0.2,
                            padding: EdgeInsets.all(0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: Addville(onVilleAdded: _loadVilles),
                                      );
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 18),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 28,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "Ajouter une ville",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
