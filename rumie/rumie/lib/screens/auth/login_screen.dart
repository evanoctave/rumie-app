import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../domain/entities/entities.dart';
import '../../domain/errors/error_messages.dart';
import '../../utils/validators.dart';
import '../../widgets/ui/app_button.dart';
import '../../widgets/ui/app_dialog.dart';
import '../../widgets/ui/app_text_field.dart';
import '../../widgets/ui/circle_button.dart';
import '../../widgets/ui/pressable.dart';
import '../../widgets/ui/reveal.dart';
import 'landing_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  /// Server 422 messages (V5), shown under the matching field.
  Map<String, List<String>> _serverErrors = const {};

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _serverErrors = const {};
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(sanitizeEmail(_emailCtrl.text), _passCtrl.text);
    if (!mounted) return;
    if (!ok && auth.fieldErrors.isNotEmpty) {
      setState(() => _serverErrors = auth.fieldErrors);
      _formKey.currentState!.validate();
    }
    if (ok) {
      await _promptBiometrics();
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Login failed.')),
      );
    }
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
      message: 'Unlock Rumie instantly with Face ID every time you open the app.',
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
                Reveal(child: Text('Welcome back', style: AppText.screenTitle)),
                const SizedBox(height: 6),
                Reveal(index: 1, child: Text('Sign in to keep looking.', style: AppText.secondary)),
                const SizedBox(height: 32),
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
                    validator: (v) => firstFieldError(_serverErrors, 'email') ?? validateEmail(v),
                  ),
                ),
                const SizedBox(height: 18),
                Reveal(
                  index: 3,
                  child: AppTextField(
                    controller: _passCtrl,
                    label: 'Password',
                    hint: '••••••••',
                    obscure: _obscure,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    maxLength: 128,
                    inputFormatters: const [SanitizingFormatter()],
                    validator: (v) => firstFieldError(_serverErrors, 'password') ?? validatePassword(v, isLogin: true),
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
                const SizedBox(height: 28),
                Reveal(
                  index: 4,
                  child: AppButton(
                    label: 'Sign in',
                    loading: loading,
                    iconAsset: 'assets/icons/ic_chevron.svg',
                    iconTrailing: true,
                    onTap: _submit,
                  ),
                ),
                const SizedBox(height: 18),
                Reveal(
                  index: 5,
                  child: Center(
                    child: Pressable(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        LandingScreen.slideRoute(const SignupScreen(role: Role.rumie)),
                      ),
                      pressedScale: 0.97,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'New here? ', style: AppText.secondary),
                              TextSpan(
                                text: 'Create an account',
                                style: AppText.secondary.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
