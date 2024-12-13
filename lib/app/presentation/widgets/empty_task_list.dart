import 'package:flutter/material.dart';

import '../../../core/enums.dart';
import '../../../core/themes/colors.dart';

class EmptyTaskList extends StatelessWidget {
  final TaskFilter currentFilter;
  final int totalTasks;
  final int unfinishedTasks;

  const EmptyTaskList({
    super.key,
    required this.currentFilter,
    required this.totalTasks,
    required this.unfinishedTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIcon(),
            size: 120,
            color: _getIconColor(context),
          ),
          const SizedBox(height: 24),
          Text(
            _getTitle(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _getMessage(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),
          // const SizedBox(height: 32),
          // FilledButton.icon(
          //   onPressed: () => showTaskDialog(context),
          //   icon: const Icon(Icons.add),
          //   label: Text(_getButtonText()),
          //   style: FilledButton.styleFrom(
          //     fixedSize: Size(MediaQuery.sizeOf(context).width / 2, 53),
          //     minimumSize: Size(MediaQuery.sizeOf(context).width / 2, 53),
          //     maximumSize: Size(MediaQuery.sizeOf(context).width / 2, 53),
          //     padding: const EdgeInsets.symmetric(
          //       horizontal: 24,
          //       vertical: 12,
          //     ),
          //     backgroundColor: _getButtonColor(context),
          //   ),
          // ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    return switch (currentFilter) {
      TaskFilter.all when totalTasks == 0 => Icons.add_task_rounded,
      TaskFilter.completed when totalTasks == 0 => Icons.checklist_rounded,
      TaskFilter.completed when unfinishedTasks > 0 =>
        Icons.pending_actions_rounded,
      TaskFilter.completed => Icons.celebration_rounded,
      TaskFilter.active when totalTasks == 0 => Icons.assignment_add,
      TaskFilter.active => Icons.task_alt_rounded,
      _ => Icons.task_outlined,
    };
  }

  Color _getIconColor(BuildContext context) {
    return switch (currentFilter) {
      TaskFilter.completed when totalTasks == 0 => Colors.grey,
      TaskFilter.completed when unfinishedTasks == 0 => MyColors.green,
      TaskFilter.active => Colors.orange,
      _ => Theme.of(context).colorScheme.primary.withOpacity(0.5),
    };
  }

  String _getTitle() {
    return switch (currentFilter) {
      TaskFilter.all when totalTasks == 0 => 'Start Your Journey',
      TaskFilter.completed when totalTasks == 0 => 'No Tasks to Complete',
      TaskFilter.completed when unfinishedTasks > 0 => 'Almost There!',
      TaskFilter.completed => 'Well Done!',
      TaskFilter.active when totalTasks == 0 => 'Ready to Begin?',
      TaskFilter.active => 'All Caught Up!',
      _ => 'No Tasks Yet',
    };
  }

  String _getMessage() {
    return switch (currentFilter) {
      TaskFilter.all when totalTasks == 0 =>
        'Create your first task and start\norganizing your life!',
      TaskFilter.completed when totalTasks == 0 =>
        'Try breaking down big tasks into\nsmaller, manageable steps to get started!',
      TaskFilter.completed when unfinishedTasks > 0 =>
        'You still have $unfinishedTasks task${unfinishedTasks > 1 ? 's' : ''} to complete.\nKeep going!',
      TaskFilter.completed =>
        'You\'ve completed all your tasks.\nTime to celebrate! 🎉',
      TaskFilter.active when totalTasks == 0 =>
        'Add some tasks and start\nmaking progress!',
      TaskFilter.active => 'All tasks are completed.\nYou\'re crushing it! 💪',
      _ => 'Create your first task and start\nbeing productive!',
    };
  }

  String _getButtonText() {
    return switch (currentFilter) {
      TaskFilter.all when totalTasks == 0 => 'Create First Task',
      TaskFilter.completed when totalTasks == 0 => 'Add Your First Task',
      TaskFilter.completed when unfinishedTasks > 0 => 'Add New Task',
      TaskFilter.completed => 'Add More Tasks',
      TaskFilter.active => 'Add New Task',
      _ => 'Add Task',
    };
  }

  Color _getButtonColor(BuildContext context) {
    return switch (currentFilter) {
      TaskFilter.completed when totalTasks == 0 => Colors.grey,
      TaskFilter.completed when unfinishedTasks == 0 => MyColors.green,
      TaskFilter.active => Colors.orange,
      _ => Theme.of(context).colorScheme.primary,
    };
  }
}
