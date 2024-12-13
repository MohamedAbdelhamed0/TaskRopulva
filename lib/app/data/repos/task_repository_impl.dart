/// A concrete implementation of [TaskRepository] that manages task-related operations using remote data source.
///
/// This repository acts as a mediator between the data layer and the domain layer,
/// handling tasks and authentication operations through a [RemoteDataSource].
///
/// Key responsibilities include:
/// * Managing user authentication (anonymous sign-in and sign-out)
/// * Performing CRUD operations on tasks
/// * Streaming authentication state changes
/// * Providing access to current user information
///
/// All operations are delegated to the [RemoteDataSource] while handling potential errors.
/// In case of errors, they are propagated up the call stack using [rethrow].
import '../data_sources/remote_data_source.dart';
import '../models/task_model.dart';
import 'task_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/cache_helper.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/calendar_service.dart';

class TaskRepositoryImpl implements TaskRepository {
  final RemoteDataSource _remoteDataSource;
  final CacheHelper _cacheHelper;
  final CalendarService _calendarService;

  TaskRepositoryImpl(this._remoteDataSource)
      : _cacheHelper = getIt<CacheHelper>(),
        _calendarService = getIt<CalendarService>();

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  Future<void> signInAnonymously() async {
    try {
      if (await _isUserCached()) return;

      final credential = await _remoteDataSource.signInAnonymously();
      final user = credential.user;
      if (user != null) {
        await _cacheHelper.saveUserId(user.uid);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _isUserCached() async {
    return _cacheHelper.getUserId() != null;
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _remoteDataSource.signOut(),
        _cacheHelper.clearUser(),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addTask(TaskModel task) async {
    try {
      await _remoteDataSource.addTask(task);
      if (task.dueDate != null && _calendarService.isInitialized) {
        await _calendarService.addTaskToCalendar(task);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _remoteDataSource.updateTask(task);
      if (task.dueDate != null && _calendarService.isInitialized) {
        await _calendarService.updateTaskInCalendar(task);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _remoteDataSource.deleteTask(taskId);
      if (_calendarService.isInitialized) {
        await _calendarService.deleteTaskFromCalendar(taskId);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<List<TaskModel>> getAllTasks() {
    try {
      return _remoteDataSource.getAllTasks().handleError((error) {
        throw error;
      });
    } catch (e) {
      rethrow;
    }
  }
}
