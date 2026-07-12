import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:happer_app/features/auth/screens/register_screen.dart';
import 'package:happer_app/features/dashboard/screens/dashboard_screen.dart';

/// Brand splash: plays the Lottie intro animation, then routes to the right
/// entry screen when the animation finishes (with a safety-net timeout).
class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;

  const SplashScreen({super.key, required this.isLoggedIn});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    // Safety net: if the animation fails to load, still route after 6 seconds
    // (it plays in 4s and routes on completion before this fires).
    Future.delayed(const Duration(seconds: 6), _goNext);
  }

  void _goNext() {
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
    _controller.dispose();
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
          child: Lottie.asset(
            'assets/animations/splash.json',
            controller: _controller,
            // contain (not cover) keeps the full frame visible and centered on
            // every aspect ratio — iPhone, Android, tablets — with no cropping.
            // The frame's own black background blends into the scaffold, so the
            // letterbox is invisible.
            fit: BoxFit.contain,
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            onLoaded: (composition) {
              // Play the full animation compressed into 4 seconds (the source
              // is ~7s) by driving the controller with a fixed 4s duration.
              _controller
                ..duration = const Duration(seconds: 4)
                ..forward();
              // Route as soon as the animation finishes playing once.
              _controller.addStatusListener((status) {
                if (status == AnimationStatus.completed) _goNext();
              });
            },
            errorBuilder: (context, error, stackTrace) {
              // If the animation can't be decoded, don't block the user.
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _goNext());
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
