import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/service_locator.dart';
import '../services/connectivity_helper.dart';
import '../themes/colors.dart';

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
        barrierLabel: 'Dismiss',
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, __) => Container(),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
              Center(
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: (isOffline ? Colors.red : MyColors.green)
                                .withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              icon,
                              size: 80,
                              color: (isOffline ? Colors.red : MyColors.green)
                                  .withOpacity(0.5),
                            )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .shimmer(
                                  duration: 2.seconds,
                                  color:
                                      isOffline ? Colors.red : MyColors.green,
                                )
                                .shake(
                                  duration: 1.seconds,
                                  curve: Curves.easeInOut,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isOffline
                                          ? Colors.red
                                          : MyColors.green,
                                    ),
                                textAlign: TextAlign.center,
                              ).animate().fade(duration: 400.ms).scale(
                                    begin: const Offset(0.8, 0.8),
                                    curve: Curves.easeOutBack,
                                    duration: 600.ms,
                                  ),
                              const SizedBox(height: 16),
                              Text(
                                message,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      height: 1.4,
                                    ),
                                textAlign: TextAlign.center,
                              )
                                  .animate(delay: 200.ms)
                                  .fade(duration: 400.ms)
                                  .slideY(
                                    begin: 0.2,
                                    curve: Curves.easeOutBack,
                                    duration: 600.ms,
                                  ),
                              const SizedBox(height: 32),
                              if (isOffline) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildButton(
                                        context: context,
                                        onPressed: () {
                                          _isDialogShowing = false;
                                          Navigator.of(context).pop();
                                        },
                                        label: 'CLOSE',
                                        isPrimary: false,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildButton(
                                        context: context,
                                        onPressed: () async {
                                          final hasConnection =
                                              await _connectivityHelper
                                                  .hasInternetConnection();
                                          if (hasConnection &&
                                              context.mounted) {
                                            _isDialogShowing = false;
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        label: 'RETRY',
                                        isPrimary: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else
                                _buildButton(
                                  context: context,
                                  onPressed: () {
                                    _isDialogShowing = false;
                                    Navigator.of(context).pop();
                                  },
                                  label: 'OK',
                                  isPrimary: true,
                                  isFullWidth: true,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ).then((_) => _isDialogShowing = false);
    }
  }

  static Widget _buildButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required String label,
    required bool isPrimary,
    bool isFullWidth = false,
  }) {
    final button = isPrimary
        ? FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(label, style: const TextStyle(fontSize: 16)),
          )
        : TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: MyColors.green,
              backgroundColor: MyColors.green.withOpacity(.250),
              fixedSize: const Size(double.infinity, 53),
              minimumSize: const Size(double.infinity, 53),
              maximumSize: const Size(double.infinity, 53),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(label, style: const TextStyle(fontSize: 16)),
          );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
