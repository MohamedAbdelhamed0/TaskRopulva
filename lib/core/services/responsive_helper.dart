/// A helper class for responsive design, providing utility methods to determine
/// screen size categories and retrieve screen dimensions.
///
/// This class defines several screen size breakpoints and provides methods to
/// check if the current screen size falls within those breakpoints. It also
/// includes methods to get the width, height, padding, and maximum width of the
/// screen based on the current context.
///
/// Screen size breakpoints:
/// - Mobile Small: 320
/// - Mobile Medium: 375
/// - Mobile Large: 425
/// - Tablet: 768
/// - Laptop Small: 1024
/// - Laptop Large: 1440
/// - Desktop 4K: 2560
///
/// Methods:
/// - `isScreenSize(BuildContext context, double width)`: Checks if the screen width is less than or equal to the given width.
/// - `isMobile(BuildContext context)`: Checks if the screen width is less than 600.
/// - `isTablet(BuildContext context)`: Checks if the screen width is between 600 and 1200.
/// - `isDesktop(BuildContext context)`: Checks if the screen width is 1200 or greater.
/// - `isMobileSmall(BuildContext context)`: Checks if the screen width is less than or equal to 320.
/// - `isMobileMedium(BuildContext context)`: Checks if the screen width is less than or equal to 375.
/// - `isMobileLarge(BuildContext context)`: Checks if the screen width is less than or equal to 425.
/// - `isLaptopSmall(BuildContext context)`: Checks if the screen width is less than or equal to 1024.
/// - `isLaptopLarge(BuildContext context)`: Checks if the screen width is less than or equal to 1440.
/// - `is4K(BuildContext context)`: Checks if the screen width is less than or equal to 2560.
/// - `getWidth(BuildContext context)`: Returns the screen width.
/// - `getHeight(BuildContext context)`: Returns the screen height.
/// - `getPadding(BuildContext context)`: Returns the appropriate padding based on the screen size.
/// - `getMaxWidth(BuildContext context)`: Returns the maximum width based on the screen size.
/// - `getResponsiveMaxWidth(BuildContext context)`: Returns the responsive maximum width based on the screen size.
/// - `isPC(BuildContext context)`: Returns true if the device is a PC/laptop based on screen size.
/// - `isTouch(BuildContext context)`: Returns true if the device is likely a touch device based on screen size.
import 'package:flutter/material.dart';
// Less efficient - creates dependency on all MediaQuery properties
// double width = MediaQuery.of(context).size.width;
// More efficient - only creates dependency on size
// double width = MediaQuery.sizeOf(context).width;
//https://www.youtube.com/watch?v=xVk1kPvkgAY

class ResponsiveHelper {
  // Screen size breakpoints
  static const double mobileSmall = 320;
  static const double mobileMedium = 375;
  static const double mobileLarge = 425;
  static const double tablet = 768;
  static const double laptopSmall = 1024;
  static const double laptopLarge = 1440;
  static const double desktop4K = 2560;

  static bool isScreenSize(BuildContext context, double width) =>
      MediaQuery.sizeOf(context).width <= width;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600 &&
      MediaQuery.sizeOf(context).width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1200;

  static bool isMobileSmall(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= mobileSmall;

  static bool isMobileMedium(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= mobileMedium;

  static bool isMobileLarge(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= mobileLarge;

  static bool isLaptopSmall(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= laptopSmall;

  static bool isLaptopLarge(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= laptopLarge;

  static bool is4K(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= desktop4K;

  static double getWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double getHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static EdgeInsetsGeometry getPadding(BuildContext context) {
    if (isMobile(context)) {
      // return const EdgeInsets.symmetric(horizontal: 22, vertical: 31);
      return const EdgeInsets.only(left: 22, right: 22, top: 31);
    }
    if (isTablet(context)) {
      return const EdgeInsets.only(left: 22, right: 22, top: 31);
    }
    if (isPC(context)) {
      return const EdgeInsets.only(left: 61, right: 61, top: 70);
    }
    return const EdgeInsets.all(32.0);
  }

  static double getMaxWidth(BuildContext context) {
    if (isMobile(context)) return getWidth(context);
    if (isTablet(context)) return 700;
    return 1200;
  }

  static double getResponsiveMaxWidth(BuildContext context) {
    if (isMobileSmall(context)) return mobileSmall;
    if (isMobileMedium(context)) return mobileMedium;
    if (isMobileLarge(context)) return mobileLarge;
    if (isTablet(context)) return tablet;
    if (isLaptopSmall(context)) return laptopSmall;
    if (isLaptopLarge(context)) return laptopLarge;
    return desktop4K;
  }

  /// Returns true if the device is a PC/laptop based on screen size
  static bool isPC(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= laptopSmall; // Only return true if width is 1024 or above
  }

  /// Returns true if the device is likely a touch device based on screen size
  static bool isTouch(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width <= tablet || // 768 and below
        isMobileSmall(context) ||
        isMobileMedium(context) ||
        isMobileLarge(context) ||
        isTablet(context);
  }
}
