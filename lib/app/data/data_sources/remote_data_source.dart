import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/cache_helper.dart';

class RemoteDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _cacheHelper = getIt<CacheHelper>();

  // Add this getter
  User? get currentUser => _auth.currentUser;

  // Add this stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInAnonymously() async {
    try {
      // Check if we have a cached user
      final cachedUserId = _cacheHelper.getUserId();
      if (cachedUserId != null) {
        // User exists in cache, no need to sign in again
        return;
      }

      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Anonymous sign in failed: No user returned');
      }

      // Save the new user ID to cache
      await _cacheHelper.saveUserId(user.uid);
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Exception: ${e.message}');
      throw Exception(
          'Failed to sign in anonymously: [${e.code}] ${e.message}');
    } catch (e) {
      debugPrint('General Exception: $e');
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _cacheHelper.clearUser();
  }

  Future<void> addTask(TaskModel task) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .doc(task.id)
            .set(task.toJson());
      }
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .doc(task.id)
            .update(task.toJson());
      }
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .doc(taskId)
            .delete();
      }
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  Stream<List<TaskModel>> getAllTasks() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromJson(doc.data()))
              .toList());
    }
    return Stream.value([]);
  }
}
