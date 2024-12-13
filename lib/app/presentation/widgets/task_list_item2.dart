import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:task_ropulva_todo_app/core/services/snackbar_service.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../controllers/task_bloc.dart';
import '../../data/models/task_model.dart';
import 'congratulations_dialog.dart';
import 'show_task_dialog.dart';

class TaskListItem2 extends StatefulWidget {
  final TaskModel task;
  const TaskListItem2({super.key, required this.task});

  @override
  State<TaskListItem2> createState() => _TaskListItem2State();
}

class _TaskListItem2State extends State<TaskListItem2> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTapDown: (details) => _showTaskMenu(context, details.globalPosition),
        child: _buildTaskContainer(),
      ),
    );
  }

  Widget _buildTaskContainer() {
    return AnimatedContainer(
      duration:
          const Duration(milliseconds: UIConstants.hoverAnimationDuration),
      padding: UIConstants.taskItemPadding,
      height: UIConstants.taskItemHeight,
      width: UIConstants.taskItemWidth,
      decoration: _buildContainerDecoration(),
      child: Center(child: _buildTaskListTile()),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: MyColors.white,
      borderRadius: BorderRadius.circular(UIConstants.borderRadius),
      border: Border.all(
        color: isHovered ? MyColors.green : Colors.transparent,
        width: UIConstants.borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: MyColors.black.withOpacity(0.250),
          blurRadius: UIConstants.shadowBlur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildTaskListTile() {
    return ListTile(
      leading: _buildSyncIndicator(),
      contentPadding: EdgeInsets.zero,
      title: _buildTaskTitle(),
      subtitle: _buildTaskDueDate(),
      trailing: _buildTaskStatusIcon(),
    );
  }

  Widget? _buildSyncIndicator() {
    if (!widget.task.needsSync) return null;

    return Tooltip(
      textAlign: TextAlign.center,
      message: 'not in cloud \n it will be on cloud when u back online',
      child: const Icon(Icons.cloud_off)
          .animate(onComplete: (controller) => controller.repeat(reverse: true))
          .shimmer(
            duration: const Duration(milliseconds: 500),
            color: MyColors.green,
          ),
    );
  }

  Widget _buildTaskTitle() {
    return Text(
      widget.task.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _buildTaskDueDate() {
    return Text(
      widget.task.dueDate != null
          ? 'Due date: ${formatTaskDate(widget.task.dueDate!)}'
          : 'No due date',
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildTaskStatusIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          widget.task.isDone ? AssetPaths.doneIcon : AssetPaths.notDoneIcon,
        ),
      ],
    );
  }

  void _showTaskMenu(BuildContext context, Offset tapPosition) {
    showMenu<String>(
      context: context,
      position: _calculateMenuPosition(tapPosition),
      items: _buildMenuItems(),
    ).then(_handleMenuSelection);
  }

  RelativeRect _calculateMenuPosition(Offset tapPosition) {
    return RelativeRect.fromLTRB(
      tapPosition.dx,
      tapPosition.dy,
      tapPosition.dx + 1,
      tapPosition.dy + 1,
    );
  }

  List<PopupMenuItem<String>> _buildMenuItems() {
    return [
      PopupMenuItem<String>(
        value: widget.task.isDone ? 'mark_not_done' : 'mark_done',
        child: Row(
          children: [
            Icon(
              widget.task.isDone ? Icons.remove_done : Icons.done,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            Text(widget.task.isDone ? 'Mark Not Done' : 'Mark Done'),
          ],
        ),
      ),
      const PopupMenuItem<String>(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit, color: MyColors.green),
            SizedBox(width: 8),
            Text('Edit'),
          ],
        ),
      ),
      const PopupMenuItem<String>(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete'),
          ],
        ),
      ),
    ];
  }

  void _handleMenuSelection(String? value) {
    if (value == null) return;

    final taskBloc = context.read<TaskBloc>();
    switch (value) {
      case 'mark_done':
        _handleMarkDone(taskBloc);
        break;
      case 'mark_not_done':
        _handleMarkNotDone(taskBloc);
        break;
      case 'edit':
        showTaskDialog(context, existingTask: widget.task);
        break;
      case 'delete':
        taskBloc.add(DeleteTask(widget.task.id));
        SnackBarService.showDelete(
          'Task deleted',
          () => taskBloc.add(AddTask(widget.task)),
        );
        break;
    }
  }

  void _handleMarkDone(TaskBloc taskBloc) {
    final now = DateTime.now();
    final completionData = _calculateCompletionData(now);

    taskBloc.add(UpdateTask(widget.task.copyWith(isDone: true)));

    showDialog(
      context: context,
      builder: (context) => CongratulationsDialog(
        timeTaken: completionData.duration,
        isOnTime: completionData.isOnTime,
        timeToDeadline: completionData.timeToDeadline,
      ),
    );
  }

  void _handleMarkNotDone(TaskBloc taskBloc) {
    taskBloc.add(
      UpdateTask(widget.task.copyWith(
        isDone: false,
        startTime: DateTime.now(),
      )),
    );
  }

  ({Duration duration, bool isOnTime, Duration? timeToDeadline})
      _calculateCompletionData(DateTime now) {
    final createdAt = widget.task.createdAt ?? now;
    final dueDate = widget.task.dueDate;

    return (
      duration: now.difference(createdAt),
      isOnTime: dueDate != null ? now.isBefore(dueDate) : true,
      timeToDeadline: dueDate?.difference(now),
    );
  }
}
