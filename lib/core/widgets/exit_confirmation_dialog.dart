import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../themes/colors.dart';

class ExitConfirmationDialog extends StatefulWidget {
  const ExitConfirmationDialog({super.key});

  @override
  State<ExitConfirmationDialog> createState() => _ExitConfirmationDialogState();
}

class _ExitConfirmationDialogState extends State<ExitConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
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
                    _buildAnimationContainer(),
                    _buildContentSection(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildAnimationContainer() => Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.exit_to_app_rounded,
              size: 80,
              color: Colors.red.withOpacity(0.5),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2.seconds, color: Colors.red)
                .shake(duration: 1.seconds, curve: Curves.easeInOut),
          ],
        ),
      );

  Widget _buildContentSection(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Are you sure? 😢',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
              textAlign: TextAlign.center,
            ).animate().fade(duration: 400.ms).scale(
                  begin: const Offset(0.8, 0.8),
                  curve: Curves.easeOutBack,
                  duration: 600.ms,
                ),
            const SizedBox(height: 16),
            Text(
              'Do you really want to exit the app?',
              style:
                  Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ).animate(delay: 200.ms).fade(duration: 400.ms).slideY(
                  begin: 0.2,
                  curve: Curves.easeOutBack,
                  duration: 600.ms,
                ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: MyColors.green.withOpacity(.250),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(
                      Icons.close,
                      color: MyColors.green,
                    ),
                    label: const Text('Cancel',
                        style: TextStyle(fontSize: 16, color: MyColors.green)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Exit', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ).animate(delay: 400.ms).fade(duration: 400.ms).slideY(
                  begin: 0.2,
                  curve: Curves.easeOutBack,
                  duration: 600.ms,
                ),
          ],
        ),
      );
}
