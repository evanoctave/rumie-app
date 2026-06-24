import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';
import 'trait_chip.dart';

class DiscoverCard extends StatelessWidget {
  final Roommate roommate;
  final int index;
  final VoidCallback onPass;
  final VoidCallback onConnect;
  final VoidCallback onTap;

  const DiscoverCard({
    super.key,
    required this.roommate,
    required this.index,
    required this.onPass,
    required this.onConnect,
    required this.onTap,
  });

  (String, String) get _nameParts {
    final idx = roommate.name.indexOf(' ');
    if (idx == -1) return (roommate.name, '');
    return (roommate.name.substring(0, idx), roommate.name.substring(idx + 1));
  }

  @override
  Widget build(BuildContext context) {
    final (first, last) = _nameParts;
    final num = (index + 1).toString().padLeft(2, '0');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: AppColors.cardShadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: -8,
              child: Opacity(
                opacity: 0.05,
                child: Text(
                  num,
                  style: GoogleFonts.syne(
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    letterSpacing: -4,
                    height: 1,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${first.toUpperCase()}\n',
                        style: GoogleFonts.syne(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          letterSpacing: -1.5,
                          height: 0.95,
                        ),
                      ),
                      if (last.isNotEmpty)
                        TextSpan(
                          text: last.toUpperCase(),
                          style: GoogleFonts.syne(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                            letterSpacing: -1.5,
                            height: 0.95,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Divider(color: AppColors.border, thickness: 1.5, height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Stat(value: '${roommate.age}', label: 'AGE'),
                    _Stat(value: roommate.location, label: 'LOCATION'),
                    _Stat(value: '\$${roommate.budget}', label: 'BUDGET'),
                  ],
                ),
                const SizedBox(height: 10),
                if (roommate.traits.isNotEmpty)
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: roommate.traits.asMap().entries.map((e) =>
                      TraitChip(trait: e.value, accent: e.key == 0),
                    ).toList(),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CardBtn(
                        label: 'PASS',
                        primary: false,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onPass();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _CardBtn(
                        label: 'CONNECT →',
                        primary: true,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onConnect();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.syne(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBtn extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _CardBtn({required this.label, required this.primary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary ? AppColors.btnPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: primary ? AppColors.btnPrimary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: primary ? AppColors.btnPrimaryText : AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
