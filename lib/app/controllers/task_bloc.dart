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

library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../core/services/ConsoleLogger.dart';
import '../../core/services/connectivity_helper.dart';
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

  void _handleSyncTasks(SyncTasks event, Emitter<TaskState> emit) async {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      final tasks = currentState.tasks;
      final unSyncedTasks = tasks.where((t) => t.needsSync).toList();

      if (unSyncedTasks.isNotEmpty) {
        ConsoleLogger.info(
            'Sync', 'Starting sync of ${unSyncedTasks.length} tasks...');

        for (var task in unSyncedTasks) {
          try {
            await _taskRepository.updateTask(task);
            task.needsSync = false;
            ConsoleLogger.success(
                'Sync', 'Successfully synced task: ${task.title}');
          } catch (e) {
            ConsoleLogger.error(
                'Sync', 'Failed to sync task ${task.title}: ${e.toString()}');
          }
        }

        emit(TasksLoaded(tasks));
        ConsoleLogger.success('Sync', 'Sync completed');
      } else {
        ConsoleLogger.info('Sync', 'No tasks need syncing');
      }
    }
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
      emit(currentState.copyWith(currentFilter: event.filter));
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
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
