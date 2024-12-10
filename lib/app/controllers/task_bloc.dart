import 'dart:async';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/models/task_model.dart';
import '../data/data_sources/remote_data_source.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/connectivity_helper.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends HydratedBloc<TaskEvent, TaskState> {
  final RemoteDataSource _remoteDataSource = getIt<RemoteDataSource>();
  final ConnectivityHelper _connectivityHelper = getIt<ConnectivityHelper>();
  StreamSubscription? _connectivitySubscription;

  TaskBloc() : super(TaskInitial()) {
    _connectivitySubscription =
        _connectivityHelper.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        add(SyncTasks());
      }
    });

    on<AddTask>((event, emit) async {
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        // Always add to local storage first
        final newTask = event.task.copyWith(needsSync: true);
        final updatedTasks = [...currentState.tasks, newTask];
        emit(TasksLoaded(updatedTasks));

        // Try to sync if online
        final hasConnection = await _connectivityHelper.hasConnection();
        if (hasConnection) {
          try {
            await _remoteDataSource.addTask(newTask);
            // Update the task's sync status after successful sync
            final syncedTask = newTask.copyWith(needsSync: false);
            add(UpdateTask(syncedTask));
          } catch (e) {
            print('Failed to sync task: $e');
            // Task remains marked as needing sync
          }
        }
      }
    });

    on<UpdateTask>((event, emit) async {
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        // Immediately update local state
        final updatedTask = event.task.copyWith(needsSync: true);
        final updatedTasks = currentState.tasks.map((task) {
          return task.id == updatedTask.id ? updatedTask : task;
        }).toList();

        // Emit the update immediately
        emit(TasksLoaded(updatedTasks));

        // Try to sync if online
        final hasConnection = await _connectivityHelper.hasConnection();
        if (hasConnection) {
          try {
            await _remoteDataSource.updateTask(updatedTask);
            // Update sync status after successful sync
            final syncedTask = updatedTask.copyWith(needsSync: false);
            final syncedTasks = updatedTasks.map((task) {
              return task.id == syncedTask.id ? syncedTask : task;
            }).toList();
            emit(TasksLoaded(syncedTasks));
          } catch (e) {
            print('Failed to sync task update: $e');
            // Task remains marked as needing sync
          }
        }
      }
    });

    on<DeleteTask>((event, emit) async {
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        // Immediately remove from local state
        final updatedTasks = currentState.tasks
            .where((task) => task.id != event.taskId)
            .toList();

        // Emit the deletion immediately
        emit(TasksLoaded(updatedTasks));

        // Try to sync if online
        final hasConnection = await _connectivityHelper.hasConnection();
        if (hasConnection) {
          try {
            await _remoteDataSource.deleteTask(event.taskId);
          } catch (e) {
            print('Failed to sync task deletion: $e');
            // If deletion fails online, we could potentially add the task back
            // or mark it for deletion later
          }
        }
      }
    });

    on<SyncTasks>((event, emit) async {
      if (state is TasksLoaded) {
        final currentState = state as TasksLoaded;
        final tasks = currentState.tasks;

        for (var task in tasks.where((t) => t.needsSync)) {
          await _remoteDataSource.updateTask(task);
          task.needsSync = false;
        }

        emit(TasksLoaded(tasks));
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
      return TasksLoaded(tasks);
    } catch (_) {
      return TasksLoaded([]);
    }
  }

  @override
  Map<String, dynamic>? toJson(TaskState state) {
    if (state is TasksLoaded) {
      return {
        'tasks': state.tasks.map((task) => task.toJson()).toList(),
      };
    }
    return null;
  }
}
