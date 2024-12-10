part of 'task_bloc.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TasksLoaded extends TaskState {
  final List<TaskModel> tasks;
  TasksLoaded(this.tasks);
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}
