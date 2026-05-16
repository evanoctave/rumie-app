import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../widgets/listing_card.dart';

/// Browse view: full list of available roommates as cards. Tap a card
/// to open a detail sheet. Separate from the Swiping tab.
class ListingsScreen extends StatelessWidget {
  const ListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (rect) =>
                      AppColors.brandGradient.createShader(rect),
                  child: const Text(
                    'Listings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('🏠', style: TextStyle(fontSize: 24)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.softPink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${sampleRoommates.length} nearby',
                    style: const TextStyle(
                      color: AppColors.pink,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: sampleRoommates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => ListingCard(
                roommate: sampleRoommates[i],
                onTap: () => _showDetail(context, sampleRoommates[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Roommate r) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(roommate: r),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  final Roommate roommate;
  const _DetailSheet({required this.roommate});

  @override
  Widget build(BuildContext context) {
    final r = roommate;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: r.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(r.emoji, style: const TextStyle(fontSize: 120)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          r.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${r.age}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 15)),
                        const SizedBox(width: 4),
                        Text(
                          r.location,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.gray,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.softPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '\$${r.budget}/mo',
                            style: const TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      r.bio,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'About them',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: r.traits
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.softPink,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(t.emoji,
                                        style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text(
                                      t.label,
                                      style: const TextStyle(
                                        color: AppColors.darkText,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
