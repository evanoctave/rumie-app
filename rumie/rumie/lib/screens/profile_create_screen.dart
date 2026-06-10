import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../theme/app_colors.dart';

class ProfileCreateScreen extends StatefulWidget {
  final UserProfile? existing;
  final void Function(UserProfile) onSave;

  const ProfileCreateScreen({super.key, this.existing, required this.onSave});

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
  static const _moveInOptions = [
    'ASAP',
    'Within 1 month',
    '1–3 months',
    'Flexible',
  ];
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                _sheetOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Choose from library',
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.gallery);
                  },
                ),
                _sheetOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Take a photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.camera);
                  },
                ),
                if (_photoPath.isNotEmpty)
                  _sheetOption(
                    icon: Icons.delete_outline_rounded,
                    label: 'Remove photo',
                    color: AppColors.red,
                    onTap: () {
                      setState(() => _photoPath = '');
                      Navigator.pop(context);
                    },
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
    );
  }

  Widget _sheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? AppColors.text;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: c,
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Max 6 traits selected')));
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
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Profile' : 'Create Profile',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: ShaderMask(
              shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
              child: Text(
                isEdit ? 'Save' : 'Done',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 60),
          children: [
            _buildPhotoSection(),
            const SizedBox(height: 32),
            _sectionLabel('Basic Info'),
            const SizedBox(height: 12),
            _field(
              controller: _nameCtrl,
              label: 'Full name',
              hint: 'Your name',
              validator:
                  (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _field(
              controller: _ageCtrl,
              label: 'Age',
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
              label: 'Location',
              hint: 'City, neighborhood',
              validator:
                  (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _field(
              controller: _bioCtrl,
              label: 'About me',
              hint: 'A short intro about yourself...',
              maxLines: 4,
              validator:
                  (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            _sectionLabel('Budget'),
            const SizedBox(height: 4),
            Text(
              '\$${_budgetMin.toStringAsFixed(0)} – \$${_budgetMax.toStringAsFixed(0)}/mo',
              style: const TextStyle(
                color: AppColors.peach,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: RangeValues(_budgetMin.toDouble(), _budgetMax.toDouble()),
              min: 400,
              max: 5000,
              divisions: 92,
              activeColor: AppColors.secondary,
              inactiveColor: AppColors.border,
              onChanged:
                  (v) => setState(() {
                    _budgetMin = v.start.round();
                    _budgetMax = v.end.round();
                  }),
            ),
            const SizedBox(height: 32),
            _sectionLabel('Living Style'),
            const SizedBox(height: 12),
            _segmentRow(
              'Schedule',
              _scheduleOptions,
              _schedule,
              (v) => setState(() => _schedule = v),
            ),
            const SizedBox(height: 12),
            _segmentRow(
              'Tidiness',
              _tidinessOptions,
              _tidiness,
              (v) => setState(() => _tidiness = v),
            ),
            const SizedBox(height: 12),
            _segmentRow(
              'Move-in',
              _moveInOptions,
              _moveIn,
              (v) => setState(() => _moveIn = v),
            ),
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
              child: _hasPets ? _buildPetSection() : const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),
            _sectionLabel('Traits'),
            const SizedBox(height: 4),
            Text(
              'Pick up to 6 — or add your own',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            _buildTraitGrid(),
            const SizedBox(height: 12),
            _buildCustomTraitInput(),
            const SizedBox(height: 40),
            _PrimaryButton(
              label: isEdit ? 'Save Changes' : 'Create Profile',
              onTap: _save,
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
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _addPet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.secondary.withAlpha(80)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: AppColors.secondary,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Add pet',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.border,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Text(
                'Tap "Add pet" to list your pets',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
    final ageCtrl = TextEditingController(
      text: pet.age > 0 ? '${pet.age}' : '',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Pet ${index + 1}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _removePet(index),
                child: const Icon(
                  Icons.remove_circle_outline_rounded,
                  color: AppColors.red,
                  size: 18,
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
                  style: TextStyle(color: AppColors.text, fontSize: 14),
                  decoration: _inputDeco('Name', 'e.g. Buddy'),
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
                  style: TextStyle(color: AppColors.text, fontSize: 14),
                  decoration: _inputDeco('Age', '3'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _petTypes.contains(pet.type) ? pet.type : _petTypes[0],
                isExpanded: true,
                dropdownColor: AppColors.cardBg,
                style: TextStyle(color: AppColors.text, fontSize: 14),
                icon: Icon(
                  Icons.expand_more_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                items:
                    _petTypes
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
      labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.gray),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
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
            style: TextStyle(color: AppColors.text, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Add a custom trait...',
              hintStyle: TextStyle(color: AppColors.gray, fontSize: 14),
              filled: true,
              fillColor: AppColors.cardBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 1.5,
                ),
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
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withAlpha(60),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: GestureDetector(
        onTap: _showPhotoPicker,
        child: Stack(
          children: [
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      _photoPath.isEmpty
                          ? AppColors.border
                          : AppColors.secondary,
                  width: _photoPath.isEmpty ? 1.5 : 2.5,
                ),
                boxShadow:
                    _photoPath.isNotEmpty
                        ? [
                          BoxShadow(
                            color: AppColors.pink.withAlpha(60),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ]
                        : null,
              ),
              child:
                  _photoPath.isNotEmpty
                      ? ClipOval(
                        child: Image.file(File(_photoPath), fit: BoxFit.cover),
                      )
                      : Center(
                        child: SvgPicture.asset(
                          'assets/icons/ic_profile.svg',
                          width: 42,
                          height: 42,
                          colorFilter: ColorFilter.mode(
                            AppColors.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pink.withAlpha(80),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
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
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          style: TextStyle(color: AppColors.text, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.gray),
            filled: true,
            fillColor: AppColors.cardBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppColors.secondary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.red, width: 1.5),
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
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children:
              options.map((opt) {
                final isSelected = opt == selected;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onSelect(opt);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(
                        right: opt == options.last ? 0 : 8,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.secondary : AppColors.cardBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.secondary
                                  : AppColors.border,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: AppColors.pink.withAlpha(50),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          opt,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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

  Widget _toggleRow(String label, bool value, void Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Switch.adaptive(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildTraitGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._presetTraits.map((trait) {
          final selected = _selectedTraits.contains(trait);
          final disabled = !selected && _selectedTraits.length >= 6;
          return GestureDetector(
            onTap:
                disabled
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
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.secondary : AppColors.cardBg,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color:
                      selected
                          ? AppColors.secondary
                          : disabled
                          ? AppColors.border.withAlpha(100)
                          : AppColors.border,
                ),
                boxShadow:
                    selected
                        ? [
                          BoxShadow(
                            color: AppColors.pink.withAlpha(50),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Text(
                trait,
                style: TextStyle(
                  color:
                      selected
                          ? Colors.white
                          : disabled
                          ? AppColors.gray
                          : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
        // Custom traits added by user (not in presets)
        ..._selectedTraits
            .where((t) => !_presetTraits.contains(t))
            .map(
              (trait) => GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedTraits.remove(trait));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pink.withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trait,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton>
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
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: AppColors.pink.withAlpha(80),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
