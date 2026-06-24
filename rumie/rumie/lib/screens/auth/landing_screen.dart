import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/role.dart';
import '../../theme/app_colors.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static PageRoute<T> slideRoute<T>(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (ctx, anim, sec) => screen,
      transitionsBuilder: (ctx, anim, sec, child) => SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'ru',
                      style: GoogleFonts.syne(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -2,
                      ),
                    ),
                    TextSpan(
                      text: 'mie',
                      style: GoogleFonts.syne(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                        letterSpacing: -2,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.1, duration: 400.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 8),
              Text(
                'Find your perfect roommate.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 80.ms, duration: 400.ms),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NO GUESSWORK.\nJUST ROOMMATES.',
                      style: GoogleFonts.syne(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: AppColors.border, thickness: 1.5, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _Pill('Discover'),
                        const SizedBox(width: 6),
                        _Pill('Connect'),
                        const SizedBox(width: 6),
                        _Pill('Move in', accent: true),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 160.ms, duration: 400.ms)
                  .slideY(
                    begin: 0.06,
                    delay: 160.ms,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 32),

              _PrimaryBtn(
                label: 'GET STARTED →',
                onTap: () => Navigator.push(
                  context,
                  slideRoute(const SignupScreen(role: Role.rumie)),
                ),
              ).animate().fadeIn(delay: 240.ms, duration: 300.ms),

              const SizedBox(height: 10),

              _OutlineBtn(
                label: 'SIGN IN',
                onTap: () => Navigator.push(
                  context,
                  slideRoute(const LoginScreen()),
                ),
              ).animate().fadeIn(delay: 280.ms, duration: 300.ms),

              const SizedBox(height: 16),
              Center(
                child: Text(
                  'By continuing you agree to our Terms of Service.',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool accent;
  const _Pill(this.label, {this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accent ? AppColors.accent : AppColors.chipBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: accent ? const Color(0xFFF2F0EB) : AppColors.chipText,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.btnPrimary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.btnPrimaryText,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: double.infinity,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderSoft, width: 1.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
