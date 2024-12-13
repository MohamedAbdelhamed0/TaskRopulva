/// A splash screen widget that displays an animated logo, app title, author information,
/// and version details with a starfield background effect.
///
/// The splash screen includes:
/// * An animated starfield background
/// * A scaling app logo animation
/// * Fade-in animations for app title, author info, and version
/// * Automatic navigation to the main task list screen after a delay
///
/// Configuration constants are defined in [AnimationConstants] class.
///
/// Example:
/// ```dart
/// MaterialApp(
///   home: SplashScreen(),
/// )
/// ```
///
/// The screen consists of multiple components:
/// * [StarField] - Creates an animated background of moving stars
/// * [SplashContent] - Contains the main content with animations
/// * [Star] - Represents individual star objects in the background
///
/// After [AnimationConstants.splashDuration], the screen automatically transitions
/// to [TaskListScreen] using a bottom-to-top slide animation.
///
/// For desktop platforms, the subsequent screen is wrapped in a [CustomWindowFrame]
/// and for all platforms, it's wrapped in a [ConnectivityWrapper].
///
/// See also:
/// * [AnimationConstants] - Contains timing configurations for animations
/// * [VersionHelper] - Handles version information display
/// * [TransitionHelper] - Manages screen transition animations
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_ropulva_todo_app/app/presentation/screens/task_list_screen.dart';

import '../services/transition_helper.dart'; // Add this import
import '../services/version_helper.dart';
import '../services/window_helper.dart';
import '../themes/colors.dart';
import '../widgets/connectivity_wrapper.dart';
import '../widgets/custom_window_frame.dart';

class AnimationConstants {
  static const splashDuration = Duration(seconds: 4);
  static const navigationDuration = Duration(milliseconds: 800);
  static const logoScaleFirstDuration = Duration(seconds: 1);
  static const logoScaleSecondDuration = Duration(seconds: 1);
  static const textFadeInDuration = Duration(seconds: 2);
  static const authorFadeInDuration = Duration(seconds: 2, milliseconds: 500);
  static const versionFadeInDuration = Duration(seconds: 3);

  static const starFieldAnimationDuration = 10.0;
  static const numberOfStars = 150;
}

class Star {
  double x;
  double y;
  double speed;
  double size;
  Color color;

  Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
  });

  static List<Color> get starColors => [
        Colors.white,
        Colors.blue[200]!,
        Colors.purple[200]!,
        Colors.yellow[200]!,
      ];
}

class StarField extends StatefulWidget {
  final Size screenSize;
  const StarField({super.key, required this.screenSize});

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField> with TickerProviderStateMixin {
  final List<Star> _stars = [];
  late final AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeStars();
    _initializeAnimation();
  }

  void _initializeStars() {
    for (int i = 0; i < AnimationConstants.numberOfStars; i++) {
      _stars.add(Star(
        x: _random.nextDouble() * widget.screenSize.width,
        y: _random.nextDouble() * widget.screenSize.height,
        speed: _random.nextDouble() * 2 + 0.5,
        size: _random.nextDouble() * 3 + 1,
        color: Star.starColors[_random.nextInt(Star.starColors.length)],
      ));
    }
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
          seconds: AnimationConstants.starFieldAnimationDuration.toInt()),
    )..repeat();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: StarPainter(_stars, _controller.value),
        size: Size.infinite,
      );
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animation;

  const StarPainter(this.stars, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final paint = Paint()..color = star.color.withOpacity(0.6);
      double y = (star.y + (animation * star.speed * 100)) % size.height;
      double twinkle = (sin(animation * 5 + star.x) + 1) / 2;

      paint.color = paint.color.withOpacity(0.3 + (twinkle * 0.7));
      canvas.drawCircle(
        Offset(star.x, y),
        star.size * (0.8 + (twinkle * 0.4)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) => true;
}

class SplashContent extends StatelessWidget {
  final String formattedVersion;

  const SplashContent({super.key, required this.formattedVersion});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        _buildAnimatedLogo(),
        _buildAppTitle(context),
        const Spacer(),
        _buildAuthorInfo(context),
        _buildVersionInfo(context),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAnimatedLogo() => Image.asset(
        'assets/images/logo.png',
        width: 200,
        height: 100,
      )
          .animate()
          .scale(
            duration: AnimationConstants.logoScaleFirstDuration,
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.2, 1.2),
          )
          .then()
          .scale(
            duration: AnimationConstants.logoScaleSecondDuration,
            begin: const Offset(1.2, 1.2),
            end: const Offset(1.0, 1.0),
          );

  Widget _buildAppTitle(BuildContext context) => Text(
        'Todo App',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      )
          .animate()
          .fadeIn(delay: AnimationConstants.textFadeInDuration)
          .slideY(begin: 0.3, end: 0);

  Widget _buildAuthorInfo(BuildContext context) => Text(
        'By\nMohamed Abdelhamed',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
      )
          .animate()
          .fadeIn(delay: AnimationConstants.authorFadeInDuration)
          .slideY(begin: 0.3, end: 0)
          .then()
          .shimmer(
            duration: const Duration(seconds: 1),
            color: Colors.white.withOpacity(0.5),
          );

  Widget _buildVersionInfo(BuildContext context) => Text(
        formattedVersion,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
      )
          .animate()
          .fadeIn(delay: AnimationConstants.versionFadeInDuration)
          .slideY(begin: 0.3, end: 0);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final VersionHelper _versionHelper = VersionHelper();

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _initVersion();
    _scheduleNavigation();
  }

  Future<void> _initVersion() async {
    await _versionHelper.init();
    if (mounted) setState(() {});
  }

  void _scheduleNavigation() {
    Future.delayed(AnimationConstants.splashDuration, () {
      Navigator.of(context).pushReplacement(
        TransitionHelper.slideBottomToTop(
          page: WindowHelper.isDesktopPlatform
              ? const CustomWindowFrame(
                  title: 'Todo App',
                  child: ConnectivityWrapper(child: TaskListScreen()),
                )
              : const ConnectivityWrapper(child: TaskListScreen()),
          duration: AnimationConstants.navigationDuration,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: MyColors.black,
      body: Stack(
        children: [
          StarField(screenSize: screenSize),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Center(
              child: SplashContent(
                formattedVersion: _versionHelper.formattedVersion,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
