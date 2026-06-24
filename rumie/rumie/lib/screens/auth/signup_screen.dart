import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../data/models/gender.dart';
import '../../data/models/register_in.dart';
import '../../data/models/role.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';

class SignupScreen extends StatefulWidget {
  final Role role;
  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  bool _obscure = true;
  Gender _gender = Gender.other;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      RegisterIn(
        email: sanitizeEmail(_emailCtrl.text),
        password: _passwordCtrl.text,
        role: widget.role,
        age: int.parse(_ageCtrl.text.trim()),
        gender: _gender,
      ),
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Registration failed.')),
      );
      return;
    }
    await _promptBiometrics();
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _promptBiometrics() async {
    final auth = LocalAuthentication();
    final canCheck = await auth.canCheckBiometrics;
    if (!canCheck || !mounted) return;
    final available = await auth.getAvailableBiometrics();
    if (!available.contains(BiometricType.face) || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.border, width: 1.5),
        ),
        title: Text('Enable Face ID?',
            style: GoogleFonts.syne(
                fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text)),
        content: Text(
          'Sign in instantly with Face ID every time you open Rumie.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Not now',
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Enable',
                style: GoogleFonts.inter(color: AppColors.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await auth.authenticate(
          localizedReason: 'Authenticate to enable Face ID for Rumie',
          options: const AuthenticationOptions(biometricOnly: true),
        );
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;
    final roleLabel = widget.role == Role.rumie ? 'ROOMMATE' : 'LANDLORD';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    '←',
                    style: GoogleFonts.syne(
                        fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text),
                  ),
                ),
                const SizedBox(height: 32),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'CREATE\n',
                        style: GoogleFonts.syne(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                          letterSpacing: -2,
                          height: 0.95,
                        ),
                      ),
                      TextSpan(
                        text: 'ACCOUNT',
                        style: GoogleFonts.syne(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                          letterSpacing: -2,
                          height: 0.95,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    roleLabel,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                const _BrutalLabel('EMAIL'),
                const SizedBox(height: 8),
                _BrutalField(
                  controller: _emailCtrl,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 254,
                  validator: validateEmail,
                ),
                const SizedBox(height: 14),

                const _BrutalLabel('PASSWORD'),
                const SizedBox(height: 8),
                _BrutalField(
                  controller: _passwordCtrl,
                  hint: '••••••••',
                  obscure: _obscure,
                  maxLength: 128,
                  validator: validatePassword,
                  suffix: GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                const _BrutalLabel('AGE'),
                const SizedBox(height: 8),
                _BrutalField(
                  controller: _ageCtrl,
                  hint: '24',
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  validator: validateAge,
                ),
                const SizedBox(height: 14),

                const _BrutalLabel('GENDER'),
                const SizedBox(height: 8),
                _GenderRow(
                  selected: _gender,
                  onChanged: (g) => setState(() => _gender = g),
                ),
                const SizedBox(height: 28),

                _SubmitBtn(label: 'CREATE ACCOUNT →', loading: loading, onTap: _submit),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderRow extends StatelessWidget {
  final Gender selected;
  final ValueChanged<Gender> onChanged;
  const _GenderRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      (Gender.male, 'Male'),
      (Gender.female, 'Female'),
      (Gender.nonbinary, 'Non-binary'),
      (Gender.other, 'Other'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt.$1;
        return GestureDetector(
          onTap: () => onChanged(opt.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentSoft : AppColors.surface,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Text(
              opt.$2,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BrutalLabel extends StatelessWidget {
  final String text;
  const _BrutalLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _BrutalField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final int? maxLength;
  final String? Function(String?)? validator;

  const _BrutalField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.maxLength,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(5));
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      inputFormatters: const [SanitizingFormatter()],
      style: GoogleFonts.inter(color: AppColors.text, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
            : null,
        suffixIconConstraints: const BoxConstraints(maxWidth: 40, maxHeight: 40),
        filled: true,
        fillColor: AppColors.surface,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: AppColors.border, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: AppColors.border, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: AppColors.accent, width: 1.5)),
        errorBorder: const OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: AppColors.red, width: 1.5)),
        focusedErrorBorder: const OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: AppColors.red, width: 1.5)),
        errorStyle: GoogleFonts.inter(color: AppColors.red, fontSize: 11),
      ),
    );
  }
}

class _SubmitBtn extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const _SubmitBtn({required this.label, required this.loading, required this.onTap});

  @override
  State<_SubmitBtn> createState() => _SubmitBtnState();
}

class _SubmitBtnState extends State<_SubmitBtn> {
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
        if (!widget.loading) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.btnPrimary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: widget.loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppColors.btnPrimaryText),
                  ),
                )
              : Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.btnPrimaryText,
                    letterSpacing: 2,
                  ),
                ),
        ),
      ),
    );
  }
}
