import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tp5_bounissou_donzaud/pages/Main_Page.dart';
import 'package:tp5_bounissou_donzaud/pages/list_ville.dart';
import 'package:tp5_bounissou_donzaud/services/Weather_Data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Météo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}
