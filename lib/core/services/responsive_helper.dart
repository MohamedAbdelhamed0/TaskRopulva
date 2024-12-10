import 'package:flutter/material.dart';
// Less efficient - creates dependency on all MediaQuery properties
// double width = MediaQuery.of(context).size.width;
// More efficient - only creates dependency on size
// double width = MediaQuery.sizeOf(context).width;
//https://www.youtube.com/watch?v=xVk1kPvkgAY

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600 &&
      MediaQuery.sizeOf(context).width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1200;

  static double getWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double getHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static double getPadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 24.0;
    return 32.0;
  }

  static double getMaxWidth(BuildContext context) {
    if (isMobile(context)) return getWidth(context);
    if (isTablet(context)) return 700;
    return 1200;
  }
}