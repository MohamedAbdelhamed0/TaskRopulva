/// A screen widget that displays a list of tasks.
///
/// This widget implements a stateful screen that shows a list of tasks and provides
/// functionality to add new tasks through a floating action button on touch devices.
///
/// Features:
/// * Transparent status bar with dark icons
/// * Responsive design that adapts to touch and non-touch devices
/// * Integration with TaskBloc for state management
/// * Loading indicator while tasks are being fetched
/// * Floating action button for adding new tasks (only on touch devices)
///
/// The screen's UI elements are styled according to the system's theme and include:
/// * A floating action button centered at the bottom (for touch devices)
/// * A main content area displaying the task list
/// * A loading indicator when tasks are being loaded
///
/// The status bar appearance is managed in the widget's lifecycle methods to maintain
/// consistency with the app's design.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import SystemChrome
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/responsive_helper.dart';
import '../../controllers/task_bloc.dart';
import '../widgets/show_task_bottom_sheet.dart';
import '../widgets/task_list_content.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    // Set the status bar color in initState
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Replace with your desired color
      statusBarIconBrightness: Brightness.dark, // Use dark for light status bar
    ));
  }

  @override
  void dispose() {
    // Reset the status bar color when navigating away
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isTouch = ResponsiveHelper.isTouch(context);

    return Scaffold(
      floatingActionButton: isTouch ? const AnimatedTaskForm() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TasksLoaded) {
            return TaskListContent(state: state);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
