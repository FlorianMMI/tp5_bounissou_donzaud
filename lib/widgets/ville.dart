import 'package:flutter/material.dart';

class Ville extends StatelessWidget {

  final String name;
  final String temp;

  Ville({
    required this.name,
    required this.temp
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        
        border: Border.all(color: const Color.fromARGB(255, 116, 116, 116)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text('$temp °C'),
        ],
      ),
    );
  }

}