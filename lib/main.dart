import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'config/app_config.dart';

void main() {
  // Initialize app configuration
  AppConfig.initialize(environment: AppEnvironment.development);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Rental App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
