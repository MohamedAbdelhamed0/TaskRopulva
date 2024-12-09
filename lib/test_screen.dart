import 'package:flutter/material.dart';
import 'package:task_ropulva_todo_app/core/themes/colors.dart';
import 'package:task_ropulva_todo_app/core/services/responsive_helper.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  String _getFormattedDateTime() {
    if (_selectedDate != null && _selectedTime != null) {
      return '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} ${_selectedTime!.format(context)}';
    }
    return 'No date and time selected';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Screen',
            style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxWidth(context),
          ),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ResponsiveHelper.isDesktop(context)
                      ? _buildDesktopLayout()
                      : _buildMobileLayout(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: _buildCommonWidgets(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: _buildCommonWidgets(),
    );
  }

  List<Widget> _buildCommonWidgets() {
    return [
      Text('Headline Large', style: Theme.of(context).textTheme.headlineLarge),
      Text('Headline Small', style: Theme.of(context).textTheme.headlineSmall),
      Text('Body Medium', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {},
        child: const Text('Elevated Button'),
      ),
      const SizedBox(height: 20),
      const TextField(
        decoration: InputDecoration(
          labelText: 'Input Field',
        ),
      ),
      const SizedBox(height: 20),
      const Chip(
        label: Text('Chip'),
      ),
      const SizedBox(height: 20),
      const ChoiceChip(
        label: Text('Selected Chip'),
        selected: true,
      ),
      const SizedBox(height: 20),
      ChoiceChip(
        label: Text('Unselected Chip',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: MyColors.green, fontWeight: FontWeight.bold)),
        disabledColor: Colors.cyan,
        color: WidgetStatePropertyAll(
          MyColors.green.withOpacity(.1),
        ),
        selected: false,
      ),
      const SizedBox(height: 20),
      const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Card'),
        ),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () => _selectTime(context),
        child: const Text('Select Time'),
      ),
      if (_selectedTime != null)
        Text('Selected Time: ${_selectedTime!.format(context)}'),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () => _selectDateTime(context),
        child: const Text('Select Date & Time'),
      ),
      const SizedBox(height: 10),
      Text(_getFormattedDateTime()),
    ];
  }
}
