import 'package:flutter/material.dart';

import 'core/themes/themes.dart';
import 'test_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: const TestScreen(),
    );
  }
}
