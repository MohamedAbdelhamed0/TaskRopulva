/// Repository interface for managing tasks and authentication.
///
/// This abstract class defines the contract for implementations that handle
/// task CRUD operations and user authentication states.
///
/// The repository provides:
/// * User authentication state management
/// * Anonymous sign-in capabilities
/// * Task creation, updating, and deletion
/// * Real-time task list streaming
///
/// Example:
/// ```dart
/// final repo = TaskRepositoryImpl();
/// await repo.signInAnonymously();
/// await repo.addTask(newTask);
/// repo.getAllTasks().listen((tasks) {
///   // Handle updated task list
/// });
/// ```
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

abstract class TaskRepository {
  User? get currentUser;
  Stream<User?> get authStateChanges;

  Future<void> signInAnonymously();
  Future<void> signOut();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Stream<List<TaskModel>> getAllTasks();
}
