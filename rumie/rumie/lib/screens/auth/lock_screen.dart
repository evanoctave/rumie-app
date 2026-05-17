import 'package:flutter/material.dart';
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
    // Auto-trigger Face ID as soon as the screen appears.
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
    if (!ok) {
      setState(() {
        _loading = false;
        _error = 'Authentication failed.';
      });
    }
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
              const Text(
                'rumie',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 56),
              GestureDetector(
                onTap: _loading ? null : _authenticate,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _loading
                        ? AppColors.primary.withAlpha(30)
                        : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _error != null
                          ? AppColors.red.withAlpha(120)
                          : AppColors.primary.withAlpha(80),
                      width: 1.5,
                    ),
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
              ),
              const SizedBox(height: 20),
              Text(
                _error != null ? 'Tap to try again' : 'Unlock with Face ID',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _error != null
                      ? AppColors.red
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
