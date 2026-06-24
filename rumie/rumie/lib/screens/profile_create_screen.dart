import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../theme/app_colors.dart';

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
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 1.5,
              color: AppColors.border,
            ),
            const SizedBox(height: 20),
            _sheetOption(
              label: 'Choose from library',
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            _sheetOption(
              label: 'Take a photo',
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            if (_photoPath.isNotEmpty)
              _sheetOption(
                label: 'Remove photo',
                onTap: () {
                  setState(() => _photoPath = '');
                  Navigator.pop(context);
                },
                danger: true,
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sheetOption({
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: danger ? AppColors.scoreLow : AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addCustomTrait() {
    final text = _customTraitCtrl.text.trim();
    if (text.isEmpty) return;
    if (_selectedTraits.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 6 traits selected')),
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
            // flat header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1.5)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      '×',
                      style: GoogleFonts.syne(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isEdit ? 'EDIT PROFILE' : 'CREATE PROFILE',
                      style: GoogleFonts.syne(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _save,
                    child: Text(
                      isEdit ? 'SAVE' : 'DONE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 60),
                  children: [
                    _buildPhotoSection(),
                    const SizedBox(height: 32),
                    _sectionLabel('BASIC INFO'),
                    const SizedBox(height: 12),
                    _field(
                      controller: _nameCtrl,
                      label: 'FULL NAME',
                      hint: 'Your name',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      controller: _ageCtrl,
                      label: 'AGE',
                      hint: '22',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 18 || n > 99) {
                          return 'Enter a valid age (18–99)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _field(
                      controller: _locationCtrl,
                      label: 'LOCATION',
                      hint: 'City, neighborhood',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      controller: _bioCtrl,
                      label: 'ABOUT ME',
                      hint: 'A short intro about yourself...',
                      maxLines: 4,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),
                    _sectionLabel('BUDGET'),
                    const SizedBox(height: 4),
                    Text(
                      '\$${_budgetMin.toStringAsFixed(0)} – \$${_budgetMax.toStringAsFixed(0)}/mo',
                      style: GoogleFonts.syne(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values:
                          RangeValues(_budgetMin.toDouble(), _budgetMax.toDouble()),
                      min: 400,
                      max: 5000,
                      divisions: 92,
                      activeColor: AppColors.accent,
                      inactiveColor: AppColors.borderSoft,
                      onChanged: (v) => setState(() {
                        _budgetMin = v.start.round();
                        _budgetMax = v.end.round();
                      }),
                    ),
                    const SizedBox(height: 32),
                    _sectionLabel('LIVING STYLE'),
                    const SizedBox(height: 12),
                    _segmentRow('SCHEDULE', _scheduleOptions, _schedule,
                        (v) => setState(() => _schedule = v)),
                    const SizedBox(height: 12),
                    _segmentRow('TIDINESS', _tidinessOptions, _tidiness,
                        (v) => setState(() => _tidiness = v)),
                    const SizedBox(height: 12),
                    _segmentRow('MOVE-IN', _moveInOptions, _moveIn,
                        (v) => setState(() => _moveIn = v)),
                    const SizedBox(height: 16),
                    _toggleRow(
                      'Has pets',
                      _hasPets,
                      (v) => setState(() {
                        _hasPets = v;
                        if (!v) _pets.clear();
                      }),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child:
                          _hasPets ? _buildPetSection() : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 32),
                    _sectionLabel('TRAITS'),
                    const SizedBox(height: 4),
                    Text(
                      'Pick up to 6 — or add your own',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTraitGrid(),
                    const SizedBox(height: 12),
                    _buildCustomTraitInput(),
                    const SizedBox(height: 40),
                    _SaveBtn(
                      label: isEdit ? 'SAVE CHANGES' : 'CREATE PROFILE',
                      onTap: _save,
                    ),
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
      child: GestureDetector(
        onTap: _showPhotoPicker,
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _photoPath.isEmpty
                      ? AppColors.border
                      : AppColors.accent,
                  width: 1.5,
                ),
              ),
              child: _photoPath.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.file(File(_photoPath), fit: BoxFit.cover),
                    )
                  : Center(
                      child: Text(
                        'PHOTO',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.btnPrimary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.btnPrimaryText,
                  size: 18,
                ),
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
            Text(
              'MY PETS',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _addPet,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Text(
                  '+ ADD PET',
                  style: GoogleFonts.inter(
                    color: AppColors.text,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_pets.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Center(
              child: Text(
                'Tap "Add pet" to list your pets',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          ...List.generate(_pets.length, (i) => _buildPetRow(i)),
      ],
    );
  }

  Widget _buildPetRow(int index) {
    Pet pet = _pets[index];
    final nameCtrl = TextEditingController(text: pet.name);
    final ageCtrl =
        TextEditingController(text: pet.age > 0 ? '${pet.age}' : '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'PET ${index + 1}',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _removePet(index),
                child: Text(
                  '×',
                  style: GoogleFonts.syne(
                    color: AppColors.scoreLow,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: nameCtrl,
                  onChanged: (v) {
                    _pets[index] = pet.copyWith(name: v);
                    pet = _pets[index];
                  },
                  style: GoogleFonts.inter(color: AppColors.text, fontSize: 14),
                  decoration: _inputDeco('NAME', 'e.g. Buddy'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) {
                    _pets[index] = pet.copyWith(age: int.tryParse(v) ?? 0);
                    pet = _pets[index];
                  },
                  style: GoogleFonts.inter(color: AppColors.text, fontSize: 14),
                  decoration: _inputDeco('AGE', '3'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _petTypes.contains(pet.type) ? pet.type : _petTypes[0],
                isExpanded: true,
                dropdownColor: AppColors.surface,
                style: GoogleFonts.inter(color: AppColors.text, fontSize: 14),
                icon: Icon(
                  Icons.expand_more_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                items: _petTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _pets[index] = pet.copyWith(type: v));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5),
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: AppColors.accent, width: 1.5),
      ),
    );
  }

  Widget _buildCustomTraitInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _customTraitCtrl,
            onSubmitted: (_) => _addCustomTrait(),
            style: GoogleFonts.inter(color: AppColors.text, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Add a custom trait...',
              hintStyle:
                  GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: AppColors.border, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: AppColors.border, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: AppColors.accent, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _addCustomTrait,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.btnPrimary,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(Icons.add_rounded, color: AppColors.btnPrimaryText, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: 8,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          style: GoogleFonts.inter(color: AppColors.text, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: AppColors.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: AppColors.scoreLow),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: AppColors.scoreLow, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _segmentRow(
    String label,
    List<String> options,
    String selected,
    void Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: options.map((opt) {
            final isSelected = opt == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(opt);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(
                    right: opt == options.last ? 0 : 6,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.btnPrimary : AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? AppColors.btnPrimary : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      opt,
                      style: GoogleFonts.inter(
                        color: isSelected
                            ? AppColors.btnPrimaryText
                            : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _toggleRow(
    String label,
    bool value,
    void Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeTrackColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildTraitGrid() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ..._presetTraits.map((trait) {
          final selected = _selectedTraits.contains(trait);
          final disabled = !selected && _selectedTraits.length >= 6;
          return GestureDetector(
            onTap: disabled
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (selected) {
                        _selectedTraits.remove(trait);
                      } else {
                        _selectedTraits.add(trait);
                      }
                    });
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.chipBg
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: selected
                      ? AppColors.chipBg
                      : disabled
                          ? AppColors.borderSoft
                          : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Text(
                trait.toUpperCase(),
                style: GoogleFonts.inter(
                  color: selected
                      ? AppColors.chipText
                      : disabled
                          ? AppColors.textSecondary
                          : AppColors.text,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        }),
        ..._selectedTraits
            .where((t) => !_presetTraits.contains(t))
            .map((trait) => GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTraits.remove(trait));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.chipBg,
                      borderRadius: BorderRadius.circular(4),
                      border:
                          Border.all(color: AppColors.chipBg, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          trait.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: AppColors.chipText,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.close_rounded,
                          color: AppColors.chipText,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                )),
      ],
    );
  }
}

class _SaveBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _SaveBtn({required this.label, required this.onTap});

  @override
  State<_SaveBtn> createState() => _SaveBtnState();
}

class _SaveBtnState extends State<_SaveBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        _ctrl.reverse();
      },
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.btnPrimary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              color: AppColors.btnPrimaryText,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
