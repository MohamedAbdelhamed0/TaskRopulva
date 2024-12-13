import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/data/models/task_model.dart';

class CalendarService {
  static final _scopes = [calendar.CalendarApi.calendarScope];
  late calendar.CalendarApi _calendarApi;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final clientId = ClientId(
      'YOUR_CLIENT_ID.apps.googleusercontent.com', // Replace with your client ID
      '', // Replace with your client secret if needed
    );

    await clientViaUserConsent(clientId, _scopes, (url) async {
      await launchUrl(Uri.parse(url));
    }).then((authenticatedClient) {
      _calendarApi = calendar.CalendarApi(authenticatedClient);
      _isInitialized = true;
    });
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      throw StateError(
          'CalendarService must be initialized before use. Call initialize() first.');
    }
  }

  Future<void> addTaskToCalendar(TaskModel task) async {
    await _ensureInitialized();
    final event = calendar.Event()
      ..summary = task.title
      ..description = task.description ?? ''
      ..start = calendar.EventDateTime(dateTime: task.dueDate)
      ..end = calendar.EventDateTime(
          dateTime: task.dueDate?.add(const Duration(hours: 1)));

    await _calendarApi.events.insert(event, 'primary');
  }

  Future<void> updateTaskInCalendar(TaskModel task) async {
    await _ensureInitialized();
    final event = calendar.Event()
      ..summary = task.title
      ..description = task.description ?? ''
      ..start = calendar.EventDateTime(dateTime: task.dueDate)
      ..end = calendar.EventDateTime(
          dateTime: task.dueDate?.add(const Duration(hours: 1)));

    await _calendarApi.events.update(event, 'primary', task.id);
  }

  Future<void> deleteTaskFromCalendar(String taskId) async {
    await _ensureInitialized();
    await _calendarApi.events.delete('primary', taskId);
  }
}
