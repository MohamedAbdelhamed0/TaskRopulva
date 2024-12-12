import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/themes/colors.dart';
import '../../controllers/task_bloc.dart';
import '../../data/models/task_model.dart';
import '../../utils/date_formatter.dart';
import 'task_form_validation.dart';

class _DialogConstants {
  static const double blurSigma = 5.0;
  static const double borderRadius = 10.0;
  static const double borderWidth = 2.0;
  static const double verticalSpacing = 8.0;
}

class _TaskDialogData {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  DateTime? selectedDate;
  final TaskModel? existingTask;

  _TaskDialogData({required this.existingTask})
      : formKey = GlobalKey<FormState>(),
        titleController = TextEditingController(text: existingTask?.title),
        selectedDate = existingTask?.dueDate;

  void dispose() {
    titleController.dispose();
  }
}

void showTaskDialog(BuildContext context, {TaskModel? existingTask}) {
  final dialogData = _TaskDialogData(existingTask: existingTask);

  showDialog(
    context: context,
    builder: (context) => _buildTaskDialog(context, dialogData),
  ).then((_) => dialogData.dispose());
}

Widget _buildTaskDialog(BuildContext context, _TaskDialogData data) {
  return BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: _DialogConstants.blurSigma,
      sigmaY: _DialogConstants.blurSigma,
    ),
    child: AlertDialog(
      shape: _buildDialogShape(),
      backgroundColor: Colors.white,
      title: _buildDialogTitle(context, data),
      content: _buildDialogContent(context, data),
      actions: [_buildSubmitButton(context, data)],
    ),
  );
}

ShapeBorder _buildDialogShape() => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_DialogConstants.borderRadius),
      side: BorderSide(
        color: MyColors.green.withOpacity(0.250),
        width: _DialogConstants.borderWidth,
      ),
    );

Widget _buildDialogTitle(BuildContext context, _TaskDialogData data) {
  return Row(
    children: [
      Text(
        data.existingTask == null ? 'Create New Task' : 'Edit Task',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const Spacer(),
      IconButton(
        icon: const Icon(Icons.close, color: MyColors.orange),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}

Widget _buildDialogContent(BuildContext context, _TaskDialogData data) {
  return Form(
    key: data.formKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTitleField(data),
        const SizedBox(height: _DialogConstants.verticalSpacing),
        _buildDateField(context, data),
      ],
    ),
  );
}

Widget _buildTitleField(_TaskDialogData data) {
  return TextFormField(
    controller: data.titleController,
    decoration: const InputDecoration(labelText: 'Title'),
    validator: TaskFormValidation.validateTitle,
  );
}

Widget _buildDateField(BuildContext context, _TaskDialogData data) {
  return TextFormField(
    readOnly: true,
    decoration: const InputDecoration(
      labelText: 'Due Date',
      suffixIcon: Icon(Icons.calendar_today),
    ),
    controller: TextEditingController(
      text: data.selectedDate != null ? formatTaskDate(data.selectedDate!) : '',
    ),
    onTap: () => _selectDateTime(context, data),
  );
}

Future<void> _selectDateTime(BuildContext context, _TaskDialogData data) async {
  final date = await showDatePicker(
    context: context,
    initialDate: data.selectedDate ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );

  if (date != null) {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(data.selectedDate ?? DateTime.now()),
    );

    if (time != null) {
      data.selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      (context as Element).markNeedsBuild();
    }
  }
}

Widget _buildSubmitButton(BuildContext context, _TaskDialogData data) {
  return FilledButton(
    onPressed: () => _handleSubmit(context, data),
    child: Text(data.existingTask == null ? 'Save Task' : 'Update Task'),
  );
}

void _handleSubmit(BuildContext context, _TaskDialogData data) {
  if (!_validateForm(context, data)) return;

  final task = _createTask(data);
  _dispatchTaskEvent(context, task, data.existingTask);
  _showSuccessMessage(context, data.existingTask);
  Navigator.pop(context);
}

bool _validateForm(BuildContext context, _TaskDialogData data) {
  if (!data.formKey.currentState!.validate()) return false;
  if (data.selectedDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a due date')),
    );
    return false;
  }
  return true;
}

TaskModel _createTask(_TaskDialogData data) {
  final title = data.titleController.text.trim();
  return data.existingTask?.copyWith(
        title: title,
        description: '',
        dueDate: data.selectedDate,
        needsSync: true,
      ) ??
      TaskModel(
        id: DateTime.now().toString(),
        title: title,
        description: '',
        dueDate: data.selectedDate,
        needsSync: true,
        createdAt: DateTime.now(),
      );
}

void _dispatchTaskEvent(
    BuildContext context, TaskModel task, TaskModel? existingTask) {
  final event = existingTask == null ? AddTask(task) : UpdateTask(task);
  context.read<TaskBloc>().add(event);
}

void _showSuccessMessage(BuildContext context, TaskModel? existingTask) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        existingTask == null
            ? 'Task added successfully'
            : 'Task updated successfully',
      ),
    ),
  );
}
