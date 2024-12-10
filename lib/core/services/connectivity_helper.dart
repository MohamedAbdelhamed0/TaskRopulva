import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static final Connectivity _connectivity = Connectivity();
  static StreamController<ConnectivityResult> _controller =
      StreamController<ConnectivityResult>.broadcast();
  static Timer? _timer;
  static ConnectivityResult _lastResult = ConnectivityResult.none;

  static void initialize() {
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

  static void _updateConnectionStatus(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    if (_lastResult != result) {
      _lastResult = result;
      if (!_controller.isClosed) {
        _controller.add(result);
      }
    }
  }

  static void dispose() {
    _timer?.cancel();
    _controller.close();
    _controller = StreamController<ConnectivityResult>.broadcast();
  }

  /// Stream of connectivity changes
  static Stream<ConnectivityResult> get onConnectivityChanged =>
      _controller.stream;

  /// Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Get current connection status
  static ConnectivityResult get currentConnectionStatus => _lastResult;

  /// Get current connection type
  static Future<String> getConnectionType() async {
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
