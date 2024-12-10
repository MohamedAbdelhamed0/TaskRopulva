import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'app/data/data_sources/remote_data_source.dart';
import 'core/screens/splash_screen.dart';
import 'core/services/window_helper.dart';
import 'core/themes/themes.dart';
import 'firebase_options.dart';
import 'core/services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: StreamBuilder<User?>(
        // Use GetIt to get RemoteDataSource instance
        stream: getIt<RemoteDataSource>().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            return const SplashScreen(); // Or your main screen
          }

          // If no user, try to sign in anonymously
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
    );
  }
}
