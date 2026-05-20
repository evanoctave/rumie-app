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
      transitionDuration: const Duration(milliseconds: 320),
    );
  }

  void _socialSnack(BuildContext context, String provider) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider sign-in coming soon — use email for now.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Decorative blobs ───────────────────────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: _Blob(size: 280, color: AppColors.softPurple, opacity: 1.0)
                .animate()
                .scale(begin: const Offset(0.6, 0.6), end: const Offset(1, 1),
                    duration: 900.ms, curve: Curves.easeOutCubic)
                .fadeIn(duration: 600.ms),
          ),
          Positioned(
            top: 120,
            left: -50,
            child: const _Blob(size: 160, color: AppColors.softPink, opacity: 0.85)
                .animate()
                .scale(begin: const Offset(0.4, 0.4), end: const Offset(1, 1),
                    delay: 120.ms, duration: 800.ms, curve: Curves.easeOutCubic)
                .fadeIn(delay: 120.ms, duration: 600.ms),
          ),
          Positioned(
            bottom: size.height * 0.32,
            right: -30,
            child: const _Blob(size: 130, color: AppColors.softGreen, opacity: 0.9)
                .animate()
                .scale(begin: const Offset(0.4, 0.4), end: const Offset(1, 1),
                    delay: 200.ms, duration: 800.ms, curve: Curves.easeOutCubic)
                .fadeIn(delay: 200.ms, duration: 600.ms),
          ),
          Positioned(
            bottom: size.height * 0.18,
            left: -40,
            child: const _Blob(size: 110, color: AppColors.softYellow, opacity: 0.8)
                .animate()
                .scale(begin: const Offset(0.4, 0.4), end: const Offset(1, 1),
                    delay: 300.ms, duration: 800.ms, curve: Curves.easeOutCubic)
                .fadeIn(delay: 300.ms, duration: 600.ms),
          ),

          // ── Main content ───────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height
                      - MediaQuery.of(context).padding.top
                      - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 64),
                      _buildBrand(),
                      const Spacer(),
                      _buildActionSection(context),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        ShaderMask(
          shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
          child: Text(
            'rumie',
            style: GoogleFonts.dmSans(
              fontSize: 60,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -3,
              height: 1.0,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 20),
        // Headline
        Text(
          'Find your\npeople.',
          style: GoogleFonts.dmSans(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            letterSpacing: -1.8,
            height: 1.1,
          ),
        )
            .animate()
            .fadeIn(delay: 80.ms, duration: 500.ms)
            .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 14),
        // Subline
        Text(
          'Match with roommates, discover listings,\nand move in with confidence.',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.55,
          ),
        )
            .animate()
            .fadeIn(delay: 160.ms, duration: 500.ms),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Column(
      children: [
        // Social logins
        _SocialButton(
          label: 'Continue with Google',
          iconWidget: const _GoogleG(),
          onTap: () => _socialSnack(context, 'Google'),
        ).animate().fadeIn(delay: 250.ms, duration: 400.ms).slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 10),
        _SocialButton(
          label: 'Continue with Apple',
          iconWidget: Icon(Icons.apple_rounded, color: AppColors.text, size: 22),
          onTap: () => _socialSnack(context, 'Apple'),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 20),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.border, thickness: 1.5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'or',
                style: GoogleFonts.dmSans(
                  color: AppColors.gray,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.border, thickness: 1.5)),
          ],
        ).animate().fadeIn(delay: 340.ms, duration: 300.ms),
        const SizedBox(height: 20),

        // Primary CTA — Create Account
        _TapButton(
          onTap: () => _showRoleSheet(context),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.buttonShadow,
            ),
            child: Text(
              'Create an Account',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 390.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),
        const SizedBox(height: 14),

        // Secondary CTA — Sign In
        _TapButton(
          onTap: () => Navigator.push(context, slideRoute(const LoginScreen())),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Sign in with Email',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 440.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

        const SizedBox(height: 20),
        Text(
          'By continuing, you agree to our Terms & Privacy Policy.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            color: AppColors.gray,
            fontSize: 11.5,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
      ],
    );
  }

  void _showRoleSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _RoleSheet(
        onSelect: (role) {
          Navigator.pop(context);
          Navigator.push(context, slideRoute(SignupScreen(role: role)));
        },
      ),
    );
  }
}

// ── Decorative blob ────────────────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Blob({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Social button ──────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget iconWidget;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.iconWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _TapButton(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Google "G" icon ────────────────────────────────────────────────────────────

class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4285F4),
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ── Tap wrapper with spring press ──────────────────────────────────────────────

class _TapButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapButton({required this.child, required this.onTap});

  @override
  State<_TapButton> createState() => _TapButtonState();
}

class _TapButtonState extends State<_TapButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

// ── Role chooser sheet ─────────────────────────────────────────────────────────

class _RoleSheet extends StatelessWidget {
  final void Function(Role) onSelect;

  const _RoleSheet({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 12, 24, MediaQuery.of(context).padding.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'I want to...',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose your path to get started.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          _RoleTile(
            emoji: '🏠',
            title: 'Find a room',
            sub: 'Looking for a room or shared space',
            accentColor: AppColors.primary,
            accentBg: AppColors.softPurple,
            onTap: () => onSelect(Role.rumie),
          ),
          const SizedBox(height: 12),
          _RoleTile(
            emoji: '🔑',
            title: 'List a property',
            sub: 'I have a room or property to rent out',
            accentColor: AppColors.green,
            accentBg: AppColors.softGreen,
            onTap: () => onSelect(Role.landlord),
          ),
        ],
      ),
    );
  }
}

class _RoleTile extends StatefulWidget {
  final String emoji;
  final String title;
  final String sub;
  final Color accentColor;
  final Color accentBg;
  final VoidCallback onTap;

  const _RoleTile({
    required this.emoji,
    required this.title,
    required this.sub,
    required this.accentColor,
    required this.accentBg,
    required this.onTap,
  });

  @override
  State<_RoleTile> createState() => _RoleTileState();
}

class _RoleTileState extends State<_RoleTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { HapticFeedback.selectionClick(); setState(() => _pressed = true); },
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutBack,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: widget.accentBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(widget.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.sub,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: widget.accentColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
