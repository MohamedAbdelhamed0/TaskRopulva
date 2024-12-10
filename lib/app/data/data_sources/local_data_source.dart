import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/task_model.dart';

class LocalDataSource {
  static const String _boxName = 'tasks';
  static Box<TaskModel>? _box;

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }

    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    _box = await Hive.openBox<TaskModel>(_boxName);
  }

  Future<void> addTask(TaskModel task) async {
    await _box?.put(task.id, task);
  }

  Future<void> updateTask(TaskModel task) async {
    await _box?.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _box?.delete(id);
  }

  List<TaskModel> getAllTasks() {
    return _box?.values.toList() ?? [];
  }

  Future<void> toggleTaskStatus(String id) async {
    final task = _box?.get(id);
    if (task != null) {
      task.isDone = !task.isDone;
      await _box?.put(id, task);
    }
  }

  TaskModel? getTask(String id) {
    return _box?.get(id);
  }

  // Clear all cached data
  Future<void> clearAllData() async {
    await _box?.clear();
  }

  // Create backup of the database
  Future<String> createBackup() async {
    try {
      final directory = await _getBackupDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath = '${directory.path}/tasks_backup_$timestamp.hive';

      // Get all tasks and convert to JSON
      final tasks = getAllTasks();
      final File backupFile = File(backupPath);

      // Convert tasks to JSON string and write to file
      final List<Map<String, dynamic>> jsonTasks =
          tasks.map((task) => task.toJson()).toList();
      await backupFile.writeAsString(jsonTasks.toString());

      return backupPath;
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  // Restore from backup file
  Future<void> restoreFromBackup(String backupPath) async {
    try {
      final File backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found');
      }

      // Clear existing data
      await clearAllData();

      // Read and parse backup file
      final String content = await backupFile.readAsString();
      final List<dynamic> jsonTasks = content as List<dynamic>;

      // Restore tasks
      for (var jsonTask in jsonTasks) {
        final task = TaskModel.fromJson(jsonTask);
        await addTask(task);
      }
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  // Get backup directory based on platform
  Future<Directory> _getBackupDirectory() async {
    if (Platform.isWindows) {
      // For Windows, use Documents folder
      final Directory directory = Directory(
          '${Platform.environment['USERPROFILE']}\\Documents\\TaskAppBackups');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    } else {
      // For Android, use external storage
      final directory = await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/TaskAppBackups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      return backupDir;
    }
  }

  // List all available backups
  Future<List<FileSystemEntity>> listBackups() async {
    final directory = await _getBackupDirectory();
    return directory
        .listSync()
        .where((file) => file.path.endsWith('.hive'))
        .toList();
  }
}
