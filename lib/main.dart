import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/presentation/pages/splash_page.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'HRIS',

      theme: AppTheme.lightTheme,

      home: const SplashPage(),
    );
  }
}