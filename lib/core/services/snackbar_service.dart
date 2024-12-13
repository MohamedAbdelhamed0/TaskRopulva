import 'package:flutter/material.dart';

class SnackBarService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message) {
    _showSnackBar(
      message,
      backgroundColor: Colors.green.shade600,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }

  static void showError(String message) {
    _showSnackBar(
      message,
      backgroundColor: Colors.red.shade600,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  static void showWarning(String message) {
    _showSnackBar(
      message,
      backgroundColor: Colors.orange.shade700,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }

  static void showDelete(String message, VoidCallback onUndo) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.delete, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: onUndo,
            child: const Text(
              'UNDO',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red.shade600,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      elevation: 4,
    );

    messengerKey.currentState
      ?..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void _showSnackBar(
    String message, {
    Color backgroundColor = Colors.black,
    Duration duration = const Duration(seconds: 2),
    Icon? icon,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            icon,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      elevation: 4,
    );

    messengerKey.currentState
      ?..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
