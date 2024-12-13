/// Main entry point and initialization functions for the Task App.
///
/// The initialization process includes:
/// * Setting up HydratedBloc storage for state persistence
/// * Initializing Firebase services with default platform options
/// * Setting up dependency injection and service locator
/// * Configuring window properties (if applicable)
/// * Handling anonymous authentication for task repository
///
/// The app initialization is handled in discrete steps with proper error handling:
/// 1. Storage initialization via [_initializeStorage]
/// 2. Firebase setup through [_initializeFirebase]
/// 3. Services configuration using [_initializeServices]
/// 4. Window setup via [WindowHelper.initializeWindow]
///
/// If any initialization step fails, the error is handled by [_handleInitializationError],
/// which will print the error in debug mode and re-throw it.
///
/// Example:
/// ```dart
/// void main() async {
///   await initializeApp();
///   runApp(const TaskApp());
/// }
/// ```
///
/// Throws an exception if initialization fails.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:task_ropulva_todo_app/app/data/repos/task_repository.dart';
import 'package:task_ropulva_todo_app/task_app.dart';

import 'core/services/service_locator.dart';
import 'core/services/window_helper.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await initializeApp();
  runApp(const TaskApp());
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
