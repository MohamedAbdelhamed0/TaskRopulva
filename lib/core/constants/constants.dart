import 'package:flutter/material.dart';

class UIConstants {
  static const double taskItemHeight = 79.0;
  static const double taskItemWidth = 323.0;
  static const double borderRadius = 10.0;
  static const double borderWidth = 2.0;
  static const double shadowBlur = 4.0;
  static const int hoverAnimationDuration = 200;

  static const EdgeInsets taskItemPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
}

class AssetPaths {
  static const String doneIcon = 'assets/svgs/done.svg';
  static const String notDoneIcon = 'assets/svgs/not_done.svg';
}
