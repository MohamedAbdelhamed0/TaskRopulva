part of 'task_bloc.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TasksLoaded extends TaskState {
  final List<TaskModel> tasks;
  final List<String> pendingDeleteIds;
  final List<TaskModel> pendingUpdates;
  final List<TaskModel> pendingAdds;
  final TaskFilter currentFilter;

  TasksLoaded(
    this.tasks, {
    this.pendingDeleteIds = const [],
    this.pendingUpdates = const [],
    this.pendingAdds = const [],
    this.currentFilter = TaskFilter.all,
  });

  TasksLoaded copyWith({
    List<TaskModel>? tasks,
    List<String>? pendingDeleteIds,
    List<TaskModel>? pendingUpdates,
    List<TaskModel>? pendingAdds,
    TaskFilter? currentFilter,
  }) {
    return TasksLoaded(
      tasks ?? this.tasks,
      pendingDeleteIds: pendingDeleteIds ?? this.pendingDeleteIds,
      pendingUpdates: pendingUpdates ?? this.pendingUpdates,
      pendingAdds: pendingAdds ?? this.pendingAdds,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}
