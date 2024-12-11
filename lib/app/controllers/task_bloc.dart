/// The `TaskBloc` class is a BLoC (Business Logic Component) that manages the state and events
/// related to tasks in the application. It extends `HydratedBloc` to provide automatic state
/// persistence.
///
/// This BLoC handles the following events:
/// - `AddTask`: Adds a new task to the local storage and attempts to sync it with Firebase.
/// - `UpdateTask`: Updates an existing task in the local storage and attempts to sync the update with Firebase.
/// - `DeleteTask`: Deletes a task from the local storage and attempts to sync the deletion with Firebase.
/// - `SyncTasks`: Syncs all tasks that need synchronization with Firebase.
/// - `LoadTasks`: Loads tasks from the local storage.
/// - `ChangeFilter`: Changes the current filter applied to the task list.
///
/// The BLoC also listens for connectivity changes and attempts to sync tasks when the connection is restored.
///
/// The state of the BLoC is persisted using the `fromJson` and `toJson` methods, which serialize and
/// deserialize the state to and from JSON format.
///
/// The `TaskBloc` uses the following dependencies:
/// - `TaskRepository`: A repository for managing tasks.
/// - `ConnectivityHelper`: A helper class for checking connectivity status.
/// - `ConsoleLogger`: A logger for logging messages to the console.
import 'dart:async';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/models/task_model.dart';
import '../data/repos/task_repository.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/connectivity_helper.dart';
import '../presentation/screens/task_list_screen.dart';
import '../../core/services/ConsoleLogger.dart';
part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends HydratedBloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository = getIt<TaskRepository>();
  final ConnectivityHelper _connectivityHelper = getIt<ConnectivityHelper>();
  StreamSubscription? _connectivitySubscription;

  TaskBloc() : super(TaskInitial()) {
    _connectivitySubscription =
        _connectivityHelper.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        ConsoleLogger.info(
            'Connectivity', 'Connection restored. Starting sync...');
        add(SyncTasks());
      } else {
        ConsoleLogger.warning(
            'Connectivity', 'Connection lost. Working offline.');
      }
    });

    on<AddTask>((event, emit) async {
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        // Always add to local storage first
        final newTask = event.task.copyWith(needsSync: true);
        final updatedTasks = [...currentState.tasks, newTask];
        emit(TasksLoaded(updatedTasks));
        ConsoleLogger.success(
            'Local Storage', 'Task added locally: ${newTask.title}');

        // Try to sync if online
        final hasConnection = await _connectivityHelper.hasConnection();
        if (hasConnection) {
          try {
            await _taskRepository.addTask(newTask);
            ConsoleLogger.success(
                'Firebase', 'Task synced to Firebase: ${newTask.title}');
            // Update the task's sync status after successful sync
            final syncedTask = newTask.copyWith(needsSync: false);
            final updatedTasksAfterSync = updatedTasks.map((task) {
              return task.id == syncedTask.id ? syncedTask : task;
            }).toList();
            emit(TasksLoaded(updatedTasksAfterSync));
          } catch (e) {
            ConsoleLogger.error(
                'Firebase', 'Failed to sync task: ${e.toString()}');
          }
        } else {
          ConsoleLogger.warning(
              'Sync', 'Task will be synced when online: ${newTask.title}');
        }
      }
    });

    on<UpdateTask>((event, emit) async {
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        final updatedTask = event.task.copyWith(needsSync: true);
        final updatedTasks = currentState.tasks.map((task) {
          return task.id == updatedTask.id ? updatedTask : task;
        }).toList();

        emit(TasksLoaded(updatedTasks));
        ConsoleLogger.success(
            'Local Storage', 'Task updated locally: ${updatedTask.title}');

        final hasConnection = await _connectivityHelper.hasConnection();
        if (hasConnection) {
          try {
            await _taskRepository.updateTask(updatedTask);
            ConsoleLogger.success('Firebase',
                'Task update synced to Firebase: ${updatedTask.title}');
            final syncedTask = updatedTask.copyWith(needsSync: false);
            final syncedTasks = updatedTasks.map((task) {
              return task.id == syncedTask.id ? syncedTask : task;
            }).toList();
            emit(TasksLoaded(syncedTasks));
          } catch (e) {
            ConsoleLogger.error(
                'Firebase', 'Failed to sync task update: ${e.toString()}');
          }
        } else {
          ConsoleLogger.warning('Sync',
              'Task update will be synced when online: ${updatedTask.title}');
        }
      }
    });

    on<DeleteTask>((event, emit) async {
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        final taskToDelete =
            currentState.tasks.firstWhere((task) => task.id == event.taskId);
        final updatedTasks = currentState.tasks
            .where((task) => task.id != event.taskId)
            .toList();

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
    });

    on<SyncTasks>((event, emit) async {
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
    });

    on<LoadTasks>((event, emit) {
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        emit(TasksLoaded(currentState.tasks));
      } else {
        emit(TasksLoaded([]));
      }
    });

    on<ChangeFilter>((event, emit) {
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        emit(currentState.copyWith(currentFilter: event.filter));
      }
    });
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
