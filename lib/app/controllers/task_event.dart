/// Events that can occur in the Task management system.
///
/// This class serves as a base for all task-related events in the application.
/// Each event represents a specific action that can be performed on tasks.

/// Represents an event to add a new task to the system.
/// [task] contains the task model data to be added.

/// Represents an event to update an existing task in the system.
/// [task] contains the updated task model data.

/// Represents an event to delete a task from the system.
/// [taskId] is the unique identifier of the task to be deleted.

/// Represents an event to load all tasks from the storage.

/// Represents an event to synchronize tasks with external storage or service.

/// Represents an event to change the current task filter.
/// [filter] specifies the new filter criteria to be applied.
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

class ChangeFilter extends TaskEvent {
  final TaskFilter filter;
  ChangeFilter(this.filter);
}
