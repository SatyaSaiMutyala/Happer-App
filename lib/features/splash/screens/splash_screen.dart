import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happer_app/features/auth/screens/register_screen.dart';
import 'package:happer_app/features/dashboard/screens/dashboard_screen.dart';

/// Animated brand splash: the Happer "H" mark fades and scales in with a white
/// circular loader spinning around it, then routes to the right entry screen
/// after 3 seconds.
class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;

  const SplashScreen({super.key, required this.isLoggedIn});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Intro: logo fade + scale.
  late final AnimationController _introController;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  // Continuous rotation for the loader ring.
  late final AnimationController _spinController;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoFade = CurvedAnimation(parent: _introController, curve: Curves.easeIn);
    _logoScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _introController.forward();
    _scheduleNavigation();
  }

  Future<void> _scheduleNavigation() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) =>
            widget.isLoggedIn ? const DashboardScreen() : RegisterScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating white loader ring around the logo.
                FadeTransition(
                  opacity: _logoFade,
                  child: RotationTransition(
                    turns: _spinController,
                    child: CustomPaint(
                      size: const Size(170, 170),
                      painter: _ArcLoaderPainter(),
                    ),
                  ),
                ),
                // The logo mark (fades + scales in).
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Image.asset(
                      'assets/images/singleLogo.png',
                      width: 92,
                      height: 92,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws a faint full track plus a brighter white sweeping arc — the arc spins
/// (via RotationTransition) to read as a loader.
class _ArcLoaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Faint background track.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawCircle(center, radius, track);

    // Bright sweeping arc (~90°).
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;
    canvas.drawArc(rect, -1.5708, 1.6, false, arc); // start at top, sweep ~92°
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
