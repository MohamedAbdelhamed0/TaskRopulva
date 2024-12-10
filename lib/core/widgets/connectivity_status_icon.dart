import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../services/connectivity_helper.dart';
import '../../core/services/service_locator.dart';

class ConnectivityStatusIcon extends StatefulWidget {
  final double size;
  final Color? connectedColor;
  final Color? disconnectedColor;

  const ConnectivityStatusIcon({
    super.key,
    this.size = 24.0,
    this.connectedColor,
    this.disconnectedColor,
  });

  @override
  State<ConnectivityStatusIcon> createState() => _ConnectivityStatusIconState();
}

class _ConnectivityStatusIconState extends State<ConnectivityStatusIcon> {
  bool isHovered = false;
  final _connectivityHelper = getIt<ConnectivityHelper>();

  @override
  void initState() {
    super.initState();
    // Initialize connectivity monitoring
    _connectivityHelper.initialize();
  }

  @override
  void dispose() {
    _connectivityHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: _connectivityHelper.onConnectivityChanged,
      initialData: _connectivityHelper.currentConnectionStatus,
      builder: (context, snapshot) {
        final connected = snapshot.data != ConnectivityResult.none;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Tooltip(
            decoration: BoxDecoration(
              color: connected ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8.0),
            ),
            message: connected
                ? 'Connected: All data will be synchronized with the cloud'
                : 'Offline: Data will be saved locally until connection is restored',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(isHovered ? 1.2 : 1.0),
              child: Icon(
                connected ? Icons.wifi : Icons.wifi_off,
                size: widget.size,
                color: connected
                    ? (widget.connectedColor ?? Colors.green)
                    : (widget.disconnectedColor ?? Colors.red),
              ),
            ),
          ),
        );
      },
    );
  }
}
