import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Addville extends StatefulWidget {
  final Function() onVilleAdded;

  const Addville({Key? key, required this.onVilleAdded}) : super(key: key);

  @override
  _AddvilleState createState() => _AddvilleState();
}

class _AddvilleState extends State<Addville> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _addVille(BuildContext context) async {
    final ville = _controller.text.trim();
    if (ville.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> villes = prefs.getStringList('villes') ?? [];

    if (!villes.contains(ville)) {
      villes.add(ville);
      bool success = await prefs.setStringList('villes', villes);
      print('Sauvegarde de la ville "$ville": $success');

      // Vérification que la sauvegarde a bien fonctionné
      await Future.delayed(Duration(milliseconds: 100));
      List<String> verification = prefs.getStringList('villes') ?? [];
      print('Villes sauvegardées: $verification');

      widget.onVilleAdded();
    }

    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ajouter une ville',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Nom de la ville',
              prefixIcon: Icon(Icons.location_city, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _addVille(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 2,
            ),
            child: Text(
              'Ajouter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
