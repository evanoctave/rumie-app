import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'ui/app_button.dart';
import 'ui/reveal.dart';

/// Centered spinner used while a screen's first load is in flight.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.accent),
      ),
    );
  }
}

/// Error state. [message] must be user-safe (see `userMessage`).
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
        child: Reveal(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(color: AppColors.dangerSoft, shape: BoxShape.circle),
                child: Icon(Icons.wifi_off_rounded, color: AppColors.danger, size: 34),
              ),
              const SizedBox(height: 22),
              Text(message, style: AppText.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 22),
              AppButton(
                label: 'Try again',
                style: AppButtonStyle.tonal,
                size: AppButtonSize.medium,
                expand: false,
                onTap: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
