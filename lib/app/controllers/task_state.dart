/// Represents different states of the Task management system.
///
/// This class hierarchy defines the possible states that the task-related
/// features can be in:
/// * [TaskInitial]: Initial state before any tasks are loaded
/// * [TasksLoaded]: State when tasks are successfully loaded
/// * [TaskError]: State when an error occurs during task operations
///
/// The states are used in conjunction with TaskBloc to manage the task data
/// and UI states throughout the application.

/// Represents the initial state of the task system.
/// This state is used when the task list has not been loaded yet.

/// Represents a state where tasks have been successfully loaded.
/// Contains the current list of tasks and the active filter setting.
///
/// Properties:
/// * [tasks] - List of TaskModel objects representing the current tasks
/// * [currentFilter] - Current filter setting for task visibility
///
/// Provides [copyWith] method for creating new instances with updated values
/// while maintaining immutability.

/// Represents an error state in the task system.
///
/// Properties:
/// * [message] - Description of the error that occurred
/// * [previousState] - The state before the error occurred, allowing for recovery
///
/// Implements [props] for equality comparison.
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
