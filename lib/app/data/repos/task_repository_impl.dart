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

class TaskRepositoryImpl implements TaskRepository {
  final RemoteDataSource _remoteDataSource;

  TaskRepositoryImpl(this._remoteDataSource);

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  Future<void> signInAnonymously() async {
    try {
      await _remoteDataSource.signInAnonymously();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addTask(TaskModel task) async {
    try {
      await _remoteDataSource.addTask(task);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await _remoteDataSource.updateTask(task);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _remoteDataSource.deleteTask(taskId);
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
