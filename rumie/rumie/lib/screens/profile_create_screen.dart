import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_shapes.dart';
import '../theme/app_text.dart';
import '../widgets/rumie_icon.dart';
import '../widgets/ui/app_button.dart';
import '../widgets/ui/app_chip.dart';
import '../widgets/ui/app_segmented.dart';
import '../widgets/ui/app_text_field.dart';
import '../widgets/ui/circle_button.dart';
import '../widgets/ui/photo.dart';
import '../widgets/ui/pressable.dart';
import '../widgets/ui/settings_rows.dart';

class ProfileCreateScreen extends StatefulWidget {
  final UserProfile? existing;
  final void Function(UserProfile) onSave;

  const ProfileCreateScreen({
    super.key,
    this.existing,
    required this.onSave,
  });

  @override
  State<ProfileCreateScreen> createState() => _ProfileCreateScreenState();
}

class _ProfileCreateScreenState extends State<ProfileCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _customTraitCtrl = TextEditingController();

  String _photoPath = '';
  int _budgetMin = 800;
  int _budgetMax = 1500;
  String _schedule = 'Flexible';
  String _tidiness = 'Relaxed';
  String _moveIn = 'Flexible';
  bool _hasPets = false;
  final List<Pet> _pets = [];

  static const _scheduleOptions = ['Early bird', 'Night owl', 'Flexible'];
  static const _tidinessOptions = ['Very tidy', 'Tidy', 'Relaxed'];
  static const _moveInOptions = ['ASAP', 'Within 1 month', '1–3 months', 'Flexible'];
  static const _presetTraits = [
    'Works from home',
    'Non-smoker',
    'Vegetarian',
    'Loves cooking',
    'Studious',
    'Gamer',
    'Music lover',
    'Gym-goer',
    'Social butterfly',
    'Homebody',
    'Night owl',
    'Early riser',
  ];
  static const _petTypes = ['Dog', 'Cat', 'Bird', 'Fish', 'Rabbit', 'Other'];
  static const _maxTraits = 6;

  final Set<String> _selectedTraits = {};

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final p = widget.existing!;
      _nameCtrl.text = p.name;
      _ageCtrl.text = p.age > 0 ? '${p.age}' : '';
      _bioCtrl.text = p.bio;
      _locationCtrl.text = p.location;
      _photoPath = p.photoPath;
      _budgetMin = p.budgetMin;
      _budgetMax = p.budgetMax;
      _schedule = p.schedule;
      _tidiness = p.tidiness;
      _moveIn = p.moveIn;
      _hasPets = p.haspets;
      _pets.addAll(p.pets);
      _selectedTraits.addAll(p.traits);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _customTraitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked != null) setState(() => _photoPath = picked.path);
    } catch (_) {}
  }

  void _showPhotoPicker() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.photoInk.withValues(alpha: 0.45),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SettingsGroup(
            children: [
              NavRow(
                label: 'Choose from library',
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              NavRow(
                label: 'Take a photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              if (_photoPath.isNotEmpty)
                NavRow(
                  label: 'Remove photo',
                  danger: true,
                  onTap: () {
                    setState(() => _photoPath = '');
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _addCustomTrait() {
    final text = _customTraitCtrl.text.trim();
    if (text.isEmpty) return;
    if (_selectedTraits.length >= _maxTraits) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can pick up to 6 traits')),
      );
      return;
    }
    setState(() {
      _selectedTraits.add(text);
      _customTraitCtrl.clear();
    });
    HapticFeedback.selectionClick();
  }

  void _addPet() {
    HapticFeedback.selectionClick();
    setState(() => _pets.add(const Pet(name: '', type: 'Dog', age: 0)));
  }

  void _removePet(int index) {
    setState(() => _pets.removeAt(index));
    HapticFeedback.selectionClick();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    final profile = UserProfile(
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
      bio: _bioCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      budgetMin: _budgetMin,
      budgetMax: _budgetMax,
      photoPath: _photoPath,
      traits: _selectedTraits.toList(),
      schedule: _schedule,
      tidiness: _tidiness,
      moveIn: _moveIn,
      haspets: _hasPets,
      pets: _hasPets ? List.unmodifiable(_pets) : const [],
    );
    widget.onSave(profile);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Row(
                children: [
                  CircleButton(
                    iconAsset: 'assets/icons/ic_close.svg',
                    semanticLabel: 'Close',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(isEdit ? 'Edit profile' : 'Create profile', style: AppText.sectionTitle),
                  ),
                  AppButton(
                    label: isEdit ? 'Save' : 'Done',
                    size: AppButtonSize.small,
                    style: AppButtonStyle.tonal,
                    expand: false,
                    onTap: _save,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
                  children: [
                    _buildPhotoSection(),
                    const SizedBox(height: 32),
                    Text('Basics', style: AppText.sectionTitle),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _nameCtrl,
                      label: 'Name',
                      hint: 'Your name',
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 110,
                          child: AppTextField(
                            controller: _ageCtrl,
                            label: 'Age',
                            hint: '22',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              if (n == null || n < 18 || n > 99) return '18 to 99';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            controller: _locationCtrl,
                            label: 'Location',
                            hint: 'City, neighborhood',
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _bioCtrl,
                      label: 'About you',
                      hint: 'A short intro. What are you like to live with?',
                      maxLines: 4,
                      minLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: Text('Budget', style: AppText.sectionTitle)),
                        AnimatedSwitcher(
                          duration: AppMotion.of(context, AppMotion.fast),
                          child: Text(
                            '\$$_budgetMin – \$$_budgetMax',
                            key: ValueKey('$_budgetMin-$_budgetMax'),
                            style: AppText.stat.copyWith(color: AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('per month', style: AppText.caption),
                    const SizedBox(height: 6),
                    RangeSlider(
                      values: RangeValues(_budgetMin.toDouble(), _budgetMax.toDouble()),
                      min: 400,
                      max: 5000,
                      divisions: 92,
                      onChanged: (v) => setState(() {
                        _budgetMin = v.start.round();
                        _budgetMax = v.end.round();
                      }),
                    ),
                    const SizedBox(height: 28),
                    Text('Living style', style: AppText.sectionTitle),
                    const SizedBox(height: 14),
                    Text('Schedule', style: AppText.label),
                    const SizedBox(height: 8),
                    AppSegmented(options: _scheduleOptions, value: _schedule, onChanged: (v) => setState(() => _schedule = v)),
                    const SizedBox(height: 16),
                    Text('Tidiness', style: AppText.label),
                    const SizedBox(height: 8),
                    AppSegmented(options: _tidinessOptions, value: _tidiness, onChanged: (v) => setState(() => _tidiness = v)),
                    const SizedBox(height: 16),
                    Text('Move-in', style: AppText.label),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final o in _moveInOptions)
                          AppChip(label: o, selected: _moveIn == o, onTap: () => setState(() => _moveIn = o)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SettingsGroup(
                      children: [
                        ToggleRow(
                          label: 'I have pets',
                          value: _hasPets,
                          onChanged: (v) => setState(() {
                            _hasPets = v;
                            if (!v) _pets.clear();
                          }),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: AppMotion.of(context, AppMotion.slow),
                      curve: AppMotion.enter,
                      alignment: Alignment.topCenter,
                      child: _hasPets ? _buildPetSection() : const SizedBox(width: double.infinity),
                    ),
                    const SizedBox(height: 32),
                    Text('Lifestyle', style: AppText.sectionTitle),
                    const SizedBox(height: 4),
                    Text('Pick up to $_maxTraits, or add your own.', style: AppText.secondary),
                    const SizedBox(height: 14),
                    _buildTraitGrid(),
                    const SizedBox(height: 12),
                    _buildCustomTraitInput(),
                    const SizedBox(height: 40),
                    AppButton(label: isEdit ? 'Save changes' : 'Create profile', onTap: _save),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Pressable(
        onTap: _showPhotoPicker,
        pressedScale: 0.95,
        semanticLabel: 'Change profile photo',
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: AppMotion.of(context, AppMotion.base),
              decoration: ShapeDecoration(
                shape: AppShapes.shape(36, side: BorderSide(color: _photoPath.isEmpty ? AppColors.lineStrong : AppColors.accent, width: 2)),
              ),
              padding: const EdgeInsets.all(4),
              child: _photoPath.isEmpty
                  ? Container(
                      width: 104,
                      height: 104,
                      decoration: ShapeDecoration(color: AppColors.surfaceSunken, shape: AppShapes.shape(32)),
                      child: Center(child: Icon(Icons.person_outline_rounded, size: 40, color: AppColors.textTertiary)),
                    )
                  : Avatar(path: _photoPath, name: _nameCtrl.text, size: 104),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 3),
                ),
                child: Center(child: RumieIcon(asset: 'assets/icons/ic_edit.svg', size: 14, color: AppColors.onAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: Text('My pets', style: AppText.label)),
            AppButton(
              label: 'Add pet',
              icon: Icons.add_rounded,
              size: AppButtonSize.small,
              style: AppButtonStyle.secondary,
              expand: false,
              onTap: _addPet,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_pets.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: ShapeDecoration(
              color: AppColors.surfaceSunken,
              shape: AppShapes.shape(AppShapes.tile),
            ),
            child: Center(child: Text('Add a pet so roommates know who else lives with you.', style: AppText.caption, textAlign: TextAlign.center)),
          )
        else
          ...List.generate(_pets.length, (i) => _buildPetRow(i)),
      ],
    );
  }

  Widget _buildPetRow(int index) {
    Pet pet = _pets[index];
    final nameCtrl = TextEditingController(text: pet.name);
    final ageCtrl = TextEditingController(text: pet.age > 0 ? '${pet.age}' : '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: AppShapes.shape(AppShapes.tile, side: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Pet ${index + 1}', style: AppText.label)),
              CircleButton(
                size: 32,
                iconAsset: 'assets/icons/ic_close.svg',
                style: CircleButtonStyle.danger,
                semanticLabel: 'Remove pet',
                onTap: () => _removePet(index),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: AppTextField(
                  controller: nameCtrl,
                  label: 'Name',
                  hint: 'e.g. Buddy',
                  textCapitalization: TextCapitalization.words,
                  onChanged: (v) {
                    _pets[index] = pet.copyWith(name: v);
                    pet = _pets[index];
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppTextField(
                  controller: ageCtrl,
                  label: 'Age',
                  hint: '3',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) {
                    _pets[index] = pet.copyWith(age: int.tryParse(v) ?? 0);
                    pet = _pets[index];
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _petTypes)
                AppChip(
                  label: t,
                  dense: true,
                  selected: (_petTypes.contains(pet.type) ? pet.type : _petTypes[0]) == t,
                  onTap: () => setState(() => _pets[index] = pet.copyWith(type: t)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTraitInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: AppTextField(
            controller: _customTraitCtrl,
            hint: 'Add your own',
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _addCustomTrait(),
          ),
        ),
        const SizedBox(width: 10),
        CircleButton(
          size: 52,
          icon: Icons.add_rounded,
          style: CircleButtonStyle.accent,
          semanticLabel: 'Add trait',
          onTap: _addCustomTrait,
        ),
      ],
    );
  }

  Widget _buildTraitGrid() {
    final full = _selectedTraits.length >= _maxTraits;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._presetTraits.map((trait) {
          final selected = _selectedTraits.contains(trait);
          final disabled = !selected && full;
          return AnimatedOpacity(
            duration: AppMotion.of(context, AppMotion.base),
            opacity: disabled ? 0.45 : 1,
            child: AppChip(
              label: trait,
              selected: selected,
              onTap: disabled
                  ? null
                  : () => setState(() {
                        if (selected) {
                          _selectedTraits.remove(trait);
                        } else {
                          _selectedTraits.add(trait);
                        }
                      }),
            ),
          );
        }),
        ..._selectedTraits.where((t) => !_presetTraits.contains(t)).map(
              (trait) => AppChip(
                label: trait,
                selected: true,
                trailing: RumieIcon(asset: 'assets/icons/ic_close.svg', size: 11, color: AppColors.background),
                onTap: () => setState(() => _selectedTraits.remove(trait)),
              ),
            ),
      ],
    );
  }
}
