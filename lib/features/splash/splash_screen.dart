import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:productloop/core/storage/hive_service.dart';
import 'package:productloop/features/dashboard/dashboard_screen.dart';
import 'package:productloop/features/intro/intro_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _titleController;
  late AnimationController _sloganController;

  late Animation<double> _iconScale;
  late Animation<double> _iconOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleOpacity;
  late Animation<double> _sloganOpacity;
  late Animation<Offset> _sloganSlide;

  @override
  void initState() {
    super.initState();

    // Icon animation: scale + fade in
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _iconScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOutBack),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOut),
    );

    // Title animation: slide up + fade in
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );

    // Slogan animation: fade in + subtle slide
    _sloganController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _sloganOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sloganController, curve: Curves.easeOut),
    );
    _sloganSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _sloganController, curve: Curves.easeOutCubic),
    );

    _playAnimations();
  }

  Future<void> _playAnimations() async {
    // Staggered entrance
    await Future.delayed(const Duration(milliseconds: 100));
    _iconController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _titleController.forward();

    await Future.delayed(const Duration(milliseconds: 250));
    _sloganController.forward();

    // Hold the splash for a moment after all animations complete
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Route based on whether the user has seen the intro
    final hasSeenIntro = HiveService().hasSeenIntro;
    final Widget destination = hasSeenIntro
        ? const DashboardScreen()
        : const IntroScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    _titleController.dispose();
    _sloganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A021F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon
            AnimatedBuilder(
              animation: _iconController,
              builder: (context, child) {
                return Opacity(
                  opacity: _iconOpacity.value,
                  child: Transform.scale(
                    scale: _iconScale.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFAB5CFA),
                            Color(0xFF9333EA),
                            Color(0xFF6B21A8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9333EA).withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.all_inclusive_rounded,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Animated Title
            SlideTransition(
              position: _titleSlide,
              child: FadeTransition(
                opacity: _titleOpacity,
                child: Text(
                  'ProductLoop',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Animated Slogan
            SlideTransition(
              position: _sloganSlide,
              child: FadeTransition(
                opacity: _sloganOpacity,
                child: Text(
                  'Discover smarter with every tap.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
