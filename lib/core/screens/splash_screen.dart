import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_ropulva_todo_app/app/controllers/task_bloc.dart';
import 'package:task_ropulva_todo_app/app/presentation/screens/task_list_screen.dart';

import '../../test_screen.dart'; // Make sure to import TestScreen
import '../services/window_helper.dart';
import '../themes/colors.dart';
import '../widgets/connectivity_wrapper.dart';
import '../widgets/custom_window_frame.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to main screen after animations
    Future.delayed(const Duration(seconds: 4), () {
      // Increased to 4 seconds to accommodate all animations
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WindowHelper.isDesktopPlatform
              ? CustomWindowFrame(
                  title: 'Todo App',
                  child: ConnectivityWrapper(
                    child: const TaskListScreen(),
                  ),
                )
              : const TaskListScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
            )
                .animate()
                .scale(
                  duration: const Duration(seconds: 1),
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.2, 1.2),
                )
                .then()
                .scale(
                  duration: const Duration(seconds: 1),
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(1.0, 1.0),
                ),
            const SizedBox(height: 20),
            Text(
              'Todo App',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            )
                .animate()
                .fadeIn(delay: const Duration(seconds: 2))
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 20),
            Text(
              'By Mohamed Abdelhamed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            )
                .animate()
                .fadeIn(
                    delay: const Duration(
                        seconds: 2,
                        milliseconds: 500)) // Delayed slightly after first text
                .slideY(begin: 0.3, end: 0)
                .then()
                .shimmer(
                  // Added shimmer effect
                  duration: const Duration(seconds: 1),
                  color: Colors.white.withOpacity(0.5),
                ),
          ],
        ),
      ),
    );
  }
}
