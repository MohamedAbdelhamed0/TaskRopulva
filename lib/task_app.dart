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
