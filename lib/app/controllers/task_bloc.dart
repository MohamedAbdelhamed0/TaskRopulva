/// A BLoC (Business Logic Component) that manages the state of tasks in the application.
///
/// This BLoC handles task operations like adding, updating, deleting, and syncing tasks
/// with both local storage and Firebase. It also manages connectivity status and task filtering.
///
/// Features:
/// * Persists state using HydratedBloc
/// * Handles offline/online synchronization
/// * Manages task filtering
/// * Provides real-time connectivity monitoring
///
/// Example:
/// ```dart
/// final taskBloc = TaskBloc();
/// taskBloc.add(AddTask(newTask));
/// taskBloc.add(UpdateTask(existingTask));
/// ```
///
/// The bloc maintains its state through [TaskState] and responds to [TaskEvent]s.
/// It uses [TaskRepository] for data persistence and [ConnectivityHelper] for
/// network connectivity monitoring.
///
/// When offline, operations are stored locally and synced when connectivity is restored.
/// All operations are logged using [ConsoleLogger] for debugging purposes.
///
/// The BLoC also includes:
/// * Retry mechanism for failed operations with a maximum of 3 attempts.
/// * Throttling to prevent excessive operations within a short period.
/// * Caching of tasks to optimize performance.
/// * Batch processing for syncing tasks to Firebase.
/// * Error handling and recovery mechanisms.
///
/// The BLoC listens to connectivity changes and triggers synchronization when the connection is restored.
/// It also supports task filtering and maintains the current filter state.
///
/// The state is persisted using HydratedBloc, allowing the BLoC to restore its state upon app restart.

library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../core/services/connectivity_helper.dart';
import '../../core/services/console_logger.dart';
import '../../core/services/service_locator.dart';
import '../data/models/task_model.dart';
import '../data/repos/task_repository.dart';
import '../presentation/screens/task_list_screen.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends HydratedBloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository = getIt<TaskRepository>();
  final ConnectivityHelper _connectivityHelper = getIt<ConnectivityHelper>();
  StreamSubscription? _connectivitySubscription;

  // Add new fields for retry and throttling
  static const int maxRetryAttempts = 3;
  final _throttle = Throttle(const Duration(seconds: 2));
  final _cache = <String, TaskModel>{};

  TaskBloc() : super(TaskInitial()) {
    _initializeConnectivityListener();
    _registerEventHandlers();
  }

  void _initializeConnectivityListener() {
    _connectivitySubscription = _connectivityHelper.onConnectivityChanged
        .listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      ConsoleLogger.info(
          'Connectivity', 'Connection restored. Starting sync...');
      add(SyncTasks());
    } else {
      ConsoleLogger.warning(
          'Connectivity', 'Connection lost. Working offline.');
    }
  }

  void _registerEventHandlers() {
    on<AddTask>(_handleAddTask);
    on<UpdateTask>(_handleUpdateTask);
    on<DeleteTask>(_handleDeleteTask);
    on<SyncTasks>(_handleSyncTasks);
    on<LoadTasks>(_handleLoadTasks);
    on<ChangeFilter>(_handleChangeFilter);
  }

  Future<void> _handleAddTask(AddTask event, Emitter<TaskState> emit) async {
    await _throttle.run(() async {
      if (state is! TasksLoaded) return;

      final currentState = state as TasksLoaded;
      final newTask = event.task.copyWith(needsSync: true);
      final updatedTasks = [...currentState.tasks, newTask];

      // Update local state
      emit(TasksLoaded(updatedTasks));
      ConsoleLogger.success(
          'Local Storage', 'Task added locally: ${newTask.title}');

      // Sync with Firebase if online
      await _syncTaskWithFirebase(
        newTask,
        updatedTasks,
        emit,
        syncOperation: () => _taskRepository.addTask(newTask),
        operationType: 'add',
      );
      _cacheTask(newTask);
    });
  }

  Future<void> _handleUpdateTask(
      UpdateTask event, Emitter<TaskState> emit) async {
    if (state is! TasksLoaded) return;

    final currentState = state as TasksLoaded;
    final updatedTask = event.task.copyWith(needsSync: true);
    final updatedTasks = _updateTaskInList(currentState.tasks, updatedTask);

    // Update local state
    emit(TasksLoaded(updatedTasks));
    ConsoleLogger.success(
        'Local Storage', 'Task updated locally: ${updatedTask.title}');

    // Sync with Firebase if online
    await _syncTaskWithFirebase(
      updatedTask,
      updatedTasks,
      emit,
      syncOperation: () => _taskRepository.updateTask(updatedTask),
      operationType: 'update',
    );
  }

  List<TaskModel> _updateTaskInList(
      List<TaskModel> tasks, TaskModel updatedTask) {
    return tasks
        .map((task) => task.id == updatedTask.id ? updatedTask : task)
        .toList();
  }

  Future<void> _syncTaskWithFirebase(
    TaskModel task,
    List<TaskModel> tasks,
    Emitter<TaskState> emit, {
    required Future<void> Function() syncOperation,
    required String operationType,
  }) async {
    if (!await _connectivityHelper.hasConnection()) {
      ConsoleLogger.warning('Sync',
          'Task $operationType will be synced when online: ${task.title}');
      return;
    }

    try {
      await syncOperation();
      ConsoleLogger.success(
          'Firebase', 'Task $operationType synced to Firebase: ${task.title}');

      final syncedTask = task.copyWith(needsSync: false);
      final syncedTasks = _updateTaskInList(tasks, syncedTask);
      emit(TasksLoaded(syncedTasks));
    } catch (e) {
      ConsoleLogger.error(
          'Firebase', 'Failed to sync task $operationType: ${e.toString()}');
    }
  }

  void _handleDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final taskToDelete =
          currentState.tasks.firstWhere((task) => task.id == event.taskId);
      final updatedTasks =
          currentState.tasks.where((task) => task.id != event.taskId).toList();

      emit(TasksLoaded(updatedTasks));
      ConsoleLogger.success(
          'Local Storage', 'Task deleted locally: ${taskToDelete.title}');

      final hasConnection = await _connectivityHelper.hasConnection();
      if (hasConnection) {
        try {
          await _taskRepository.deleteTask(event.taskId);
          ConsoleLogger.success('Firebase',
              'Task deletion synced to Firebase: ${taskToDelete.title}');
        } catch (e) {
          ConsoleLogger.error(
              'Firebase', 'Failed to sync task deletion: ${e.toString()}');
        }
      } else {
        ConsoleLogger.warning('Sync',
            'Task deletion will be synced when online: ${taskToDelete.title}');
      }
    }
  }

  // Modified sync method with batch processing
  Future<void> _handleSyncTasks(
      SyncTasks event, Emitter<TaskState> emit) async {
    if (state is! TasksLoaded) return;

    final currentState = state as TasksLoaded;
    final unSyncedTasks = currentState.tasks.where((t) => t.needsSync).toList();

    if (unSyncedTasks.isEmpty) {
      ConsoleLogger.info('Sync', 'No tasks need syncing');
      return;
    }

    ConsoleLogger.info(
        'Sync', 'Starting batch sync of ${unSyncedTasks.length} tasks...');

    // Process in batches of 5
    for (var i = 0; i < unSyncedTasks.length; i += 5) {
      final batch = unSyncedTasks.skip(i).take(5);
      await Future.wait(
        batch.map((task) => _syncSingleTask(task, emit)),
      );
    }

    emit(TasksLoaded(currentState.tasks));
    ConsoleLogger.success('Sync', 'Batch sync completed');
  }

  Future<void> _syncSingleTask(TaskModel task, Emitter<TaskState> emit) async {
    try {
      await _retryOperation(
        () => _taskRepository.updateTask(task),
        'sync',
        task.title,
      );
      task.needsSync = false;
      _cache[task.id] = task;
      ConsoleLogger.success('Sync', 'Successfully synced task: ${task.title}');
    } catch (e) {
      emit(TaskError(e.toString(), previousState: state));
      ConsoleLogger.error(
          'Sync', 'Failed to sync task ${task.title}: ${e.toString()}');
    }
  }

  // Add error recovery method
  Future<void> _retryOperation(
    Future<void> Function() operation,
    String operationType,
    String taskTitle,
  ) async {
    int attempts = 0;
    while (attempts < maxRetryAttempts) {
      try {
        await operation();
        return;
      } catch (e) {
        attempts++;
        ConsoleLogger.warning(
          'Retry',
          'Attempt $attempts failed for $operationType: $taskTitle',
        );
        await Future.delayed(Duration(seconds: attempts));
      }
    }
    throw MaxRetryExceededException('Failed after $maxRetryAttempts attempts');
  }

  // Add cache management
  TaskModel? _getCachedTask(String taskId) => _cache[taskId];

  void _cacheTask(TaskModel task) {
    _cache[task.id] = task;
  }

  void _handleLoadTasks(LoadTasks event, Emitter<TaskState> emit) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      emit(TasksLoaded(currentState.tasks));
    } else {
      emit(TasksLoaded([]));
    }
  }

  void _handleChangeFilter(ChangeFilter event, Emitter<TaskState> emit) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      emit(TasksLoaded(
        currentState.tasks,
        currentFilter: event.filter,
      ));
      ConsoleLogger.info('Filter', 'Changed to: ${event.filter.name}');
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _throttle.dispose();
    _cache.clear();
    return super.close();
  }

  @override
  TaskState? fromJson(Map<String, dynamic> json) {
    try {
      final tasks = (json['tasks'] as List)
          .map((task) => TaskModel.fromJson(task as Map<String, dynamic>))
          .toList();
      final filter = TaskFilter.values.firstWhere(
        (f) => f.name == (json['filter'] ?? 'all'),
        orElse: () => TaskFilter.all,
      );
      return TasksLoaded(tasks, currentFilter: filter);
    } catch (_) {
      return TasksLoaded([]);
    }
  }

  @override
  Map<String, dynamic>? toJson(TaskState state) {
    if (state is TasksLoaded) {
      return {
        'tasks': state.tasks.map((task) => task.toJson()).toList(),
        'filter': state.currentFilter.name,
      };
    }
    return null;
  }
}

// Add new utility classes
class Throttle {
  final Duration duration;
  Timer? _timer;

  Throttle(this.duration);

  Future<void> run(Future<void> Function() action) async {
    if (_timer?.isActive ?? false) return;

    await action();
    _timer = Timer(duration, () {});
  }

  void dispose() => _timer?.cancel();
}

class MaxRetryExceededException implements Exception {
  final String message;
  MaxRetryExceededException(this.message);
  @override
  String toString() => message;
}
