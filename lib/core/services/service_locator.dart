import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/data/data_sources/remote_data_source.dart';
import '../../app/data/repos/task_repository.dart';
import '../../app/data/repos/task_repository_impl.dart';
import '../services/connectivity_helper.dart';
import '../services/cache_helper.dart';
import 'calendar_service.dart';

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

  // Register TaskRepository
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(getIt<RemoteDataSource>()),
  );

  // Register CalendarService
  getIt.registerLazySingleton(() => CalendarService());

  // Initialize required services
}
