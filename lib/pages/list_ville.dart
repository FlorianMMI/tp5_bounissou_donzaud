import 'package:flutter/material.dart';
import 'package:tp5_bounissou_donzaud/widgets/Ville.dart';
import 'package:tp5_bounissou_donzaud/services/Weather_Data.dart';
import 'package:tp5_bounissou_donzaud/widgets/addville.dart';

class ListVille extends StatefulWidget {

  @override
  State<ListVille> createState() => _ListVilleState();
}

class _ListVilleState extends State<ListVille> {

  String temp = "";
  bool isLoading = false;
  String errorMessage = "";
  Map<String, String> villes = {"Localisation" : ""};
  

  @override
  void initState() {
    super.initState();
    _loadTemp();
  }

  Future<void> _loadTemp() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    try {
      WeatherService weatherService = WeatherService();
      final temperature = await weatherService.fetchTempData("Limoges");
      setState(() {
        temp = temperature;
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text('Page Ville'),
                Ville(name: 'Localisation', temp: temp),
              ],
            ),
            
            Container(
              width: double.infinity,
              child: ElevatedButton(
                  
                  style: ElevatedButton.styleFrom(
                  elevation: 0,
                   foregroundColor: Colors.black,
                   
                  ),
                  onPressed: () {
                    showDialog(context: context, builder: (context) {
                      return AlertDialog(
                        content: Addville(),
                      );
                    });
                  }, 
                  child: 
                  Container(
              
                  margin: EdgeInsets.all(8.0),
                  
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                  
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    Text("Ajouter une ville"),
                  ],),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}