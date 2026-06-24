import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../services/value_score.dart';
import '../services/value_score_service.dart';
import '../theme/app_colors.dart';
import '../widgets/listing_card.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  String _selectedType = 'All';
  final Map<int, ValueScore?> _scores = {};
  final _svc = ValueScoreService();

  static const _types = ['All', 'Apartment', 'House', 'Condo', 'Room', 'Duplex', 'Studio'];

  static const _listings = [
    {'title': 'Bright private room near campus', 'type': 'Room', 'location': 'Westwood, Los Angeles', 'rent': 1250, 'sqft': 280, 'bedsBaths': '1 bed / shared bath', 'availableDate': 'June 1'},
    {'title': 'Spacious apartment with shared kitchen', 'type': 'Apartment', 'location': 'Koreatown, Los Angeles', 'rent': 1800, 'sqft': 650, 'bedsBaths': '2 bed / 1 bath', 'availableDate': 'Now'},
    {'title': 'Quiet condo with home office', 'type': 'Condo', 'location': 'Pasadena, CA', 'rent': 2100, 'sqft': 900, 'bedsBaths': '2 bed / 2 bath', 'availableDate': 'July 10'},
    {'title': 'Duplex room with private backyard', 'type': 'Duplex', 'location': 'El Sereno, Los Angeles', 'rent': 1450, 'sqft': 480, 'bedsBaths': '1 bed / 1 bath', 'availableDate': 'August 1'},
    {'title': 'Modern studio in downtown', 'type': 'Studio', 'location': 'DTLA, Los Angeles', 'rent': 1650, 'sqft': 420, 'bedsBaths': 'Studio / 1 bath', 'availableDate': 'Now'},
  ];

  List<Map<String, dynamic>> get _visible => _selectedType == 'All'
      ? _listings.cast<Map<String, dynamic>>()
      : _listings.cast<Map<String, dynamic>>().where((l) => l['type'] == _selectedType).toList();

  @override
  void initState() {
    super.initState();
    _fetchScores();
  }

  Future<void> _fetchScores() async {
    for (int i = 0; i < _listings.length; i++) {
      final l = _listings[i];
      final score = await _svc.compute(
        rent: l['rent'] as int,
        sqft: l['sqft'] as int? ?? 0,
        location: l['location'] as String,
      );
      if (mounted) setState(() => _scores[i] = score);
    }
  }

  int _globalIndex(Map<String, dynamic> listing) =>
      _listings.indexWhere((l) => l['title'] == listing['title']);

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
            child: _visible.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    itemCount: _visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final l = _visible[i];
                      final gi = _globalIndex(l);
                      return ListingCard(
                        title: l['title'] as String,
                        type: l['type'] as String,
                        location: l['location'] as String,
                        rent: l['rent'] as int,
                        sqft: l['sqft'] as int? ?? 0,
                        bedsBaths: l['bedsBaths'] as String,
                        availableDate: l['availableDate'] as String,
                        valueScore: _scores[gi],
                        animationIndex: i,
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Row(
        children: [
          Text(
            'Listings',
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.8,
            ),
          ),
          const Spacer(),
          _PostBtn(onTap: () => _showPostSheet(context)),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final type = _types[i];
          final selected = _selectedType == type;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedType = type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.text : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: selected ? AppColors.text : AppColors.borderSoft,
                  width: 1.5,
                ),
              ),
              child: Text(
                type.toUpperCase(),
                style: GoogleFonts.inter(
                  color: selected ? AppColors.background : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        'NO LISTINGS\nIN THIS TYPE',
        textAlign: TextAlign.center,
        style: GoogleFonts.syne(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
          letterSpacing: -1,
          height: 1,
        ),
      ),
    );
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

class _PostBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _PostBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.btnPrimary,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          '+ POST',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.btnPrimaryText,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// ── Post listing sheet ─────────────────────────────────────────────────────────

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
  static const _bedOptions = ['Studio / 1 bath', '1 bed / 1 bath', '2 bed / 1 bath', '2 bed / 2 bath', '3 bed / 2 bath'];
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
            if (!_photoPaths.contains(img.path)) _photoPaths.add(img.path);
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
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.borderSoft,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'POST LISTING',
                        style: GoogleFonts.syne(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border, width: 1.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 16),
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
                padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 32),
                children: [
                  _buildPhotoSection(),
                  const SizedBox(height: 20),
                  _sheetField(_titleCtrl, 'TITLE', 'e.g. Bright room near downtown'),
                  const SizedBox(height: 12),
                  _sheetField(_locationCtrl, 'LOCATION', 'Neighborhood, City'),
                  const SizedBox(height: 12),
                  _sheetField(_rentCtrl, 'RENT / MO', '1200', keyboard: TextInputType.number),
                  const SizedBox(height: 12),
                  _dropdownRow('TYPE', _types, _type, (v) => setState(() => _type = v!)),
                  const SizedBox(height: 12),
                  _dropdownRow('BEDS / BATHS', _bedOptions, _beds, (v) => setState(() => _beds = v!)),
                  const SizedBox(height: 12),
                  _dropdownRow('AVAILABLE', _availOptions, _available, (v) => setState(() => _available = v!)),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Listing posted!')),
                      );
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
                        'POST LISTING →',
                        style: GoogleFonts.inter(
                          color: AppColors.btnPrimaryText,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 2,
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
        Text(
          'PHOTOS',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photoPaths.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == _photoPaths.length) return _addPhotoButton();
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
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_rounded, color: AppColors.textSecondary, size: 22),
            const SizedBox(height: 4),
            Text(
              'ADD',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
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
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCover ? AppColors.accent : AppColors.border,
                width: isCover ? 2 : 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.file(File(_photoPaths[index]), fit: BoxFit.cover),
            ),
          ),
          if (isCover)
            Positioned(
              top: 5,
              left: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'COVER',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFF2F0EB),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(160),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetField(TextEditingController ctrl, String label, String hint, {TextInputType keyboard = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          style: GoogleFonts.inter(color: AppColors.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
            filled: true,
            fillColor: AppColors.background,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: AppColors.border, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: AppColors.border, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: AppColors.accent, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _dropdownRow(String label, List<String> options, String value, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: GoogleFonts.inter(color: AppColors.text, fontSize: 14),
              icon: Icon(Icons.expand_more_rounded, color: AppColors.textSecondary, size: 18),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
