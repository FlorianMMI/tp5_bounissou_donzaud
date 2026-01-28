import 'package:flutter/material.dart';
import 'package:tp5_bounissou_donzaud/widgets/Ville.dart';
import 'package:tp5_bounissou_donzaud/services/weather_data.dart';
import 'package:tp5_bounissou_donzaud/widgets/addville.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      final localisationTemp = await weatherService.fetchTempData("Limoges");
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
      appBar: AppBar(
        title: Text('Choisir une ville'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(errorMessage, textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadVilles,
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(top: 16),
                    children: villes.entries.map((entry) {
                      return Ville(name: entry.key, temp: entry.value);
                    }).toList(),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      foregroundColor: Colors.blue,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Addville(onVilleAdded: _loadVilles),
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 28),
                        SizedBox(width: 8),
                        Text(
                          "Ajouter une ville",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
