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
