/// A widget that displays a horizontal list of filter chips for task filtering.
///
/// The filter chips show different task categories (All, Done, Not Done) along with
/// the count of tasks in each category. The chips are animated using fade effects
/// when they appear.
///
/// Properties:
/// * [tasks] - List of TaskModel objects to be filtered
/// * [currentFilter] - The currently active TaskFilter enum value
///
/// The widget supports three filter states:
/// * All - Shows total count of tasks
/// * Done - Shows count of completed tasks
/// * Not Done - Shows count of active (incomplete) tasks
///
/// Each chip changes its appearance based on whether it represents the current
/// filter state, using different background colors and text colors to indicate
/// selection.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums.dart';
import '../../../core/themes/colors.dart';
import '../../controllers/task_bloc.dart';
import '../../data/models/task_model.dart';

class FilterChips extends StatelessWidget {
  final List<TaskModel> tasks;
  final TaskFilter currentFilter;

  const FilterChips({required this.tasks, required this.currentFilter});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            context,
            'All',
            tasks.length,
            TaskFilter.all,
          ),
          const SizedBox(width: 3),
          _buildFilterChip(
            context,
            'Done',
            tasks.where((t) => t.isDone).length,
            TaskFilter.completed,
          ),
          const SizedBox(width: 3),
          _buildFilterChip(
            context,
            'Not Done',
            tasks.where((t) => !t.isDone).length,
            TaskFilter.active,
          ),
        ].animate(interval: 100.ms).fade(duration: 75.ms),
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, int count, TaskFilter filter) {
    return GestureDetector(
      onTap: () => context.read<TaskBloc>().add(ChangeFilter(filter)),
      child: Chip(
          shadowColor: Colors.transparent,
          elevation: 0,
          label: Text(
            '$label ($count)',
            style: TextStyle(
              color: currentFilter == filter ? MyColors.white : MyColors.green,
            ),
          ),
          backgroundColor: currentFilter == filter
              ? MyColors.green
              : MyColors.black.withOpacity(0.1),
          color: WidgetStatePropertyAll(
            currentFilter == filter
                ? MyColors.green
                : MyColors.green.withOpacity(0.1),
          )),
    );
  }
}
