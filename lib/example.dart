import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'core/themes/colors.dart';

void main() {
  // Accessing a color
  Color headlineColor = MyColors.black;

  // Printing the color
  if (kDebugMode) {
    print('Headline color: $headlineColor');
  }
}
