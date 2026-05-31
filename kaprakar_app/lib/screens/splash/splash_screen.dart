import 'dart:async';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../onboarding/language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _dotColor = Color(0xBF006D77); // ~0.75 opacity teal
  static const Duration _logoAnimDuration = Duration(milliseconds: 900);
  static const Duration _dotsLoopDuration = Duration(milliseconds: 900);
  static const Duration _fadeToLoginDuration = Duration(milliseconds: 380);

  late final AnimationController _logoController;
  late final AnimationController _dotsController;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoSlide;

  late final Animation<double> _dotsOpacity;
  late final Animation<double> _dot1;
  late final Animation<double> _dot2;
  late final Animation<double> _dot3;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: _logoAnimDuration,
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: _dotsLoopDuration,
    );

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );

    _logoScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // Dots should appear only after logo is clearly visible.
    _dotsOpacity = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.70, 1.00, curve: Curves.easeIn),
    );

    _dot1 = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _dotsController, curve: const Interval(0.00, 0.60, curve: Curves.easeInOut)),
    );
    _dot2 = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _dotsController, curve: const Interval(0.15, 0.75, curve: Curves.easeInOut)),
    );
    _dot3 = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _dotsController, curve: const Interval(0.30, 0.90, curve: Curves.easeInOut)),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // 1) Logo animation
    await _logoController.forward();

    // 2) Start dots and let them complete at least one loop
    if (!mounted) return;
    _dotsController.repeat();

    // Ensure at least one full loop + a small extra pause so it feels intentional
    _navTimer = Timer(_dotsLoopDuration + const Duration(milliseconds: 450), _goToLogin);
  }

  void _goToLogin() async {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        settings: const RouteSettings(name: AppRoutes.languageSelection),
        pageBuilder: (context, animation, secondaryAnimation) => const LanguageSelectionScreen(),
        transitionDuration: _fadeToLoginDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _logoController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Bigger than before. Still clamps so it won’t explode on tablets.
    final logoWidth = (size.width * 0.92).clamp(280.0, 420.0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              Colors.white,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _logoOpacity,
                  child: SlideTransition(
                    position: _logoSlide,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: SizedBox(
                        width: logoWidth,
                        child: Image.asset(
                          'assets/images/logo_transparent.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          isAntiAlias: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FadeTransition(
                  opacity: _dotsOpacity,
                  child: AnimatedBuilder(
                    animation: _dotsController,
                    builder: (context, _) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Dot(opacity: _dot1.value, color: _dotColor),
                          const SizedBox(width: 8),
                          _Dot(opacity: _dot2.value, color: _dotColor),
                          const SizedBox(width: 8),
                          _Dot(opacity: _dot3.value, color: _dotColor),
                        ],
                      );
                    },
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

class _Dot extends StatelessWidget {
  final double opacity;
  final Color color;

  const _Dot({required this.opacity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
