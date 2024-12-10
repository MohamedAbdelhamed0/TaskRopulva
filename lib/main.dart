import 'package:flutter/material.dart';

import 'core/screens/splash_screen.dart'; // Add this import
import 'core/services/window_helper.dart';
import 'core/themes/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowHelper.initializeWindow();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(), // Change initial screen to SplashScreen
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
