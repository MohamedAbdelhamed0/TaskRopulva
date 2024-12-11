import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_ropulva_todo_app/app/presentation/screens/task_list_screen.dart';
import '../services/version_helper.dart'; // Add this import

import '../services/window_helper.dart';
import '../themes/colors.dart';
import '../widgets/connectivity_wrapper.dart';
import '../widgets/custom_window_frame.dart';

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
}

class StarField extends StatefulWidget {
  final Size screenSize;

  const StarField({Key? key, required this.screenSize}) : super(key: key);

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField> with TickerProviderStateMixin {
  final List<Star> stars = [];
  late AnimationController _controller;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _initializeStars();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _controller.addListener(() => setState(() {}));
  }

  void _initializeStars() {
    final starColors = [
      Colors.white,
      Colors.blue[200]!,
      Colors.purple[200]!,
      Colors.yellow[200]!,
    ];

    for (int i = 0; i < 150; i++) {
      // Increased number of stars
      stars.add(Star(
        x: random.nextDouble() * widget.screenSize.width,
        y: random.nextDouble() * widget.screenSize.height,
        speed: random.nextDouble() * 2 + 0.5,
        size: random.nextDouble() * 3 + 1,
        color: starColors[random.nextInt(starColors.length)],
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StarPainter(stars, _controller.value),
      size: Size.infinite,
    );
  }
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animation;

  StarPainter(this.stars, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final paint = Paint()..color = star.color.withOpacity(0.6);

      double y = (star.y + (animation * star.speed * 100)) % size.height;

      // Create a twinkling effect
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
    _initVersion();
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              WindowHelper.isDesktopPlatform
                  ? const CustomWindowFrame(
                      title: 'Todo App',
                      child: ConnectivityWrapper(
                        child: TaskListScreen(),
                      ),
                    )
                  : const TaskListScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Slide from right
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  Future<void> _initVersion() async {
    await _versionHelper.init();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: MyColors.black,
      body: Stack(
        children: [
          // Updated StarField with screen size
          StarField(screenSize: screenSize),
          // Main content
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    height: 100,
                  )
                      .animate()
                      .scale(
                        duration: const Duration(seconds: 1),
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.2, 1.2),
                      )
                      .then()
                      .scale(
                        duration: const Duration(seconds: 1),
                        begin: const Offset(1.2, 1.2),
                        end: const Offset(1.0, 1.0),
                      ),
                  Text(
                    'Todo App',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  )
                      .animate()
                      .fadeIn(delay: const Duration(seconds: 2))
                      .slideY(begin: 0.3, end: 0),
                  Spacer(),
                  Text(
                    'By\nMohamed Abdelhamed',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  )
                      .animate()
                      .fadeIn(
                          delay: const Duration(
                              seconds: 2,
                              milliseconds:
                                  500)) // Delayed slightly after first text
                      .slideY(begin: 0.3, end: 0)
                      .then()
                      .shimmer(
                        // Added shimmer effect
                        duration: const Duration(seconds: 1),
                        color: Colors.white.withOpacity(0.5),
                      ),
                  const SizedBox(height: 4),
                  Text(
                    _versionHelper.formattedVersion,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                  )
                      .animate()
                      .fadeIn(delay: const Duration(seconds: 3))
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
