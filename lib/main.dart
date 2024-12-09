import 'package:flutter/material.dart';
import 'core/themes/themes.dart';
import 'test_screen.dart';
import 'core/widgets/custom_window_frame.dart';
import 'core/services/window_helper.dart';

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
      theme: AppTheme.lightTheme,
      home: WindowHelper.isDesktopPlatform
          ? const CustomWindowFrame(
              title: 'Todo App',
              child: TestScreen(),
            )
          : const TestScreen(),
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
