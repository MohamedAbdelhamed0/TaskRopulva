import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/enums.dart';
import '../../../core/services/responsive_helper.dart';
import '../../data/models/task_model.dart';
import 'empty_task_list.dart';
import 'task_list_item2.dart';

class TaskList extends StatelessWidget {
  final List<TaskModel> filteredTasks;
  final TaskFilter currentFilter;
  final int totalTasks;
  final int unfinishedTasks;

  const TaskList({
    required this.filteredTasks,
    required this.currentFilter,
    required this.totalTasks,
    required this.unfinishedTasks,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    ResponsiveHelper.getMaxWidth(context);
    final int crossAxisCount = ResponsiveHelper.isDesktop(context) ? 3 : 2;

    return Expanded(
      child: filteredTasks.isEmpty
          ? EmptyTaskList(
              currentFilter: currentFilter,
              totalTasks: totalTasks,
              unfinishedTasks: unfinishedTasks,
            )
          : isMobile
              ? ListView.separated(
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) => TaskListItem2(
                          task: filteredTasks[index])
                      .animate()
                      .slideX(duration: Duration(milliseconds: 200 * index)),
                )
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: (323 / 79), // Original mobile dimensions
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) => TaskListItem2(
                          task: filteredTasks[index])
                      .animate()
                      .slideX(duration: Duration(milliseconds: 200 * index)),
                ),
    );
  }
}
