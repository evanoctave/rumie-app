import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_text.dart';
import '../../widgets/ui/pressable.dart';
import '../../widgets/ui/wordmark.dart';

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

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = ok ? null : 'Authentication failed.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final failed = _error != null;
    final tint = failed ? AppColors.danger : AppColors.accent;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Wordmark(size: 44).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 64),
              Pressable(
                onTap: _loading ? null : _authenticate,
                pressedScale: 0.92,
                semanticLabel: 'Unlock with Face ID',
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!AppMotion.reduced(context) && !failed)
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: tint.withValues(alpha: 0.18)),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.5, 1.5), duration: 1800.ms, curve: Curves.easeOut)
                          .fadeOut(duration: 1800.ms, curve: Curves.easeOut),
                    AnimatedContainer(
                      duration: AppMotion.of(context, AppMotion.base),
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: tint.withValues(alpha: 0.4), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: tint.withValues(alpha: 0.25), blurRadius: 28, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Center(
                        child: _loading
                            ? SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: tint),
                              )
                            : Icon(
                                failed ? Icons.face_retouching_off_rounded : Icons.face_rounded,
                                size: 42,
                                color: tint,
                              ),
                      ),
                    ),
                  ],
                ),
              ).animate().scale(duration: 500.ms, curve: AppMotion.enter, delay: 100.ms),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.base),
                child: Text(
                  key: ValueKey(_error),
                  failed ? 'Tap to try again' : 'Unlock with Face ID',
                  style: AppText.bodyMedium.copyWith(color: failed ? AppColors.danger : AppColors.textSecondary),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }
}
