part of 'task_bloc.dart';

abstract class TaskEvent {}

class AddTask extends TaskEvent {
  final TaskModel task;
  AddTask(this.task);
}

class UpdateTask extends TaskEvent {
  final TaskModel task;
  UpdateTask(this.task);
}

class DeleteTask extends TaskEvent {
  final String taskId;
  DeleteTask(this.taskId);
}

class LoadTasks extends TaskEvent {}

class SyncTasks extends TaskEvent {}
