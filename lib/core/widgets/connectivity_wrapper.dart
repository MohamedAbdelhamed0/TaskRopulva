import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/connectivity_helper.dart';
import 'connectivity_dialog.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _wasConnected = true;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    // Initialize connectivity
    ConnectivityHelper.initialize();
    // Check initial connection after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnection();
    });
    // Listen to changes
    _subscription = ConnectivityHelper.onConnectivityChanged.listen((result) {
      if (!mounted) return;

      final isConnected = result != ConnectivityResult.none;
      if (!isConnected && _wasConnected) {
        _wasConnected = false;
        ConnectivityDialog.showNoInternetDialog(context);
      } else if (isConnected && !_wasConnected) {
        _wasConnected = true;
        if (ConnectivityDialog.isDialogShowing) {
          Navigator.of(context).pop();
        }
        ConnectivityDialog.showBackOnlineDialog(context);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final hasConnection = await ConnectivityHelper.hasInternetConnection();
    _wasConnected = hasConnection;
    if (!hasConnection && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ConnectivityDialog.showNoInternetDialog(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
