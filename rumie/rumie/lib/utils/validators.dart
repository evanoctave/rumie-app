import 'package:flutter/services.dart';

// ── Sanitizers ────────────────────────────────────────────────────────────────

/// Trims and lowercases an email, stripping ASCII control chars.
String sanitizeEmail(String email) =>
    email.trim().toLowerCase().replaceAll(_ctrl, '');

/// Trims and strips ASCII control chars from any text input.
String sanitizeText(String text) => text.trim().replaceAll(_ctrl, '');

final RegExp _ctrl = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]');

// ── Validators ────────────────────────────────────────────────────────────────

/// RFC 5321-simplified email check.
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Email is required.';
  if (value.trim().length > 254) return 'Email is too long.';
  const pattern = r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$';
  if (!RegExp(pattern).hasMatch(value.trim())) {
    return 'Enter a valid email address.';
  }
  return null;
}

/// Password validator.  [isLogin] skips complexity checks on the login form.
String? validatePassword(String? value, {bool isLogin = false}) {
  if (value == null || value.isEmpty) return 'Password is required.';
  if (!isLogin) {
    if (value.length < 8) return 'Password must be at least 8 characters.';
    if (value.trim().isEmpty) return 'Password cannot be only spaces.';
  }
  return null;
}

/// Age must be an integer between 18 and 100.
String? validateAge(String? value) {
  if (value == null || value.trim().isEmpty) return 'Age is required.';
  final n = int.tryParse(value.trim());
  if (n == null) return 'Enter a valid age.';
  if (n < 18) return 'You must be 18 or older to use Rumie.';
  if (n > 100) return 'Enter a valid age.';
  return null;
}

/// Non-empty name, 2–60 chars.
String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Name is required.';
  if (value.trim().length < 2) return 'Name is too short.';
  if (value.trim().length > 60) return 'Name must be under 60 characters.';
  return null;
}

/// Bio: required, max 500 chars.
String? validateBio(String? value) {
  if (value == null || value.trim().isEmpty) return 'Bio is required.';
  if (value.length > 500) return 'Bio must be under 500 characters.';
  return null;
}

// ── TextInputFormatter ────────────────────────────────────────────────────────

/// Strips ASCII control characters (null bytes, escape sequences, etc.)
/// from every keystroke before it reaches the field's value.
class SanitizingFormatter extends TextInputFormatter {
  const SanitizingFormatter();

  static final _strip = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = newValue.text.replaceAll(_strip, '');
    if (cleaned == newValue.text) return newValue;
    return newValue.copyWith(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}
