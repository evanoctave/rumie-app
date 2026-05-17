import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await context.read<AuthProvider>().unlockWithBiometrics();

    // Widget may have been removed from the tree if auth succeeded and
    // _LockOverlay already swapped it out — always guard before setState.
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = ok ? null : 'Authentication failed.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const Text(
                'rumie',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                  letterSpacing: -2,
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 60),
              // Face ID button
              GestureDetector(
                onTap: _loading ? null : _authenticate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: _loading
                        ? AppColors.primary.withAlpha(18)
                        : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _error != null
                          ? AppColors.red.withAlpha(140)
                          : AppColors.primary.withAlpha(80),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_error != null ? AppColors.red : AppColors.primary)
                            .withAlpha(_loading ? 20 : 40),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          )
                        : Icon(
                            _error != null
                                ? Icons.face_retouching_off_rounded
                                : Icons.face_rounded,
                            size: 38,
                            color: _error != null
                                ? AppColors.red
                                : AppColors.primary,
                          ),
                  ),
                ),
              ).animate().scale(
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                    delay: 100.ms,
                  ),
              const SizedBox(height: 22),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  key: ValueKey(_error),
                  _error != null ? 'Tap to try again' : 'Unlock with Face ID',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _error != null
                        ? AppColors.red
                        : AppColors.textSecondary,
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }
}
