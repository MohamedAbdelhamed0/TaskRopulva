import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  final Connectivity _connectivity = Connectivity();
  ConnectivityResult _currentStatus = ConnectivityResult.none;

  ConnectivityHelper();

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _currentStatus = results.first;
  }

  void dispose() {
    // Add any cleanup if needed
  }

  ConnectivityResult get currentConnectionStatus => _currentStatus;

  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map((results) => results.first);

  Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> hasInternetConnection() async {
    return hasConnection();
  }
}
