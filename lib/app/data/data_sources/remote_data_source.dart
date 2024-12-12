/// A data source class that manages remote data operations using Firebase services.
///
/// This class handles:
/// * User authentication operations (anonymous sign-in and sign-out)
/// * CRUD operations for tasks using Firestore
/// * User session management with local caching
///
/// The class uses Firebase Authentication for user management and Firestore
/// for storing task data. It also integrates with [CacheHelper] for local
/// storage of user credentials.
///
/// Usage example:
/// ```dart
/// final remoteDataSource = RemoteDataSource();
/// await remoteDataSource.signInAnonymously();
/// await remoteDataSource.addTask(task);
/// final tasks = remoteDataSource.getAllTasks();
/// ```
///
/// Throws [Exception] if:
/// * Authentication operations fail
/// * CRUD operations are attempted without an authenticated user
/// * Firebase operations fail
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/cache_helper.dart';
import '../../../core/services/service_locator.dart';
import '../models/task_model.dart';

/// Handles all remote data operations for tasks and authentication.
class RemoteDataSource {
  static const String _usersCollection = 'users';
  static const String _tasksCollection = 'tasks';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final CacheHelper _cacheHelper;

  RemoteDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    CacheHelper? cacheHelper,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _cacheHelper = cacheHelper ?? getIt<CacheHelper>();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Authenticates user anonymously, using cached credentials if available.
  Future<void> signInAnonymously() async {
    try {
      if (await _isUserCached()) return;
      await _performAnonymousSignIn();
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  Future<bool> _isUserCached() async {
    return _cacheHelper.getUserId() != null;
  }

  Future<void> _performAnonymousSignIn() async {
    final userCredential = await _auth.signInAnonymously();
    final user = userCredential.user;

    if (user == null) {
      throw Exception('Anonymous sign in failed: No user returned');
    }
    await _cacheHelper.saveUserId(user.uid);
  }

  void _handleAuthError(FirebaseAuthException e) {
    debugPrint('Firebase Auth Exception: ${e.message}');
    throw Exception('Authentication failed: [${e.code}] ${e.message}');
  }

  /// Signs out the current user and clears cached data.
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _cacheHelper.clearUser(),
    ]);
  }

  /// CRUD Operations for Tasks

  /// Adds a new task to Firestore.
  Future<void> addTask(TaskModel task) async {
    await _executeTaskOperation(
      operation: () =>
          _getUserTasksCollection().doc(task.id).set(task.toJson()),
      errorMessage: 'Failed to add task',
    );
  }

  /// Updates an existing task in Firestore.
  Future<void> updateTask(TaskModel task) async {
    await _executeTaskOperation(
      operation: () =>
          _getUserTasksCollection().doc(task.id).update(task.toJson()),
      errorMessage: 'Failed to update task',
    );
  }

  /// Deletes a task from Firestore.
  Future<void> deleteTask(String taskId) async {
    await _executeTaskOperation(
      operation: () => _getUserTasksCollection().doc(taskId).delete(),
      errorMessage: 'Failed to delete task',
    );
  }

  /// Returns a stream of all tasks for the current user.
  Stream<List<TaskModel>> getAllTasks() {
    final user = currentUser;
    if (user == null) return Stream.value([]);

    return _getUserTasksCollection().snapshots().map(_convertToTaskList);
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
}
