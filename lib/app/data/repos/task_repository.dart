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
