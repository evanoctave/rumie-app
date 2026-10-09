import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_shapes.dart';
import '../../theme/app_text.dart';

/// Labeled text field. The label tints and a soft accent halo fades in on
/// focus, so the active field is obvious without a heavy border.
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;

  /// Server-side message shown under the field (takes priority over validator output).
  final String? errorText;

  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.errorText,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() {
    if (_focused == _focus.hasFocus) return;
    setState(() => _focused = _focus.hasFocus);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.base);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          AnimatedDefaultTextStyle(
            duration: duration,
            style: AppText.label.copyWith(color: _focused ? AppColors.accent : AppColors.textSecondary),
            child: Text(widget.label!),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: duration,
          curve: AppMotion.standard,
          decoration: BoxDecoration(
            borderRadius: AppShapes.radius(AppShapes.input),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: _focused ? 0.18 : 0),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focus,
            autofocus: widget.autofocus,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscure,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLengthEnforcement: widget.maxLength != null ? MaxLengthEnforcement.enforced : null,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            textCapitalization: widget.textCapitalization,
            textInputAction: widget.textInputAction,
            cursorColor: AppColors.accent,
            style: AppText.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: widget.errorText,
              counterText: '',
              suffixIcon: widget.suffix != null
                  ? Padding(padding: const EdgeInsets.only(right: 14), child: widget.suffix)
                  : null,
              suffixIconConstraints: const BoxConstraints(maxWidth: 44, maxHeight: 44),
            ),
          ),
        ),
      ],
    );
  }
}
