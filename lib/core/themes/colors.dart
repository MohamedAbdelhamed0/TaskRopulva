import 'dart:ui';

class MyColors {
  /// Black color used for headline, task card header, create new task, and task date.
  static const black = Color(0xFF000000);

  /// Green color used for button, add task button, and not selected chip with opacity.
  static const green = Color(0xFF00CA5D);

  /// White color used for background.
  static const white = Color(0xFFFFFFFF);

  /// Light green color used for text, save task button, selected chip, and text chip.
  static const lightGreen = Color(0xFF4ECB71);

  /// Grey color used for border and form field background.
  static const grey = Color(0xFFD9D9D9);

  /// Off white color used for background and card background.
  static const offWhite = Color(0xFFFDFDFD);

  /// Orange color used for button and close icon.
  static const orange = Color(0xFFF24E1E);

  /// Dark background color used for app background in dark mode
  static const darkBackground = Color(0xFF121212);

  /// Dark surface color used for cards and elevated surfaces in dark mode
  static const darkSurface = Color(0xFF1E1E1E);

  /// Dark grey color used for borders and form fields in dark mode
  static const darkGrey = Color(0xFF2C2C2C);

  /// Dark text color used for text content in dark mode
  static const darkText = Color(0xFFE1E1E1);

  /// Dark green color used for primary actions and buttons in dark mode
  static const darkGreen = Color(0xFF00A54C);

  /// Dark light green color used for secondary actions and selected states in dark mode
  static const darkLightGreen = Color(0xFF3AA861);

  static Color withOpacityPercentage(Color color, int percentage) {
    return color.withOpacity(percentage / 100);
  }
}

class CustomColorScheme {
  final bool isDark;
  const CustomColorScheme({this.isDark = false});

  Color get background => isDark ? MyColors.darkBackground : MyColors.white;
  Color get surface => isDark ? MyColors.darkSurface : MyColors.offWhite;
  Color get onSurface => isDark ? MyColors.darkText : MyColors.black;
  Color get primary => isDark ? MyColors.darkGreen : MyColors.green;
  Color get onPrimary => MyColors.white;
  Color get secondary => isDark ? MyColors.darkLightGreen : MyColors.lightGreen;
  Color get grey => isDark ? MyColors.darkGrey : MyColors.grey;
  Color get shadow => isDark ? MyColors.darkBackground : MyColors.offWhite;
  Brightness get brightness => isDark ? Brightness.dark : Brightness.light;
}
