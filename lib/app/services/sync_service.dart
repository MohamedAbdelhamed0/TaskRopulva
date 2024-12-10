import 'dart:async';
import '../../core/services/connectivity_helper.dart';
import '../../core/services/service_locator.dart';
import '../controllers/task_bloc.dart';
import '../data/data_sources/remote_data_source.dart';

class SyncService {
  final TaskBloc _taskBloc;
  final _remoteDataSource = getIt<RemoteDataSource>();
  final _connectivityHelper = getIt<ConnectivityHelper>();
  final _syncController = StreamController<void>.broadcast();
  Timer? _syncTimer;

  SyncService(this._taskBloc);

  Stream<void> syncChanges() => _syncController.stream;

  void scheduleSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 5), _sync);
  }

  Future<void> _sync() async {
    final hasConnection = await _connectivityHelper.hasConnection();
    if (!hasConnection) {
      return;
    }

    try {
      if (_taskBloc.state is TasksLoaded) {
        final state = _taskBloc.state as TasksLoaded;
        final tasks = state.tasks;
        final needsSyncTasks = tasks.where((task) => task.needsSync).toList();

        for (var task in needsSyncTasks) {
          await _remoteDataSource.updateTask(task);
          task.needsSync = false;
          _taskBloc.add(UpdateTask(task));
        }

        _syncController.add(null);
      }
    } catch (e) {
      print('Sync failed: $e');
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncController.close();
  }
}
