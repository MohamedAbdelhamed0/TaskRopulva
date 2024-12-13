/// A Flutter application for managing tasks.
///
/// This application uses BLoC pattern for state management and Firebase for authentication.
/// The app includes features such as:
/// * Anonymous authentication
/// * Task management
/// * Fixed text scaling
/// * Custom theme implementation
///
/// The app structure consists of two main widgets:
/// * [TaskApp]: The root widget that sets up the application configuration
/// * [AuthStateHandler]: Manages authentication state and user sessions
///
/// The [TaskApp] widget initializes:
/// * BLoC provider for task management
/// * Material app configuration
/// * Global scaffold messenger
/// * Theme settings
/// * Fixed text scaling
///
/// The [AuthStateHandler] widget:
/// * Listens to authentication state changes
/// * Handles anonymous sign-in
/// * Displays splash screen during authentication
///
/// This application uses dependency injection through GetIt service locator
/// for managing dependencies across the app.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/controllers/task_bloc.dart';
import 'app/data/repos/task_repository.dart';
import 'core/screens/splash_screen.dart';
import 'core/services/service_locator.dart';
import 'core/services/snackbar_service.dart';
import 'core/themes/themes.dart';

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc()..add(LoadTasks()),
      child: MaterialApp(
        scaffoldMessengerKey: SnackBarService.messengerKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthStateHandler(),
        builder: _buildWithFixedTextScale,
      ),
    );
  }

  Widget _buildWithFixedTextScale(BuildContext context, Widget? child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: child!,
    );
  }
}

class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: getIt<TaskRepository>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasData) {
          return const SplashScreen();
        }
        getIt<TaskRepository>().signInAnonymously();

        return const SplashScreen();
      },
    );
  }
}
