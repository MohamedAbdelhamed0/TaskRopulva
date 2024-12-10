import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/data/data_sources/remote_data_source.dart';
import '../services/connectivity_helper.dart';
import '../services/cache_helper.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Services
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<CacheHelper>(CacheHelper(prefs));

  // Data sources
  getIt.registerLazySingleton<RemoteDataSource>(() => RemoteDataSource());

  // Connectivity
  getIt.registerLazySingleton<ConnectivityHelper>(() {
    final helper = ConnectivityHelper();
    helper.initialize();
    return helper;
  });

  // Initialize required services
}
