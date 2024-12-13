part of 'task_bloc.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TasksLoaded extends TaskState {
  final List<TaskModel> tasks;
  final TaskFilter currentFilter;

  TasksLoaded(
    this.tasks, {
    this.currentFilter = TaskFilter.all,
  });

  TasksLoaded copyWith({
    List<TaskModel>? tasks,
    TaskFilter? currentFilter,
  }) {
    return TasksLoaded(
      tasks ?? this.tasks,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }
}

class TaskError extends TaskState {
  final String message;
  final TaskState previousState;

  TaskError(this.message, {required this.previousState});

  List<Object?> get props => [message, previousState];
}
