import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../di/locator.dart';
import '../domain/entities/entities.dart';
import '../domain/errors/error_messages.dart';
import '../domain/repositories/asset_repository.dart';
import '../domain/repositories/discovery_repository.dart';
import '../domain/repositories/listings_repository.dart';
import '../services/value_score.dart';
import '../services/value_score_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_shapes.dart';
import '../theme/app_text.dart';
import '../utils/content_type.dart';
import '../widgets/listing_card.dart';
import '../widgets/rumie_icon.dart';
import '../widgets/state_views.dart';
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

  static const _types = ['All', 'Apartment', 'House', 'Condo', 'Room', 'Duplex', 'Studio'];

  List<ListingOut> _listings = const [];
  final Map<String, ValueScore> _scores = {};
  final _scoreSvc = ValueScoreService();
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
      _scoreAll(listings);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userMessage(e, fallback: "Couldn't load listings.");
        _loading = false;
      });
    }
  }

  /// Value scores are an estimate layered on top of the API listing; they
  /// arrive after the list renders so loading never waits on them.
  Future<void> _scoreAll(List<ListingOut> listings) async {
    for (final l in listings) {
      if (_scores.containsKey(l.id)) continue;
      final score = await _scoreSvc.compute(rent: l.rent, sqft: 0, location: l.location);
      if (!mounted) return;
      setState(() => _scores[l.id] = score);
    }
  }

  List<ListingOut> get _visible => _selectedType == 'All'
      ? _listings
      : _listings.where((l) => ListingMeta.of(l).type == _selectedType).toList();

  @override
  Widget build(BuildContext context) {
    final bottomPad = kNavClearance + MediaQuery.paddingOf(context).bottom;
    final visible = _visible;

    final Widget body;
    if (_loading) {
      body = const LoadingView(key: ValueKey('loading'));
    } else if (_error != null) {
      body = ErrorView(key: const ValueKey('error'), message: _error!, onRetry: _load);
    } else if (visible.isEmpty) {
      body = _buildEmpty();
    } else {
      body = RefreshIndicator(
        key: ValueKey('list-$_selectedType'),
        color: AppColors.accent,
        onRefresh: () => _load(showSpinner: false),
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad),
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: visible.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final l = visible[i];
            final meta = ListingMeta.of(l);
            return Reveal(
              key: ValueKey(l.id),
              index: i,
              child: ListingCard(
                title: l.title,
                type: meta.type,
                location: l.location,
                rent: l.rent,
                bedsBaths: meta.bedsBaths,
                availableDate: meta.availableDate,
                photoUrl: l.photoUrls.isEmpty ? null : l.photoUrls.first,
                valueScore: _scores[l.id],
                animationIndex: i,
              ),
            );
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafeArea(
          bottom: false,
          child: ScreenHeader(
            title: 'Listings',
            subtitle: _loading
                ? 'Finding places near you'
                : '${visible.length} ${visible.length == 1 ? 'place' : 'places'} available',
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
            child: body,
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
            Text(
              _listings.isEmpty ? 'No listings yet. Check back soon.' : 'No listings in this category.',
              style: AppText.secondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showPostSheet(BuildContext context) {
    showAppSheet<void>(
      context,
      initialSize: 0.9,
      builder: (controller) => _PostListingSheet(scrollController: controller, onPosted: _load),
    );
  }
}

// ── Post listing sheet ─────────────────────────────────────────────────────────

class _PostListingSheet extends StatefulWidget {
  final ScrollController scrollController;

  /// Called after the listing was created so the list can refresh.
  final VoidCallback onPosted;

  const _PostListingSheet({required this.scrollController, required this.onPosted});

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
        description: ListingMeta.encode(type: _type, bedsBaths: _beds, availableDate: _available),
        photoUrls: urls,
      ));
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Listing posted')));
      widget.onPosted();
    } catch (e) {
      if (!mounted) return;
      final fields = fieldErrorsOf(e);
      setState(() {
        _posting = false;
        _fieldErrors = fields;
      });
      const shown = {'title', 'location', 'rent'};
      final other = fields.entries.where((f) => !shown.contains(f.key)).expand((f) => f.value);
      if (fields.isEmpty || other.isNotEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              other.isNotEmpty ? other.first : userMessage(e, fallback: "Couldn't post your listing."),
            ),
          ),
        );
      }
    }
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
          AppTextField(
            controller: _titleCtrl,
            label: 'Title',
            hint: 'e.g. Bright room near downtown',
            textCapitalization: TextCapitalization.sentences,
            errorText: firstFieldError(_fieldErrors, 'title'),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _locationCtrl,
            label: 'Location',
            hint: 'Neighborhood, City',
            textCapitalization: TextCapitalization.words,
            errorText: firstFieldError(_fieldErrors, 'location'),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _rentCtrl,
            label: 'Rent per month',
            hint: '1200',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            errorText: firstFieldError(_fieldErrors, 'rent'),
          ),
          const SizedBox(height: 18),
          _ChoiceRow(label: 'Type', options: _types, value: _type, onChanged: (v) => setState(() => _type = v)),
          const SizedBox(height: 14),
          _ChoiceRow(label: 'Beds and baths', options: _bedOptions, value: _beds, onChanged: (v) => setState(() => _beds = v)),
          const SizedBox(height: 14),
          _ChoiceRow(label: 'Available', options: _availOptions, value: _available, onChanged: (v) => setState(() => _available = v)),
          const SizedBox(height: 28),
          AppButton(label: 'Post listing', loading: _posting, onTap: _post),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photos', style: AppText.label),
        const SizedBox(height: 4),
        Text(
          _photoPaths.isEmpty ? 'Add photos of your space.' : 'Tap a photo to make it the cover.',
          style: AppText.caption,
        ),
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
            for (final o in options) AppChip(label: o, selected: o == value, onTap: () => onChanged(o)),
          ],
        ),
      ],
    );
  }
}
