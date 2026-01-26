import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Addville extends StatefulWidget {
  @override
  _AddvilleState createState() => _AddvilleState();
}

class _AddvilleState extends State<Addville> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _addVille(BuildContext context) async {
    final ville = _controller.text.trim();
    if (ville.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ville', ville);
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
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Ajouter une ville',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _addVille(context),
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}