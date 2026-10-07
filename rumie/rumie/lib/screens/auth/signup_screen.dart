import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../data/models/gender.dart';
import '../../data/models/register_in.dart';
import '../../data/models/role.dart';
import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../utils/validators.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/app_chip.dart';
import '../../widgets/ui/app_dialog.dart';
import '../../widgets/ui/app_text_field.dart';
import '../../widgets/ui/circle_button.dart';
import '../../widgets/ui/pressable.dart';
import '../../widgets/ui/reveal.dart';

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
    FocusScope.of(context).unfocus();
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

    final confirmed = await showAppDialog(
      context,
      title: 'Enable Face ID?',
      message: 'Sign in instantly with Face ID every time you open Rumie.',
      confirmLabel: 'Enable',
      cancelLabel: 'Not now',
    );

    if (confirmed && mounted) {
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
    final roleLabel = widget.role == Role.rumie ? 'Looking for a roommate' : 'Landlord';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleButton(
                  iconAsset: 'assets/icons/ic_back.svg',
                  semanticLabel: 'Back',
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 36),
                Reveal(child: Text('Create your account', style: AppText.screenTitle)),
                const SizedBox(height: 10),
                Reveal(index: 1, child: AppChip(label: roleLabel, style: AppChipStyle.accent)),
                const SizedBox(height: 30),
                Reveal(
                  index: 2,
                  child: AppTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    maxLength: 254,
                    inputFormatters: const [SanitizingFormatter()],
                    validator: validateEmail,
                  ),
                ),
                const SizedBox(height: 18),
                Reveal(
                  index: 3,
                  child: AppTextField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    hint: 'At least 8 characters',
                    obscure: _obscure,
                    textInputAction: TextInputAction.next,
                    maxLength: 128,
                    inputFormatters: const [SanitizingFormatter()],
                    validator: validatePassword,
                    suffix: Pressable(
                      onTap: () => setState(() => _obscure = !_obscure),
                      pressedScale: 0.85,
                      semanticLabel: _obscure ? 'Show password' : 'Hide password',
                      child: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Reveal(
                  index: 4,
                  child: AppTextField(
                    controller: _ageCtrl,
                    label: 'Age',
                    hint: '24',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    maxLength: 3,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: validateAge,
                  ),
                ),
                const SizedBox(height: 18),
                Reveal(index: 5, child: Text('Gender', style: AppText.label)),
                const SizedBox(height: 8),
                Reveal(
                  index: 5,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final opt in const [
                        (Gender.male, 'Male'),
                        (Gender.female, 'Female'),
                        (Gender.nonbinary, 'Non-binary'),
                        (Gender.other, 'Other'),
                      ])
                        AppChip(
                          label: opt.$2,
                          selected: _gender == opt.$1,
                          onTap: () => setState(() => _gender = opt.$1),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Reveal(
                  index: 6,
                  child: AppButton(
                    label: 'Create account',
                    loading: loading,
                    iconAsset: 'assets/icons/ic_chevron.svg',
                    iconTrailing: true,
                    onTap: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
