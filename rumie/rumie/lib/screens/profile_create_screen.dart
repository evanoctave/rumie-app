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

  String _photoPath = '';
  int _budgetMin = 800;
  int _budgetMax = 1500;
  String _schedule = 'Flexible';
  String _tidiness = 'Relaxed';
  String _moveIn = 'Flexible';
  bool _hasPets = false;

  static const _scheduleOptions = ['Early bird', 'Night owl', 'Flexible'];
  static const _tidinessOptions = ['Very tidy', 'Tidy', 'Relaxed'];
  static const _moveInOptions = ['ASAP', 'Within 1 month', '1–3 months', 'Flexible'];
  static const _traitOptions = [
    'Works from home',
    'Non-smoker',
    'Vegetarian',
    'Has a cat',
    'Has a dog',
    'Loves cooking',
    'Studious',
    'Gamer',
    'Music lover',
    'Gym-goer',
    'Social butterfly',
    'Homebody',
  ];

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
      _selectedTraits.addAll(p.traits);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
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
      if (picked != null) {
        setState(() => _photoPath = picked.path);
      }
    } catch (_) {}
  }

  void _showPhotoPicker() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
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
            Text(label, style: TextStyle(color: c, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
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
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Profile' : 'Create Profile',
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              isEdit ? 'Save' : 'Done',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
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
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
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
                if (n == null || n < 18 || n > 99) return 'Enter a valid age (18–99)';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _field(
              controller: _locationCtrl,
              label: 'Location',
              hint: 'City, neighborhood',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _field(
              controller: _bioCtrl,
              label: 'About me',
              hint: 'A short intro about yourself...',
              maxLines: 4,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            _sectionLabel('Budget'),
            const SizedBox(height: 4),
            Text(
              '\$${_budgetMin.toStringAsFixed(0)} – \$${_budgetMax.toStringAsFixed(0)}/mo',
              style: const TextStyle(
                color: AppColors.primary,
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
              activeColor: AppColors.primary,
              inactiveColor: AppColors.border,
              onChanged: (v) => setState(() {
                _budgetMin = v.start.round();
                _budgetMax = v.end.round();
              }),
            ),
            const SizedBox(height: 32),
            _sectionLabel('Living Style'),
            const SizedBox(height: 12),
            _segmentRow('Schedule', _scheduleOptions, _schedule,
                (v) => setState(() => _schedule = v)),
            const SizedBox(height: 12),
            _segmentRow('Tidiness', _tidinessOptions, _tidiness,
                (v) => setState(() => _tidiness = v)),
            const SizedBox(height: 12),
            _segmentRow('Move-in', _moveInOptions, _moveIn,
                (v) => setState(() => _moveIn = v)),
            const SizedBox(height: 16),
            _toggleRow('Has pets', _hasPets, (v) => setState(() => _hasPets = v)),
            const SizedBox(height: 32),
            _sectionLabel('Traits'),
            const SizedBox(height: 4),
            const Text(
              'Pick up to 6',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            _buildTraitGrid(),
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

  Widget _buildPhotoSection() {
    return Center(
      child: GestureDetector(
        onTap: _showPhotoPicker,
        child: Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _photoPath.isEmpty ? AppColors.border : AppColors.primary,
                  width: _photoPath.isEmpty ? 1.5 : 2.5,
                ),
              ),
              child: _photoPath.isNotEmpty
                  ? ClipOval(
                      child: Image.file(
                        File(_photoPath),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: SvgPicture.asset(
                        'assets/icons/ic_profile.svg',
                        width: 40,
                        height: 40,
                        colorFilter: const ColorFilter.mode(
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
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
          style: const TextStyle(
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
          style: const TextStyle(color: AppColors.text, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.gray),
            filled: true,
            fillColor: AppColors.cardBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
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
                  duration: const Duration(milliseconds: 160),
                  margin: EdgeInsets.only(right: opt == options.last ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      opt,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
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
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTraitGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _traitOptions.map((trait) {
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
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : disabled
                        ? AppColors.border.withAlpha(100)
                        : AppColors.border,
              ),
            ),
            child: Text(
              trait,
              style: TextStyle(
                color: selected
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
      }).toList(),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
