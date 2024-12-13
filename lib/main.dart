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
