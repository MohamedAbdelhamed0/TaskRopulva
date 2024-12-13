import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:task_ropulva_todo_app/core/services/sound_service.dart';
import 'package:task_ropulva_todo_app/core/themes/colors.dart';

class _DialogConstants {
  static const dialogMaxWidth = 400.0;
  static const dialogMargin = 24.0;
  static const dialogRadius = 28.0;
  static const animationHeight = 180.0;
  static const animationDuration = Duration(milliseconds: 800);
  static const soundSpeed = 1.5;
}

class _CompletionFeedback {
  static String getEmoji(
      Duration duration, bool isOnTime, Duration? timeToDeadline) {
    if (timeToDeadline == null) return '🎯';
    if (!isOnTime) return '⏰';

    final hoursEarly = timeToDeadline.inHours;
    if (hoursEarly > 24) return '🏃';
    if (hoursEarly > 12) return '⚡';
    if (hoursEarly > 6) return '👍';
    if (hoursEarly > 2) return '😊';
    return '😅';
  }

  static String getMessage(bool isOnTime, Duration? timeToDeadline) {
    if (timeToDeadline == null) return 'Great job completing this task!';

    if (!isOnTime) {
      return _formatLateMessage(timeToDeadline.abs());
    }
    return _formatEarlyMessage(timeToDeadline);
  }

  static String _formatLateMessage(Duration lateDuration) {
    final hours = lateDuration.inHours;
    final minutes = lateDuration.inMinutes % 60;
    return hours > 0
        ? 'Completed ${hours}h ${minutes}m late'
        : 'Completed ${minutes}m late';
  }

  static String _formatEarlyMessage(Duration earlyDuration) {
    final hours = earlyDuration.inHours;
    final minutes = earlyDuration.inMinutes % 60;
    return hours > 0
        ? 'Completed ${hours}h ${minutes}m early! 🎯'
        : 'Completed ${minutes}m early! 🎯';
  }
}

class CongratulationsDialog extends StatefulWidget {
  final Duration timeTaken;
  final bool isOnTime;
  final Duration? timeToDeadline;

  const CongratulationsDialog({
    super.key,
    required this.timeTaken,
    required this.isOnTime,
    this.timeToDeadline,
  });

  @override
  CongratulationsDialogState createState() => CongratulationsDialogState();
}

class CongratulationsDialogState extends State<CongratulationsDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _playSound();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: _DialogConstants.animationDuration,
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

  Future<void> _playSound() async {
    await _soundService.initialize();
    await _soundService.playSound(
      'assets/sound/crowd-cheer-in-school-auditorium-236699.mp3',
      speed: _DialogConstants.soundSpeed,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _soundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          _buildBlurredBackground(),
          _buildDialogContent(context),
        ],
      );

  Widget _buildBlurredBackground() => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(color: Colors.black.withOpacity(0.1)),
      );

  Widget _buildDialogContent(BuildContext context) => Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: _DialogConstants.dialogMaxWidth,
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: _DialogConstants.dialogMargin,
            ),
            decoration: _buildDialogDecoration(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimationContainer(),
                _buildContentSection(context),
              ],
            ),
          ),
        ),
      );

  BoxDecoration _buildDialogDecoration(BuildContext context) => BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(_DialogConstants.dialogRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      );

  Widget _buildAnimationContainer() => Container(
        height: _DialogConstants.animationHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: MyColors.green.withOpacity(0.1),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(_DialogConstants.dialogRadius),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildConfettiAnimation(),
            _buildTrophyIcon(),
          ],
        ),
      );

  Widget _buildConfettiAnimation() => Lottie.asset(
        'assets/lotties/cele.json',
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.cover,
      );

  Widget _buildTrophyIcon() => Icon(
        Icons.emoji_events_rounded,
        size: 80,
        color: MyColors.green.withOpacity(0.5),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 2.seconds, color: MyColors.green)
          .shake(duration: 1.seconds, curve: Curves.easeInOut);

  Widget _buildContentSection(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTitle(context),
            const SizedBox(height: 16),
            _buildMessage(context),
            const SizedBox(height: 32),
            _buildActionButton(context),
          ],
        ),
      );

  Widget _buildTitle(BuildContext context) => Text(
        'Congratulations! 🎉',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: MyColors.green,
            ),
        textAlign: TextAlign.center,
      ).animate().fade(duration: 400.ms).scale(
            begin: const Offset(0.8, 0.8),
            curve: Curves.easeOutBack,
            duration: 600.ms,
          );

  Widget _buildMessage(BuildContext context) => Text(
        '${_CompletionFeedback.getMessage(widget.isOnTime, widget.timeToDeadline)}\n'
        '${_CompletionFeedback.getEmoji(widget.timeTaken, widget.isOnTime, widget.timeToDeadline)}',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.4),
        textAlign: TextAlign.center,
      ).animate(delay: 200.ms).fade(duration: 400.ms).slideY(
            begin: 0.2,
            curve: Curves.easeOutBack,
            duration: 600.ms,
          );

  Widget _buildActionButton(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.celebration_rounded),
          label: const Text('Awesome!', style: TextStyle(fontSize: 16)),
        ),
      ).animate(delay: 400.ms).fade(duration: 400.ms).slideY(
            begin: 0.2,
            curve: Curves.easeOutBack,
            duration: 600.ms,
          );
}
