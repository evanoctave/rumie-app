import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../widgets/trait_chip.dart';

class ProfileViewScreen extends StatelessWidget {
  final Roommate roommate;
  const ProfileViewScreen({super.key, required this.roommate});

  static PageRoute<void> route(Roommate r) {
    return PageRouteBuilder(
      pageBuilder: (_, anim, sec) => ProfileViewScreen(roommate: r),
      transitionsBuilder: (_, anim, sec, child) => SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      '←',
                      style: GoogleFonts.syne(
                          fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'PROFILE',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roommate.name.toUpperCase(),
                      style: GoogleFonts.syne(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -2,
                        height: 0.95,
                      ),
                    ),
                    Text(
                      '${roommate.age} · ${roommate.location}',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: AppColors.border, thickness: 1.5, height: 1),
                    const SizedBox(height: 20),

                    const _SectionLabel('PHOTOS'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, _) => _PhotoPlaceholder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const _SectionLabel('DETAILS'),
                    const SizedBox(height: 8),
                    _StatsGrid(roommate: roommate),
                    const SizedBox(height: 20),

                    if (roommate.traits.isNotEmpty) ...[
                      const _SectionLabel('TRAITS'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: roommate.traits.asMap().entries.map((e) =>
                          TraitChip(trait: e.value, accent: e.key == 0),
                        ).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (roommate.bio.isNotEmpty) ...[
                      const _SectionLabel('BIO'),
                      const SizedBox(height: 8),
                      Text(
                        roommate.bio,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.text, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
              ),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
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
                    'CONNECT →',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.btnPrimaryText,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 2,
        ),
      );
}

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderSoft, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        'PHOTO',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Roommate roommate;
  const _StatsGrid({required this.roommate});

  @override
  Widget build(BuildContext context) {
    final cells = [
      ('\$${roommate.budget}/mo', 'BUDGET'),
      ('${roommate.age}', 'AGE'),
      (roommate.location, 'LOCATION'),
      ('Flexible', 'MOVE-IN'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.4,
      children: cells.map((c) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderSoft, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              c.$1,
              style: GoogleFonts.syne(
                  fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text),
            ),
            Text(
              c.$2,
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
