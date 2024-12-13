import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_ropulva_todo_app/app/presentation/widgets/show_task_dialog.dart';

import '../../../core/enums.dart';
import '../../../core/services/responsive_helper.dart';
import '../../controllers/task_bloc.dart';
import '../../data/models/task_model.dart';
import 'add_buttom_windos.dart';
import 'filter_chips.dart';
import 'header_section.dart';
import 'task_list.dart';

class TaskListContent extends StatelessWidget {
  final TasksLoaded state;

  const TaskListContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final tasks = state.tasks;
    final filteredTasks = _getFilteredTasks(tasks, state.currentFilter);

    bool isPC = ResponsiveHelper.isPC(context);

    return Padding(
      padding: ResponsiveHelper.getPadding(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeaderSection().animate().slideX(duration: 500.ms),
                  FilterChips(tasks: tasks, currentFilter: state.currentFilter),
                ].animate(interval: 500.ms).slideX(duration: 700.ms),
              ),
            ),
            if (isPC)
              Expanded(
                flex: 0,
                child: AddButtonWindows(
                  onPressed: () => showTaskDialog(context),
                ),
              ),
          ],
        ),
        TaskList(
          filteredTasks: filteredTasks,
          currentFilter: state.currentFilter,
          totalTasks: tasks.length,
          unfinishedTasks: tasks.where((t) => !t.isDone).length,
        ),
        if (!isPC) const SizedBox(height: 60),
      ]),
    );
  }

  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks, TaskFilter filter) {
    return switch (filter) {
      TaskFilter.all => tasks,
      TaskFilter.active => tasks.where((task) => !task.isDone).toList(),
      TaskFilter.completed => tasks.where((task) => task.isDone).toList(),
    };
  }
}
