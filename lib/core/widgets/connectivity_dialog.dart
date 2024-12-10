import 'package:flutter/material.dart';
import '../../core/services/service_locator.dart';

import '../services/connectivity_helper.dart';

class ConnectivityDialog {
  static bool _isDialogShowing = false;
  static bool get isDialogShowing => _isDialogShowing;
  static final _connectivityHelper = getIt<ConnectivityHelper>();

  static void showNoInternetDialog(BuildContext context) {
    _showDialog(
      context,
      icon: Icons.wifi_off_rounded,
      title: 'You\'re Offline',
      message:
          'Don\'t worry! Your data is safely stored locally until you\'re back online.',
      isOffline: true,
    );
  }

  static void showBackOnlineDialog(BuildContext context) {
    _showDialog(
      context,
      icon: Icons.wifi_rounded,
      title: 'Back Online!',
      message: 'Your data is now syncing with the cloud.',
      isOffline: false,
    );
  }

  static void _showDialog(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required bool isOffline,
  }) {
    if (!_isDialogShowing && context.mounted) {
      _isDialogShowing = true;
      showGeneralDialog(
        context: context,
        barrierDismissible: !isOffline,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, __) => Container(),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: FadeTransition(
              opacity: animation,
              child: PopScope(
                canPop: !isOffline,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Column(
                    children: [
                      _buildAnimatedIcon(animation, icon, isOffline),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  actions: [
                    if (isOffline) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {
                                _isDialogShowing = false;
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'CLOSE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () async {
                                final hasConnection = await _connectivityHelper
                                    .hasInternetConnection();
                                if (hasConnection && context.mounted) {
                                  _isDialogShowing = false;
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text(
                                'RETRY',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          _isDialogShowing = false;
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ).then((_) => _isDialogShowing = false);
    }
  }

  static Widget _buildAnimatedIcon(
    Animation<double> animation,
    IconData icon,
    bool isOffline,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14,
          child: Icon(
            icon,
            size: 48,
            color: isOffline
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}
