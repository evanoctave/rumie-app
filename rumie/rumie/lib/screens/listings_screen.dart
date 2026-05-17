import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../widgets/listing_card.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  String _selectedType = 'All';

  static const _types = ['All', 'Apartment', 'House', 'Condo', 'Room', 'Duplex', 'Studio'];

  static const _listings = [
    {
      'title': 'Bright private room near campus',
      'type': 'Room',
      'location': 'Westwood, Los Angeles',
      'rent': 1250,
      'bedsBaths': '1 bed / shared bath',
      'availableDate': 'June 1',
    },
    {
      'title': 'Spacious apartment with shared kitchen',
      'type': 'Apartment',
      'location': 'Koreatown, Los Angeles',
      'rent': 1800,
      'bedsBaths': '2 bed / 1 bath',
      'availableDate': 'July 10',
    },
    {
      'title': 'Quiet condo with home office',
      'type': 'Condo',
      'location': 'Pasadena, CA',
      'rent': 2100,
      'bedsBaths': '2 bed / 2 bath',
      'availableDate': 'Now',
    },
    {
      'title': 'Duplex room with private backyard',
      'type': 'Duplex',
      'location': 'El Sereno, Los Angeles',
      'rent': 1450,
      'bedsBaths': '1 bed / 1 bath',
      'availableDate': 'August 1',
    },
    {
      'title': 'Modern studio in downtown',
      'type': 'Studio',
      'location': 'DTLA, Los Angeles',
      'rent': 1650,
      'bedsBaths': 'Studio / 1 bath',
      'availableDate': 'Now',
    },
  ];

  List<Map<String, dynamic>> get _visible => _selectedType == 'All'
      ? _listings.cast<Map<String, dynamic>>()
      : _listings.cast<Map<String, dynamic>>().where((l) => l['type'] == _selectedType).toList();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildFilter(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: _visible.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final l = _visible[index];
                return ListingCard(
                  title: l['title'] as String,
                  type: l['type'] as String,
                  location: l['location'] as String,
                  rent: l['rent'] as int,
                  bedsBaths: l['bedsBaths'] as String,
                  availableDate: l['availableDate'] as String,
                  animationIndex: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Text(
            'Listings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showPostSheet(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Post',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildFilter() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = _types[index];
          final selected = _selectedType == type;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedType = type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 80.ms, duration: 300.ms);
  }

  void _showPostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _PostListingSheet(),
    );
  }
}

class _PostListingSheet extends StatefulWidget {
  const _PostListingSheet();

  @override
  State<_PostListingSheet> createState() => _PostListingSheetState();
}

class _PostListingSheetState extends State<_PostListingSheet> {
  final _titleCtrl     = TextEditingController();
  final _locationCtrl  = TextEditingController();
  final _rentCtrl      = TextEditingController();
  String _type         = 'Apartment';
  String _beds         = '1 bed / 1 bath';
  String _available    = 'Now';

  static const _types = ['Room', 'Apartment', 'Condo', 'House', 'Duplex', 'Studio'];
  static const _bedOptions = ['Studio / 1 bath', '1 bed / 1 bath', '2 bed / 1 bath', '2 bed / 2 bath', '3 bed / 2 bath'];
  static const _availOptions = ['Now', 'June 1', 'July 1', 'August 1', 'Flexible'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _rentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Post a Listing',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sheetField(_titleCtrl, 'Title', 'e.g. Bright room near downtown'),
          const SizedBox(height: 10),
          _sheetField(_locationCtrl, 'Location', 'Neighborhood, City'),
          const SizedBox(height: 10),
          _sheetField(_rentCtrl, 'Rent / mo', '1200', keyboard: TextInputType.number),
          const SizedBox(height: 10),
          _dropdownRow('Type', _types, _type, (v) => setState(() => _type = v!)),
          const SizedBox(height: 10),
          _dropdownRow('Beds / Baths', _bedOptions, _beds, (v) => setState(() => _beds = v!)),
          const SizedBox(height: 10),
          _dropdownRow('Available', _availOptions, _available, (v) => setState(() => _available = v!)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listing posted!'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Post Listing',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetField(
    TextEditingController ctrl,
    String label,
    String hint, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          style: const TextStyle(color: AppColors.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.gray),
            filled: true,
            fillColor: AppColors.cardBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownRow(String label, List<String> options, String value, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.cardBg,
              style: const TextStyle(color: AppColors.text, fontSize: 14),
              icon: const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary, size: 18),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
