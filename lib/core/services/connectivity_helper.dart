import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityResult> _controller =
      StreamController<ConnectivityResult>.broadcast();
  Timer? _timer;
  ConnectivityResult _lastResult = ConnectivityResult.none;

  void initialize() {
    // Listen to platform connectivity changes
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // Start periodic connectivity check
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    });

    // Do initial check
    _connectivity.checkConnectivity().then(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    if (_lastResult != result) {
      _lastResult = result;
      if (!_controller.isClosed) {
        _controller.add(result);
      }
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }

  Stream<ConnectivityResult> get onConnectivityChanged => _controller.stream;

  Future<bool> hasInternetConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  ConnectivityResult get currentConnectionStatus => _lastResult;

  Future<String> getConnectionType() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    switch (connectivityResult) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.none:
        return 'No Internet';
      default:
        return 'Unknown';
    }
  }
}
