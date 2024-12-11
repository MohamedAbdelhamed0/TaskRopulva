import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/services/responsive_helper.dart';
import '../../../core/themes/colors.dart';
import '../../controllers/task_bloc.dart';
import '../../data/models/task_model.dart';
import '../widgets/CongratulationsDialog.dart';

enum TaskFilter { all, active, completed }

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TasksLoaded) {
            return _TaskListContent(state: state);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskListContent extends StatelessWidget {
  final TasksLoaded state;

  const _TaskListContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final tasks = state.tasks;
    final filteredTasks = _getFilteredTasks(tasks, state.currentFilter);

    return Padding(
      padding: ResponsiveHelper.getPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(),
          _FilterChips(tasks: tasks, currentFilter: state.currentFilter),
          _TaskList(filteredTasks: filteredTasks),
        ],
      ),
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

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Good Morning',
        style: Theme.of(context).textTheme.headlineLarge);
  }
}

class _FilterChips extends StatelessWidget {
  final List<TaskModel> tasks;
  final TaskFilter currentFilter;

  const _FilterChips({required this.tasks, required this.currentFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
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
          _buildFilterChip(
            context,
            'Done',
            tasks.where((t) => t.isDone).length,
            TaskFilter.completed,
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => context.read<TaskBloc>().add(ChangeFilter(filter)),
        child: Chip(
            shadowColor: Colors.transparent,
            elevation: 0,
            label: Text(
              '$label ($count)',
              style: TextStyle(
                color:
                    currentFilter == filter ? MyColors.white : MyColors.green,
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
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskModel> filteredTasks;

  const _TaskList({required this.filteredTasks});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final double maxWidth = ResponsiveHelper.getMaxWidth(context);
    final int crossAxisCount = ResponsiveHelper.isDesktop(context) ? 3 : 2;

    return Expanded(
      child: filteredTasks.isEmpty
          ? _EmptyTaskList()
          : isMobile
              ? ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) =>
                      _TaskListItem2(task: filteredTasks[index]),
                )
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: (323 / 79), // Original mobile dimensions
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) =>
                      _TaskListItem2(task: filteredTasks[index]),
                ),
    );
  }
}

class _EmptyTaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No tasks available',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _TaskListItem2 extends StatefulWidget {
  final TaskModel task;
  const _TaskListItem2({required this.task});

  @override
  State<_TaskListItem2> createState() => _TaskListItem2State();
}

class _TaskListItem2State extends State<_TaskListItem2> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTapDown: (details) => _showTaskMenu(context, details.globalPosition),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 79,
          width: 323,
          decoration: BoxDecoration(
            color: MyColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHovered ? MyColors.green : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: MyColors.black.withOpacity(0.250),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                widget.task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              subtitle: Text(
                widget.task.dueDate != null
                    ? 'Due date: ${widget.task.dueDate.toString().split('.')[0]}'
                    : 'No due date',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: Stack(
                alignment: Alignment.center,
                children: [
                  widget.task.isDone
                      ? SvgPicture.asset('assets/svgs/done.svg')
                      : SvgPicture.asset('assets/svgs/not_done.svg'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskMenu(BuildContext context, Offset tapPosition) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1,
        tapPosition.dy + 1,
      ),
      items: [
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
      ],
    ).then((value) {
      if (value == null) return;

      switch (value) {
        case 'mark_done':
          final now = DateTime.now();
          final createdAt = widget.task.createdAt ?? now;
          final dueDate = widget.task.dueDate;
          final completionDuration = now.difference(createdAt);

          // Calculate if task was completed before or after due date
          final isOnTime = dueDate != null ? now.isBefore(dueDate) : true;
          final timeToDeadline =
              dueDate != null ? dueDate.difference(now) : null;

          context.read<TaskBloc>().add(
                UpdateTask(widget.task.copyWith(isDone: true)),
              );

          showDialog(
            context: context,
            builder: (context) => CongratulationsDialog(
              timeTaken: completionDuration,
              isOnTime: isOnTime,
              timeToDeadline: timeToDeadline,
            ),
          );
          break;
        case 'mark_not_done':
          context.read<TaskBloc>().add(
                UpdateTask(widget.task.copyWith(
                  isDone: false,
                  startTime: DateTime.now(),
                )),
              );
          break;
        case 'edit':
          _showTaskDialog(context, existingTask: widget.task);
          break;
        case 'delete':
          context.read<TaskBloc>().add(DeleteTask(widget.task.id));
          break;
      }
    });
  }
}

void _showTaskDialog(BuildContext context, {TaskModel? existingTask}) {
  final titleController = TextEditingController(text: existingTask?.title);
  final descriptionController =
      TextEditingController(text: existingTask?.description);
  DateTime? selectedDate = existingTask?.dueDate;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(existingTask == null ? 'Add Task' : 'Edit Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          ListTile(
            title: Text(selectedDate != null
                ? 'Due: ${selectedDate.toString().split('.')[0]}'
                : 'Set Due Date & Time'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );

              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                    selectedDate ?? DateTime.now(),
                  ),
                );

                if (time != null) {
                  selectedDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                  (context as Element).markNeedsBuild();
                }
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final title = titleController.text.trim();
            final description = descriptionController.text.trim();

            if (title.isEmpty) return;

            final task = existingTask?.copyWith(
                  title: title,
                  description: description,
                  dueDate: selectedDate,
                  needsSync: true,
                ) ??
                TaskModel(
                  id: DateTime.now().toString(),
                  title: title,
                  description: description,
                  dueDate: selectedDate,
                  needsSync: true,
                  createdAt: DateTime.now(), // Add this line
                );

            if (existingTask == null) {
              context.read<TaskBloc>().add(AddTask(task));
            } else {
              context.read<TaskBloc>().add(UpdateTask(task));
            }

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(existingTask == null
                    ? 'Task added successfully'
                    : 'Task updated successfully'),
              ),
            );
          },
          child: Text(existingTask == null ? 'Add' : 'Update'),
        ),
      ],
    ),
  );
}
