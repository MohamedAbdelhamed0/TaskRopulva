import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/task_bloc.dart';
import '../../data/models/task_model.dart';
import '../../../core/widgets/connectivity_status_icon.dart';

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
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: const [ConnectivityStatusIcon()],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TasksLoaded) {
            final tasks = state.tasks;
            final filteredTasks = switch (state.currentFilter) {
              TaskFilter.all => tasks,
              TaskFilter.active => tasks.where((task) => !task.isDone).toList(),
              TaskFilter.completed =>
                tasks.where((task) => task.isDone).toList(),
            };

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilterChip(
                        selected: state.currentFilter == TaskFilter.all,
                        label: Text('All (${tasks.length})'),
                        onSelected: (_) => context
                            .read<TaskBloc>()
                            .add(ChangeFilter(TaskFilter.all)),
                      ),
                      FilterChip(
                        selected: state.currentFilter == TaskFilter.active,
                        label: Text(
                          'Active (${tasks.where((t) => !t.isDone).length})',
                        ),
                        onSelected: (_) => context
                            .read<TaskBloc>()
                            .add(ChangeFilter(TaskFilter.active)),
                      ),
                      FilterChip(
                        selected: state.currentFilter == TaskFilter.completed,
                        label: Text(
                          'Done (${tasks.where((t) => t.isDone).length})',
                        ),
                        onSelected: (_) => context
                            .read<TaskBloc>()
                            .add(ChangeFilter(TaskFilter.completed)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredTasks.isEmpty
                      ? Center(
                          child: Text(
                            'No ${state.currentFilter.name} tasks',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return ListTile(
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(task.description),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      Chip(
                                        label:
                                            Text(task.isDone ? 'Done' : 'Todo'),
                                        backgroundColor: task.isDone
                                            ? Colors.green[100]
                                            : Colors.blue[100],
                                      ),
                                      if (task.dueDate != null)
                                        Chip(
                                          label: Text(task.dueDate
                                              .toString()
                                              .split('.')[0]),
                                          backgroundColor: task.dueDate!
                                                  .isBefore(DateTime.now())
                                              ? Colors.red[100]
                                              : Colors.orange[100],
                                        ),
                                      if (task.needsSync)
                                        const Chip(
                                          avatar:
                                              Icon(Icons.cloud_off, size: 16),
                                          label: Text('Not synced'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              leading: IconButton(
                                icon: Icon(
                                  task.isDone
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color:
                                      task.isDone ? Colors.green : Colors.grey,
                                ),
                                onPressed: () {
                                  context.read<TaskBloc>().add(
                                        UpdateTask(
                                          task.copyWith(isDone: !task.isDone),
                                        ),
                                      );
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showTaskDialog(context,
                                        existingTask: task),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      context
                                          .read<TaskBloc>()
                                          .add(DeleteTask(task.id));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Task deleted')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
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
}
