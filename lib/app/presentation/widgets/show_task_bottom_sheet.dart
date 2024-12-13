/// A widget that displays an animated form for creating or editing tasks.
///
/// This widget provides a collapsible form that expands when clicked. When expanded,
/// it shows input fields for task title and due date. The form can be used both for
/// creating new tasks and editing existing ones.
///
/// The widget includes:
/// * An animated container that expands/collapses smoothly
/// * A blur effect on the background when expanded
/// * Form validation for the task title
/// * Date and time picker for selecting due date
/// * Integration with TaskBloc for state management
///
/// Example:
/// ```dart
/// AnimatedTaskForm(
///   existingTask: taskModel, // Pass null for creating new task
/// )
/// ```
///
/// Parameters:
/// * [existingTask] - Optional parameter that contains the task to be edited.
///   If null, the form will be in "create new task" mode.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/snackbar_service.dart';
import '../../../core/themes/colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../controllers/task_bloc.dart';
import '../../data/models/task_model.dart';
import 'task_form_validation.dart';

class AnimatedTaskForm extends StatefulWidget {
  final TaskModel? existingTask;
  const AnimatedTaskForm({super.key, this.existingTask});

  @override
  State<AnimatedTaskForm> createState() => _AnimatedTaskFormState();
}

class _AnimatedTaskFormState extends State<AnimatedTaskForm> {
  bool isExpanded = false;
  bool isAnimationComplete = false;
  final formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.existingTask?.title);
    selectedDate = widget.existingTask?.dueDate;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
          sigmaX: isExpanded ? 5 : 0, sigmaY: isExpanded ? 5 : 0),
      child: Padding(
        padding: isExpanded
            ? const EdgeInsets.symmetric(horizontal: 9)
            : EdgeInsets.zero,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isExpanded ? MediaQuery.sizeOf(context).height * 0.350 : 53,
          width: MediaQuery.sizeOf(context).width,
          curve: Curves.easeInOut,
          onEnd: () {
            setState(() {
              isAnimationComplete = isExpanded;
            });
          },
          decoration: BoxDecoration(
            color: isExpanded ? MyColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(isExpanded ? 16 : 16),
            boxShadow: [
              BoxShadow(
                color: isExpanded
                    ? Colors.black.withOpacity(0.250)
                    : Colors.transparent,
                blurRadius: isExpanded ? 4 : 0,
                offset: isExpanded ? const Offset(0, 4) : const Offset(0, 0),
              ),
            ],
          ),
          child: isExpanded && isAnimationComplete
              ? _buildExpandedContent()
              : _buildCollapsedContent(),
        ),
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: FilledButton(
        onPressed: () {
          setState(() {
            isExpanded = true;
            isAnimationComplete = false;
          });
        },
        child: const Text('Create Task'),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.only(left: 11.0, right: 11.0, top: 16.0),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingTask == null ? 'Create New Task' : 'Edit Task',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: MyColors.orange),
                  onPressed: () => setState(() => isExpanded = false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: TaskFormValidation.validateTitle,
            ),
            const SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              onTap: _selectDateTime,
              decoration: const InputDecoration(
                labelText: 'Due Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: selectedDate != null ? formatTaskDate(selectedDate!) : '',
              ),
            ),
            const SizedBox(height: 15),
            FilledButton(
              onPressed: _submitForm,
              child: Text(
                  widget.existingTask == null ? 'Save Task' : 'Update Task'),
            ),
            const SizedBox(height: 15),
          ].animate(interval: 100.ms).fade(duration: 75.ms),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _submitForm() {
    if (!formKey.currentState!.validate()) return;
    if (selectedDate == null) {
      SnackBarService.showWarning('Please select a due date');
      return;
    }

    final task = widget.existingTask?.copyWith(
          title: titleController.text.trim(),
          description: '', // Add empty description
          dueDate: selectedDate,
          needsSync: true,
        ) ??
        TaskModel(
          id: DateTime.now().toString(),
          title: titleController.text.trim(),
          description: '', // Add empty description
          dueDate: selectedDate,
          needsSync: true,
          createdAt: DateTime.now(),
        );

    if (widget.existingTask == null) {
      context.read<TaskBloc>().add(AddTask(task));
    } else {
      context.read<TaskBloc>().add(UpdateTask(task));
    }

    setState(() => isExpanded = false);
    SnackBarService.showSuccess(
      widget.existingTask == null
          ? 'Task added successfully'
          : 'Task updated successfully',
    );
  }
}
