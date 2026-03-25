import 'package:flutter/material.dart';
import 'dart:io';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MinistryOfTruthApp());
}

class MinistryOfTruthApp extends StatelessWidget {
  const MinistryOfTruthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ministry of Truth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
