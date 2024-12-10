import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controllers/task_bloc.dart';
import '../../data/models/task_model.dart';
import '../../../core/widgets/connectivity_status_icon.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

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
            return ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.description),
                      if (task.dueDate != null)
                        Text(
                          'Due: ${task.dueDate.toString().split('.')[0]}',
                          style: TextStyle(
                            color: task.dueDate!.isBefore(DateTime.now())
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                    ],
                  ),
                  leading: task.needsSync
                      ? const Icon(Icons.cloud_off, color: Colors.grey)
                      : const Icon(Icons.cloud_done, color: Colors.green),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showTaskDialog(context, existingTask: task),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          context.read<TaskBloc>().add(DeleteTask(task.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task deleted')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
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
