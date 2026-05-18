import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

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
      : _listings
          .cast<Map<String, dynamic>>()
          .where((l) => l['type'] == _selectedType)
          .toList();

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
          ShaderMask(
            shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
            child: const Text(
              'Listings',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
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
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pink.withAlpha(70),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(
          begin: -0.15,
          end: 0,
          curve: Curves.easeOutCubic,
        );
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
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.secondary : AppColors.cardBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected ? AppColors.secondary : AppColors.border,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.pink.withAlpha(60),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
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
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  String _type = 'Apartment';
  String _beds = '1 bed / 1 bath';
  String _available = 'Now';

  final List<String> _photoPaths = [];
  int _coverIndex = 0;

  static const _types = ['Room', 'Apartment', 'Condo', 'House', 'Duplex', 'Studio'];
  static const _bedOptions = [
    'Studio / 1 bath',
    '1 bed / 1 bath',
    '2 bed / 1 bath',
    '2 bed / 2 bath',
    '3 bed / 2 bath',
  ];
  static const _availOptions = ['Now', 'June 1', 'July 1', 'August 1', 'Flexible'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _rentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    HapticFeedback.selectionClick();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(imageQuality: 80);
      if (picked.isNotEmpty) {
        setState(() {
          for (final img in picked) {
            if (!_photoPaths.contains(img.path)) {
              _photoPaths.add(img.path);
            }
          }
          if (_coverIndex >= _photoPaths.length) _coverIndex = 0;
        });
      }
    } catch (_) {}
  }

  void _removePhoto(int index) {
    setState(() {
      _photoPaths.removeAt(index);
      if (_coverIndex >= _photoPaths.length) {
        _coverIndex = _photoPaths.isEmpty ? 0 : _photoPaths.length - 1;
      }
    });
    HapticFeedback.selectionClick();
  }

  void _setCover(int index) {
    setState(() => _coverIndex = index);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.border),
            left: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
          ),
        ),
        child: Column(
          children: [
            // Handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (b) =>
                            AppColors.primaryGradient.createShader(b),
                        child: const Text(
                          'Post a Listing',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
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
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                children: [
                  _buildPhotoSection(),
                  const SizedBox(height: 16),
                  _sheetField(_titleCtrl, 'Title', 'e.g. Bright room near downtown'),
                  const SizedBox(height: 10),
                  _sheetField(_locationCtrl, 'Location', 'Neighborhood, City'),
                  const SizedBox(height: 10),
                  _sheetField(
                    _rentCtrl,
                    'Rent / mo',
                    '1200',
                    keyboard: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _dropdownRow(
                    'Type',
                    _types,
                    _type,
                    (v) => setState(() => _type = v!),
                  ),
                  const SizedBox(height: 10),
                  _dropdownRow(
                    'Beds / Baths',
                    _bedOptions,
                    _beds,
                    (v) => setState(() => _beds = v!),
                  ),
                  const SizedBox(height: 10),
                  _dropdownRow(
                    'Available',
                    _availOptions,
                    _available,
                    (v) => setState(() => _available = v!),
                  ),
                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Listing posted!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pink.withAlpha(80),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Post Listing',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PHOTOS',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _photoPaths.isEmpty
              ? 'Add photos of your space'
              : 'Tap a photo to set as cover · ${_photoPaths.length} photo${_photoPaths.length == 1 ? '' : 's'}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photoPaths.length + 1,
            separatorBuilder: (ctx, i) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == _photoPaths.length) {
                return _addPhotoButton();
              }
              return _photoThumbnail(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _addPhotoButton() {
    return GestureDetector(
      onTap: _pickPhotos,
      child: Container(
        width: 90,
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.secondary.withAlpha(80),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pink.withAlpha(70),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add\nPhotos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoThumbnail(int index) {
    final isCover = index == _coverIndex;
    return GestureDetector(
      onTap: () => _setCover(index),
      child: Stack(
        children: [
          Container(
            width: 90,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCover ? AppColors.secondary : AppColors.border,
                width: isCover ? 2.5 : 1.5,
              ),
              boxShadow: isCover
                  ? [
                      BoxShadow(
                        color: AppColors.pink.withAlpha(80),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(_photoPaths[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (isCover)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Cover',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(160),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 12,
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
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownRow(
    String label,
    List<String> options,
    String value,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.cardBg,
              style: const TextStyle(color: AppColors.text, fontSize: 14),
              icon: const Icon(
                Icons.expand_more_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
