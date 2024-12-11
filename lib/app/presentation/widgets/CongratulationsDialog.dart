import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:task_ropulva_todo_app/core/services/SoundService.dart';
import 'package:task_ropulva_todo_app/core/themes/colors.dart';

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
  _CongratulationsDialogState createState() => _CongratulationsDialogState();
}

class _CongratulationsDialogState extends State<CongratulationsDialog>
    with SingleTickerProviderStateMixin {
  final SoundService _soundService = SoundService();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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

    _playSound();
    _controller.forward();
  }

  Future<void> _playSound() async {
    await _soundService.initialize();
    await _soundService.playSound(
      'assets/sound/crowd-cheer-in-school-auditorium-236699.mp3',
      speed: 1.5,
    );
  }

  String _getTimeEmoji(
      Duration duration, bool isOnTime, Duration? timeToDeadline) {
    if (timeToDeadline == null) return '🎯';
    if (!isOnTime) return '⏰';

    final hoursEarly = timeToDeadline.inHours;
    if (hoursEarly > 24) return '🏃'; // Super early
    if (hoursEarly > 12) return '⚡'; // Very early
    if (hoursEarly > 6) return '👍'; // Good timing
    if (hoursEarly > 2) return '😊'; // Just right
    return '😅'; // Cutting it close
  }

  String _getCompletionMessage(bool isOnTime, Duration? timeToDeadline) {
    if (timeToDeadline == null) return 'Great job completing this task!';

    final hours = timeToDeadline.inHours;
    final minutes = timeToDeadline.inMinutes % 60;

    if (!isOnTime) {
      // Task completed late
      final lateHours = timeToDeadline.abs().inHours;
      final lateMinutes = timeToDeadline.abs().inMinutes % 60;
      if (lateHours > 0) {
        return 'Completed ${lateHours}h ${lateMinutes}m late';
      }
      return 'Completed ${lateMinutes}m late';
    }

    // Task completed early
    if (hours > 0) {
      return 'Completed ${hours}h ${minutes}m early! 🎯';
    }
    return 'Completed ${minutes}m early! 🎯';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours hr${hours > 1 ? 's' : ''} $minutes min';
    } else if (minutes > 0) {
      return '$minutes min $seconds sec';
    }
    return '$seconds seconds';
  }

  @override
  void dispose() {
    _controller.dispose();
    _soundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: Colors.black.withOpacity(0.1),
          ),
        ),

        // Main dialog content
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
                  // Trophy animation container
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: MyColors.green.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Confetti animation
                        Lottie.asset(
                          'assets/lotties/cele.json',
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        // Trophy or celebration icon
                        Icon(
                          Icons.emoji_events_rounded,
                          size: 80,
                          color: MyColors.green.withOpacity(0.5),
                        )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .shimmer(
                              duration: 2.seconds,
                              color: MyColors.green,
                            )
                            .shake(
                              duration: 1.seconds,
                              curve: Curves.easeInOut,
                            ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Congratulations! 🎉',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: MyColors.green,
                              ),
                          textAlign: TextAlign.center,
                        ).animate().fade(duration: 400.ms).scale(
                              begin: const Offset(0.8, 0.8),
                              curve: Curves.easeOutBack,
                              duration: 600.ms,
                            ),
                        const SizedBox(height: 16),
                        Text(
                          '${_getCompletionMessage(widget.isOnTime, widget.timeToDeadline)}\n'
                          '${_getTimeEmoji(widget.timeTaken, widget.isOnTime, widget.timeToDeadline)}',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    height: 1.4,
                                  ),
                          textAlign: TextAlign.center,
                        ).animate(delay: 200.ms).fade(duration: 400.ms).slideY(
                              begin: 0.2,
                              curve: Curves.easeOutBack,
                              duration: 600.ms,
                            ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
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
                            label: const Text(
                              'Awesome!',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ).animate(delay: 400.ms).fade(duration: 400.ms).slideY(
                              begin: 0.2,
                              curve: Curves.easeOutBack,
                              duration: 600.ms,
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
  }
}
