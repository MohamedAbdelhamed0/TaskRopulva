import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app/controllers/task_bloc.dart';
import 'app/data/data_sources/remote_data_source.dart';
import 'core/screens/splash_screen.dart';
import 'core/services/window_helper.dart';
import 'core/themes/themes.dart';
import 'firebase_options.dart';
import 'core/services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize HydratedStorage
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory(),
    );

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await setupServiceLocator();
    final remoteDataSource = getIt<RemoteDataSource>();

    // Will check cache before creating new anonymous user
    if (remoteDataSource.currentUser == null) {
      await remoteDataSource.signInAnonymously();
    }

    await WindowHelper.initializeWindow();
  } catch (e) {
    print('Error initializing app: $e');
    rethrow;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc()..add(LoadTasks()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: StreamBuilder<User?>(
          stream: getIt<RemoteDataSource>().authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (snapshot.hasData) {
              return const SplashScreen();
            }

            getIt<RemoteDataSource>().signInAnonymously();
            return const SplashScreen();
          },
        ),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
      ),
    );
  }
}
