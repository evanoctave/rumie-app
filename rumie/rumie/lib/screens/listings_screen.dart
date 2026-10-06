import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../di/locator.dart';
import '../domain/entities/entities.dart';
import '../domain/errors/error_messages.dart';
import '../domain/repositories/asset_repository.dart';
import '../domain/repositories/discovery_repository.dart';
import '../domain/repositories/listings_repository.dart';
import '../theme/app_colors.dart';
import '../utils/content_type.dart';
import '../widgets/listing_card.dart';
import '../widgets/state_views.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  String _selectedType = 'All';

  static const _types = [
    'All',
    'Apartment',
    'House',
    'Condo',
    'Room',
    'Duplex',
    'Studio',
  ];

  List<ListingOut> _listings = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showSpinner = true}) async {
    // Already in the loading state on first run (called from initState).
    if (showSpinner && !_loading) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final listings = await locator<DiscoveryRepository>().discoverListings();
      if (!mounted) return;
      setState(() {
        _listings = listings;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userMessage(e, fallback: "Couldn't load listings.");
        _loading = false;
      });
    }
  }

  List<ListingOut> get _visible =>
      _selectedType == 'All'
          ? _listings
          : _listings
              .where((l) => ListingMeta.of(l).type == _selectedType)
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
            child:
                _loading
                    ? const LoadingView()
                    : _error != null
                    ? ErrorView(message: _error!, onRetry: _load)
                    : _visible.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _load(showSpinner: false),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                        itemCount: _visible.length,
                        separatorBuilder:
                            (ctx, i) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final l = _visible[index];
                          final meta = ListingMeta.of(l);
                          return ListingCard(
                            title: l.title,
                            type: meta.type,
                            location: l.location,
                            rent: l.rent,
                            bedsBaths: meta.bedsBaths,
                            availableDate: meta.availableDate,
                            photoUrl:
                                l.photoUrls.isEmpty ? null : l.photoUrls.first,
                            animationIndex: index,
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1.5),
            ),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Listings',
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      letterSpacing: -0.8,
                    ),
                  ),
                  Text(
                    'Find your next space',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _PostButton(onTap: () => _showPostSheet(context)),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideY(begin: -0.15, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildFilter() {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = _types[index];
          final selected = _selectedType == type;
          final color = _typeColor(type);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedType = type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? color : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? color : AppColors.border,
                  width: 1.5,
                ),
                boxShadow:
                    selected
                        ? [
                          BoxShadow(
                            color: color.withAlpha(60),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                        : AppColors.cardShadow,
              ),
              child: Text(
                type,
                style: GoogleFonts.dmSans(
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

  Color _typeColor(String type) {
    switch (type) {
      case 'Room':
        return AppColors.primary;
      case 'Apartment':
        return AppColors.blue;
      case 'Condo':
        return AppColors.teal;
      case 'House':
        return AppColors.orange;
      case 'Duplex':
        return AppColors.green;
      case 'Studio':
        return AppColors.pink;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _listings.isEmpty
                  ? 'No listings yet. Check back soon.'
                  : 'No listings in this category.',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PostListingSheet(onPosted: _load),
    );
  }
}

// ── Post button ────────────────────────────────────────────────────────────────

class _PostButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PostButton({required this.onTap});

  @override
  State<_PostButton> createState() => _PostButtonState();
}

class _PostButtonState extends State<_PostButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.buttonShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                'Post',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Post listing sheet ─────────────────────────────────────────────────────────

class _PostListingSheet extends StatefulWidget {
  /// Called after the listing was created so the list can refresh.
  final VoidCallback onPosted;

  const _PostListingSheet({required this.onPosted});

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

  bool _posting = false;

  /// Client-side and server (422, V5) messages keyed by API field name.
  Map<String, List<String>> _fieldErrors = const {};

  static const _types = [
    'Room',
    'Apartment',
    'Condo',
    'House',
    'Duplex',
    'Studio',
  ];
  static const _bedOptions = [
    'Studio / 1 bath',
    '1 bed / 1 bath',
    '2 bed / 1 bath',
    '2 bed / 2 bath',
    '3 bed / 2 bath',
  ];
  static const _availOptions = [
    'Now',
    'June 1',
    'July 1',
    'August 1',
    'Flexible',
  ];

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

  Map<String, List<String>> _validate() {
    final errors = <String, List<String>>{};
    if (_titleCtrl.text.trim().isEmpty) {
      errors['title'] = ['Add a title.'];
    } else if (_titleCtrl.text.trim().length > 200) {
      errors['title'] = ['Keep the title under 200 characters.'];
    }
    if (_locationCtrl.text.trim().isEmpty) {
      errors['location'] = ['Add a location.'];
    }
    final rent = int.tryParse(_rentCtrl.text.trim());
    if (rent == null || rent < 0) errors['rent'] = ['Enter the monthly rent.'];
    return errors;
  }

  /// Uploads photos (cover first) via presign → PUT (V8), then creates the
  /// listing with the returned asset URLs.
  Future<void> _post() async {
    if (_posting) return;
    final local = _validate();
    setState(() => _fieldErrors = local);
    if (local.isNotEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() => _posting = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final ordered = [
        if (_photoPaths.isNotEmpty) _photoPaths[_coverIndex],
        for (var i = 0; i < _photoPaths.length; i++)
          if (i != _coverIndex) _photoPaths[i],
      ];
      final assets = locator<AssetRepository>();
      final urls = <String>[];
      for (final path in ordered) {
        urls.add(await assets.upload(
          kind: AssetKind.listingPhoto,
          bytes: await File(path).readAsBytes(),
          contentType: contentTypeForPath(path),
        ));
      }
      await locator<ListingsRepository>().create(ListingCreate(
        title: _titleCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        rent: int.parse(_rentCtrl.text.trim()),
        description: ListingMeta.encode(
          type: _type,
          bedsBaths: _beds,
          availableDate: _available,
        ),
        photoUrls: urls,
      ));
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Listing posted! 🎉')),
      );
      widget.onPosted();
    } catch (e) {
      if (!mounted) return;
      final fields = fieldErrorsOf(e);
      setState(() {
        _posting = false;
        _fieldErrors = fields;
      });
      const shown = {'title', 'location', 'rent'};
      final other = fields.entries
          .where((f) => !shown.contains(f.key))
          .expand((f) => f.value);
      if (fields.isEmpty || other.isNotEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              other.isNotEmpty
                  ? other.first
                  : userMessage(e, fallback: "Couldn't post your listing."),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder:
          (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Text(
                            'Post a Listing',
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      MediaQuery.of(context).viewInsets.bottom + 32,
                    ),
                    children: [
                      _buildPhotoSection(),
                      const SizedBox(height: 20),
                      _sheetField(
                        _titleCtrl,
                        'Title',
                        'e.g. Bright room near downtown',
                        error: firstFieldError(_fieldErrors, 'title'),
                      ),
                      const SizedBox(height: 12),
                      _sheetField(
                        _locationCtrl,
                        'Location',
                        'Neighborhood, City',
                        error: firstFieldError(_fieldErrors, 'location'),
                      ),
                      const SizedBox(height: 12),
                      _sheetField(
                        _rentCtrl,
                        'Rent / mo',
                        '1200',
                        keyboard: TextInputType.number,
                        error: firstFieldError(_fieldErrors, 'rent'),
                      ),
                      const SizedBox(height: 12),
                      _dropdownRow(
                        'Type',
                        _types,
                        _type,
                        (v) => setState(() => _type = v!),
                      ),
                      const SizedBox(height: 12),
                      _dropdownRow(
                        'Beds / Baths',
                        _bedOptions,
                        _beds,
                        (v) => setState(() => _beds = v!),
                      ),
                      const SizedBox(height: 12),
                      _dropdownRow(
                        'Available',
                        _availOptions,
                        _available,
                        (v) => setState(() => _available = v!),
                      ),
                      const SizedBox(height: 28),
                      GestureDetector(
                        onTap: _post,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.buttonShadow,
                          ),
                          child: Center(
                            child: Text(
                              _posting ? 'Posting…' : 'Post Listing',
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
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
        Text(
          'PHOTOS',
          style: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _photoPaths.isEmpty
              ? 'Add photos of your space'
              : 'Tap a photo to set as cover · ${_photoPaths.length} added',
          style: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 115,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photoPaths.length + 1,
            separatorBuilder: (ctx, i) => const SizedBox(width: 10),
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
        width: 92,
        height: 115,
        decoration: BoxDecoration(
          color: AppColors.softPurple,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withAlpha(80),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppColors.buttonShadow,
              ),
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add\nPhotos',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppColors.primary,
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
            width: 92,
            height: 115,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCover ? AppColors.primary : AppColors.border,
                width: isCover ? 2.5 : 1.5,
              ),
              boxShadow: isCover ? AppColors.cardShadow : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(_photoPaths[index]), fit: BoxFit.cover),
            ),
          ),
          if (isCover)
            Positioned(
              top: 7,
              left: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Cover',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(150),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 14,
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
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          style: GoogleFonts.dmSans(color: AppColors.text, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(color: AppColors.gray, fontSize: 15),
            errorText: error,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
          style: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: GoogleFonts.dmSans(color: AppColors.text, fontSize: 15),
              icon: Icon(
                Icons.expand_more_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              items:
                  options
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
