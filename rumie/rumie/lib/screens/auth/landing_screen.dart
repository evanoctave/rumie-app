import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models/role.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_shapes.dart';
import '../../theme/app_text.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/photo.dart';
import '../../widgets/ui/wordmark.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

/// First screen. A slow-drifting photo wall fades into the paper ground;
/// the wordmark and actions rise in beneath it.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static PageRoute<T> slideRoute<T>(Widget screen) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, _, _) => screen,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, anim, _, child) {
        final curved = CurvedAnimation(parent: anim, curve: AppMotion.enter, reverseCurve: AppMotion.exit);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.56,
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const OverflowBox(
                    alignment: Alignment.topCenter,
                    maxHeight: double.infinity,
                    child: _PhotoWall(),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background.withValues(alpha: 0.35),
                          AppColors.background.withValues(alpha: 0),
                          AppColors.background.withValues(alpha: 0),
                          AppColors.background,
                        ],
                        stops: const [0, 0.18, 0.5, 0.98],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Wordmark(size: 64)
                      .animate()
                      .fadeIn(duration: 500.ms, curve: AppMotion.enter)
                      .slideY(begin: 0.3, duration: 600.ms, curve: AppMotion.enter),
                  const SizedBox(height: 10),
                  Text(
                    'Roommates you’ll actually\nlike living with.',
                    style: AppText.sectionTitle.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ).animate().fadeIn(delay: 120.ms, duration: 500.ms).slideY(begin: 0.3, delay: 120.ms, duration: 600.ms, curve: AppMotion.enter),
                  const SizedBox(height: 32),
                  AppButton(
                    label: 'Get started',
                    onTap: () => Navigator.push(context, slideRoute(const SignupScreen(role: Role.rumie))),
                  ).animate().fadeIn(delay: 240.ms, duration: 400.ms).slideY(begin: 0.4, delay: 240.ms, duration: 600.ms, curve: AppMotion.enter),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'I already have an account',
                    style: AppButtonStyle.secondary,
                    onTap: () => Navigator.push(context, slideRoute(const LoginScreen())),
                  ).animate().fadeIn(delay: 320.ms, duration: 400.ms).slideY(begin: 0.4, delay: 320.ms, duration: 600.ms, curve: AppMotion.enter),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      'By continuing you agree to our Terms of Service.',
                      style: AppText.caption.copyWith(color: AppColors.textTertiary),
                    ),
                  ).animate().fadeIn(delay: 420.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two columns of photos that drift in opposite directions. Static under
/// reduced motion.
class _PhotoWall extends StatefulWidget {
  const _PhotoWall();

  @override
  State<_PhotoWall> createState() => _PhotoWallState();
}

class _PhotoWallState extends State<_PhotoWall> with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  static const _left = ['assets/images/evan_1.jpg', 'assets/images/p_malik.jpg', 'assets/images/p_devon.jpg'];
  static const _right = ['assets/images/p_marcus.jpg', 'assets/images/evan_4.jpg', 'assets/images/p_darius.jpg'];

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(vsync: this, duration: const Duration(seconds: 28));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _drift.stop();
    } else if (!_drift.isAnimating) {
      _drift.repeat();
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: AnimatedBuilder(
        animation: _drift,
        builder: (context, _) {
          final wave = math.sin(_drift.value * 2 * math.pi);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _column(_left, dy: -26 * wave, startOffset: -30, stagger: 0)),
              const SizedBox(width: 12),
              Expanded(child: _column(_right, dy: 26 * wave, startOffset: 40, stagger: 1)),
            ],
          );
        },
      ),
    );
  }

  Widget _column(List<String> paths, {required double dy, required double startOffset, required int stagger}) {
    return Transform.translate(
      offset: Offset(0, startOffset + dy),
      child: Column(
        children: [
          for (var i = 0; i < paths.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AspectRatio(
                aspectRatio: 0.8,
                child: ClipRSuperellipse(
                  borderRadius: AppShapes.radius(AppShapes.photo),
                  child: RumiePhoto(path: paths[i], fallbackName: '?'),
                ),
              ).animate().fadeIn(delay: (80 * (i * 2 + stagger)).ms, duration: 700.ms, curve: AppMotion.enter).scale(
                    begin: const Offset(0.94, 0.94),
                    delay: (80 * (i * 2 + stagger)).ms,
                    duration: 800.ms,
                    curve: AppMotion.enter,
                  ),
            ),
        ],
      ),
    );
  }
}
