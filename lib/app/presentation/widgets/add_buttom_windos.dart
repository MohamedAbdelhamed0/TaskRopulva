import 'package:flutter/material.dart';

import '../../../core/themes/colors.dart';

class AddButtonWindows extends StatefulWidget {
  final VoidCallback onPressed;

  const AddButtonWindows({
    super.key,
    required this.onPressed,
  });

  @override
  State<AddButtonWindows> createState() => _AddButtonWindowsState();
}

class _AddButtonWindowsState extends State<AddButtonWindows> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          color: MyColors.green,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: IconButton(
          style: ButtonStyle(
            fixedSize: WidgetStateProperty.all<Size>(const Size(55, 55)),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          padding: EdgeInsets.zero,
          iconSize: 55,
          onPressed: widget.onPressed,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return RotationTransition(
                turns: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              isHovered ? Icons.task : Icons.add,
              key: ValueKey<bool>(isHovered),
              color: MyColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
