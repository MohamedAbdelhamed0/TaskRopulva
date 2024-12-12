import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/themes/colors.dart';
import '../../controllers/task_bloc.dart';
import '../../data/models/task_model.dart';
import '../screens/task_list_screen.dart';

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
        ],
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
