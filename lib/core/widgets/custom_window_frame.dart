import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_ropulva_todo_app/core/widgets/connectivity_status_icon.dart';
import 'package:window_manager/window_manager.dart';

import '../themes/colors.dart';
import 'exit_confirmation_dialog.dart';

class CustomWindowFrame extends StatelessWidget {
  final Widget child;
  final String title;
  final Color? backgroundColor;

  const CustomWindowFrame({
    super.key,
    required this.child,
    required this.title,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WindowCaption(
          brightness: Theme.of(context).brightness,
          backgroundColor: MyColors.white,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? MyColors.white
                      : MyColors.black,
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 50,
                fit: BoxFit.contain,
              )
                  .animate()
                  .slide()
                  .then(duration: const Duration(seconds: 2))
                  .shimmer(
                    color: Colors.white,
                    duration: const Duration(seconds: 2),
                  ),
              const Spacer(),
              const ConnectivityStatusIcon(
                size: 15.0,
              )
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class WindowCaption extends StatelessWidget {
  final Widget title;
  final Color backgroundColor;
  final Brightness brightness;

  const WindowCaption({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  child: title,
                ),
              ),
            ),
          ),
          WindowCaptionButton.minimize(
            brightness: brightness,
            onPressed: () async {
              await windowManager.minimize();
            },
          ),
          WindowCaptionButton.maximize(
            brightness: brightness,
            onPressed: () async {
              if (await windowManager.isMaximized()) {
                await windowManager.restore();
              } else {
                await windowManager.maximize();
              }
            },
          ),
          WindowCaptionButton.close(
            brightness: brightness,
            onPressed: () async {
              final shouldExit = await showDialog<bool>(
                context: context,
                builder: (context) => const ExitConfirmationDialog(),
              );
              if (shouldExit == true) {
                await windowManager.close();
              }
            },
          ),
        ],
      ),
    );
  }
}
