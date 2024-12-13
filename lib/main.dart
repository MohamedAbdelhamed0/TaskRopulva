import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_ropulva_todo_app/app/data/repos/task_repository.dart';
import 'package:task_ropulva_todo_app/core/services/snackbar_service.dart';

import 'app/controllers/task_bloc.dart';
import 'core/screens/splash_screen.dart';
import 'core/services/service_locator.dart';
import 'core/services/window_helper.dart';
import 'core/themes/themes.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await initializeApp();
  runApp(const MyApp());
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _initializeStorage();
    await _initializeFirebase();
    await _initializeServices();
    await WindowHelper.initializeWindow();
  } catch (e) {
    _handleInitializationError(e);
  }
}

Future<void> _initializeStorage() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> _initializeServices() async {
  await setupServiceLocator();
  final taskRepository = getIt<TaskRepository>();
  if (taskRepository.currentUser == null) {
    await taskRepository.signInAnonymously();
  }
}

void _handleInitializationError(Object error) {
  if (kDebugMode) {
    print('Error initializing app: $error');
  }
  throw error;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
