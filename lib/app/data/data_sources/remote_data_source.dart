import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

class RemoteDataSource {
  static const String _usersCollection = 'users';
  static const String _tasksCollection = 'tasks';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  RemoteDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception: ${e.message}');
      throw Exception('Authentication failed: [${e.code}] ${e.message}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Private helper methods

  CollectionReference _getUserTasksCollection() {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user found');

    return _firestore
        .collection(_usersCollection)
        .doc(user.uid)
        .collection(_tasksCollection);
  }

  List<TaskModel> _convertToTaskList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> _executeTaskOperation({
    required Future<void> Function() operation,
    required String errorMessage,
  }) async {
    try {
      if (currentUser == null) throw Exception('No authenticated user found');
      await operation();
    } catch (e) {
      throw Exception('$errorMessage: $e');
    }
  }

  Future<void> addTask(TaskModel task) async {
    await _executeTaskOperation(
      operation: () =>
          _getUserTasksCollection().doc(task.id).set(task.toJson()),
      errorMessage: 'Failed to add task',
    );
  }

  Future<void> updateTask(TaskModel task) async {
    await _executeTaskOperation(
      operation: () =>
          _getUserTasksCollection().doc(task.id).update(task.toJson()),
      errorMessage: 'Failed to update task',
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _executeTaskOperation(
      operation: () => _getUserTasksCollection().doc(taskId).delete(),
      errorMessage: 'Failed to delete task',
    );
  }

  Stream<List<TaskModel>> getAllTasks() {
    final user = currentUser;
    if (user == null) return Stream.value([]);

    return _getUserTasksCollection().snapshots().map(_convertToTaskList);
  }
}
