import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
        position: Tween(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  void _socialSnack(BuildContext context, String provider) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cardBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          side: BorderSide(color: AppColors.border),
        ),
        content: Text(
          '$provider sign-in coming soon — use email for now.',
          style: const TextStyle(color: AppColors.text, fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height
                  - MediaQuery.of(context).padding.top
                  - MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 72),
                  _buildBrand(),
                  const Spacer(),
                  _buildSocialSection(context),
                  const SizedBox(height: 20),
                  _buildDivider(),
                  const SizedBox(height: 20),
                  _buildPrimaryButton(
                    label: 'Sign in with Email',
                    onTap: () => Navigator.push(context, slideRoute(const LoginScreen())),
                  ).animate().fadeIn(delay: 250.ms, duration: 300.ms),
                  const SizedBox(height: 12),
                  _buildSecondaryButton(
                    label: 'Create an Account',
                    onTap: () => _showRoleSheet(context),
                  ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'rumie',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: AppColors.secondary,
            letterSpacing: -3.0,
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.15, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: 8),
        const Text(
          'Find your ideal roommate.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
        const SizedBox(height: 4),
        const Text(
          'Swipe, match, and chat.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 160.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildSocialSection(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label: 'Continue with Google',
          button: true,
          child: _SocialButton(
            label: 'Continue with Google',
            iconWidget: const _GoogleG(),
            onTap: () => _socialSnack(context, 'Google'),
          ),
        ),
        const SizedBox(height: 10),
        Semantics(
          label: 'Continue with Apple',
          button: true,
          child: _SocialButton(
            label: 'Continue with Apple',
            iconWidget: const Icon(Icons.apple, color: AppColors.text, size: 20),
            onTap: () => _socialSnack(context, 'Apple'),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or',
            style: TextStyle(color: AppColors.textSecondary.withAlpha(140), fontSize: 13),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onTap}) {
    return _TapButton(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({required String label, required VoidCallback onTap}) {
    return _TapButton(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.fromBorderSide(BorderSide(color: AppColors.border, width: 1.5)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }

  void _showRoleSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

// ── Social button ─────────────────────────────────────────────────────────────

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
        height: 56,
        decoration: const BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
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

// ── Google "G" icon ───────────────────────────────────────────────────────────

class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.secondary,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ── Generic tap wrapper ───────────────────────────────────────────────────────

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
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

// ── Role chooser sheet ────────────────────────────────────────────────────────

class _RoleSheet extends StatelessWidget {
  final void Function(Role) onSelect;

  const _RoleSheet({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 20, 24, MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: const BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
          ),
          const Text(
            'I want to...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          _RoleTile(
            emoji: '🏠',
            title: 'Find a room',
            sub: "Looking for a room or shared space",
            onTap: () => onSelect(Role.rumie),
          ),
          const SizedBox(height: 10),
          _RoleTile(
            emoji: '🔑',
            title: 'List a property',
            sub: 'I have a room or property to rent out',
            onTap: () => onSelect(Role.landlord),
          ),
        ],
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String sub;
  final VoidCallback onTap;

  const _RoleTile({
    required this.emoji,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(80),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
