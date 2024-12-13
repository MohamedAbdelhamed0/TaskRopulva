/// A utility class that provides various page transition animations for Flutter applications.
///
/// This class contains static methods that return [PageRouteBuilder] objects with
/// different transition animations. These can be used when navigating between screens
/// to create smooth and visually appealing transitions.
///
/// Available transitions:
/// * [slideRightToLeft] - Slides the new page in from right to left
/// * [slideBottomToTop] - Slides the new page in from bottom to top
/// * [fade] - Fades the new page in
/// * [scale] - Scales the new page from small to full size
/// * [fadeAndScale] - Combines fade and scale animations
///
/// Example usage:
/// ```dart
/// Navigator.of(context).push(
///   TransitionHelper.slideRightToLeft(
///     page: NextScreen(),
///     duration: Duration(milliseconds: 300),
///   ),
/// );
/// ```
import 'package:flutter/material.dart';

class TransitionHelper {
  // Slide transition from right to left (default)
  static PageRouteBuilder slideRightToLeft({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  // Slide transition from bottom to top
  static PageRouteBuilder slideBottomToTop({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  // Fade transition
  static PageRouteBuilder fade({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  // Scale transition
  static PageRouteBuilder scale({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  // Combined fade and scale transition
  static PageRouteBuilder fadeAndScale({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }
}
