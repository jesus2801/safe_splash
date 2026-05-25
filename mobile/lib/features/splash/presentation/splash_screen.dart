import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../home/presentation/home_screen.dart';

/// Minimal branded entry: short animation then [HomeScreen].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.85, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _goHome();
  }

  Future<void> _goHome() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    await Navigator.of(context).pushReplacement<void, void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const HomeScreen();
        },
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
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
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.mist, AppColors.foam, AppColors.surface],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Opacity(
                opacity: _opacity.value,
                child: Transform.scale(
                  scale: _scale.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.waves_rounded,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Splash',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.poolDeep,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
