import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/value_score.dart';
import '../services/value_score_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_shapes.dart';
import '../theme/app_text.dart';
import '../widgets/listing_card.dart';
import '../widgets/rumie_icon.dart';
import '../widgets/ui/app_button.dart';
import '../widgets/ui/app_chip.dart';
import '../widgets/ui/app_sheet.dart';
import '../widgets/ui/app_text_field.dart';
import '../widgets/ui/pressable.dart';
import '../widgets/ui/reveal.dart';
import '../widgets/ui/screen_header.dart';
import 'home_screen.dart';

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
    final bottomPad = kNavClearance + MediaQuery.paddingOf(context).bottom;
    final visible = _visible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafeArea(
          bottom: false,
          child: ScreenHeader(
            title: 'Listings',
            subtitle: '${visible.length} available',
            trailing: AppButton(
              label: 'Post',
              icon: Icons.add_rounded,
              size: AppButtonSize.small,
              expand: false,
              onTap: () => _showPostSheet(context),
            ),
          ),
        ),
        _buildFilter(),
        Expanded(
          child: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.slow),
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.exit,
            child: visible.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    key: ValueKey(_selectedType),
                    padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad),
                    physics: const BouncingScrollPhysics(),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final l = visible[i];
                      final gi = _globalIndex(l);
                      return Reveal(
                        index: i,
                        child: ListingCard(
                          title: l['title'] as String,
                          type: l['type'] as String,
                          location: l['location'] as String,
                          rent: l['rent'] as int,
                          sqft: l['sqft'] as int? ?? 0,
                          bedsBaths: l['bedsBaths'] as String,
                          availableDate: l['availableDate'] as String,
                          valueScore: _scores[gi],
                          animationIndex: i,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilter() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _types.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final type = _types[i];
          return AppChip(
            label: type,
            selected: _selectedType == type,
            onTap: () => setState(() => _selectedType = type),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      key: const ValueKey('empty'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nothing here yet', style: AppText.sectionTitle),
            const SizedBox(height: 8),
            Text('No ${_selectedType.toLowerCase()} listings right now.', style: AppText.secondary, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _showPostSheet(BuildContext context) {
    showAppSheet<void>(
      context,
      initialSize: 0.9,
      builder: (controller) => _PostListingSheet(scrollController: controller),
    );
  }
}

// ── Post listing sheet ─────────────────────────────────────────────────────────

class _PostListingSheet extends StatefulWidget {
  final ScrollController scrollController;
  const _PostListingSheet({required this.scrollController});

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

  void _post() {
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing posted')));
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: 'Post a listing',
      scrollController: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhotoSection(),
          const SizedBox(height: 20),
          AppTextField(controller: _titleCtrl, label: 'Title', hint: 'e.g. Bright room near downtown', textCapitalization: TextCapitalization.sentences),
          const SizedBox(height: 14),
          AppTextField(controller: _locationCtrl, label: 'Location', hint: 'Neighborhood, City', textCapitalization: TextCapitalization.words),
          const SizedBox(height: 14),
          AppTextField(controller: _rentCtrl, label: 'Rent per month', hint: '1200', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const SizedBox(height: 18),
          _ChoiceRow(label: 'Type', options: _types, value: _type, onChanged: (v) => setState(() => _type = v)),
          const SizedBox(height: 14),
          _ChoiceRow(label: 'Beds and baths', options: _bedOptions, value: _beds, onChanged: (v) => setState(() => _beds = v)),
          const SizedBox(height: 14),
          _ChoiceRow(label: 'Available', options: _availOptions, value: _available, onChanged: (v) => setState(() => _available = v)),
          const SizedBox(height: 28),
          AppButton(label: 'Post listing', onTap: _post),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photos', style: AppText.label),
        const SizedBox(height: 8),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
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
    return Pressable(
      onTap: _pickPhotos,
      pressedScale: 0.95,
      semanticLabel: 'Add photos',
      child: Container(
        width: 84,
        height: 104,
        decoration: ShapeDecoration(
          color: AppColors.surfaceSunken,
          shape: AppShapes.shape(AppShapes.input, side: BorderSide(color: AppColors.lineStrong)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: AppColors.textSecondary, size: 22),
            const SizedBox(height: 6),
            Text('Add', style: AppText.caption),
          ],
        ),
      ),
    );
  }

  Widget _photoThumbnail(int index) {
    final isCover = index == _coverIndex;
    return Pressable(
      onTap: () => _setCover(index),
      pressedScale: 0.95,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: AppMotion.of(context, AppMotion.base),
            width: 84,
            height: 104,
            decoration: ShapeDecoration(
              shape: AppShapes.shape(AppShapes.input, side: BorderSide(color: isCover ? AppColors.accent : AppColors.line, width: isCover ? 2 : 1)),
            ),
            child: ClipRSuperellipse(
              borderRadius: AppShapes.radius(AppShapes.input - 2),
              child: Image.file(File(_photoPaths[index]), fit: BoxFit.cover),
            ),
          ),
          if (isCover)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(999)),
                child: Text('Cover', style: AppText.micro.copyWith(color: AppColors.onAccent, fontSize: 10)),
              ),
            ),
          Positioned(
            top: 4,
            right: 4,
            child: Pressable(
              onTap: () => _removePhoto(index),
              pressedScale: 0.85,
              semanticLabel: 'Remove photo',
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: AppColors.photoInk.withValues(alpha: 0.7), shape: BoxShape.circle),
                child: const Center(child: RumieIcon(asset: 'assets/icons/ic_close.svg', size: 11, color: AppColors.photoText)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;
  const _ChoiceRow({required this.label, required this.options, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in options)
              AppChip(label: o, selected: o == value, onTap: () => onChanged(o)),
          ],
        ),
      ],
    );
  }
}
