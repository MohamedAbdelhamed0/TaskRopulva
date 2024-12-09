

// final getIt = GetIt.instance;

// class ServiceLocator{

//   static void initApp(){
//     getIt.registerLazySingleton<RemoteDataSource>(() => RemoteDataSource());
//     getIt.registerLazySingleton<LocalDataSource>(() => LocalDataSource());
//     getIt.registerLazySingleton<TaskRepository>(() => TaskRepository(getIt(),getIt()));
//     getIt.registerLazySingleton<TasksBloc>(() => TasksBloc(getIt()));
//   }

// }