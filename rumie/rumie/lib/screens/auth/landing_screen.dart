import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/models/role.dart';
import '../../theme/app_colors.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _pageController = PageController(viewportFraction: 0.82);
  int _selectedIndex = 0;

  final _cards = const [
    _RoleCard(
      role: Role.rumie,
      emoji: '🏠',
      headline: 'Find a place\nto call home.',
      sub: "I'm looking for a room or shared space.",
    ),
    _RoleCard(
      role: Role.landlord,
      emoji: '🔑',
      headline: 'Rent out\nyour space.',
      sub: "I have a room or property to list.",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) => setState(() => _selectedIndex = index);

  Role get _selectedRole => _cards[_selectedIndex].role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 52),
            _buildLogo(),
            const SizedBox(height: 8),
            _buildSubtitle(),
            const SizedBox(height: 48),
            _buildCards(),
            const SizedBox(height: 20),
            _buildDots(),
            const Spacer(),
            _buildButtons(),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return const Text(
      'rumie',
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w900,
        color: AppColors.text,
        letterSpacing: -1.5,
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildSubtitle() {
    return const Text(
      'Your next chapter starts here.',
      style: TextStyle(
        fontSize: 15,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 400.ms);
  }

  Widget _buildCards() {
    return SizedBox(
      height: 320,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _cards.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, i) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double scale = 1.0;
              if (_pageController.position.haveDimensions) {
                final delta = (_pageController.page! - i).abs();
                scale = (1.0 - delta * 0.06).clamp(0.92, 1.0);
              }
              return Transform.scale(scale: scale, child: child);
            },
            child: _cards[i],
          );
        },
      ),
    ).animate().fadeIn(delay: 250.ms, duration: 500.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_cards.length, (i) {
        final selected = i == _selectedIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: selected ? 20 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          _PrimaryButton(
            label: 'Create Account',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SignupScreen(role: _selectedRole),
              ),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            child: const Text(
              'Already have an account? Log in',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }
}

class _RoleCard extends StatelessWidget {
  final Role role;
  final String emoji;
  final String headline;
  final String sub;

  const _RoleCard({
    required this.role,
    required this.emoji,
    required this.headline,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withAlpha(60), width: 1),
                ),
                child: Text(
                  role == Role.rumie ? 'Roommate' : 'Landlord',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
