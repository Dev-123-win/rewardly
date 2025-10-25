import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class ValidatedTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final int? maxLines;
  final String? helperText;
  final bool obscureText;
  final ValueChanged<bool>? onValidationChanged;

  const ValidatedTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.maxLines = 1,
    this.helperText,
    this.obscureText = false,
    this.onValidationChanged,
    super.key,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  String? _errorText;
  bool _isValid = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _validateField(String value) {
    setState(() {
      _errorText = widget.validator?.call(value);
      _isValid = _errorText == null && value.isNotEmpty;
    });
    widget.onValidationChanged?.call(_isValid);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: DesignSystem.titleMedium.copyWith(
            color: DesignSystem.textPrimary,
          ),
        ),
        SizedBox(height: DesignSystem.spacing2),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          obscureText: _obscureText,
          onChanged: _validateField,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? GestureDetector(
                    onTap: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                    child: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: DesignSystem.textSecondary,
                    ),
                  )
                : (_isValid
                    ? Icon(
                        Icons.check_circle,
                        color: DesignSystem.success,
                      )
                    : null),
            errorText: _errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: _errorText != null
                    ? DesignSystem.error
                    : DesignSystem.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: _errorText != null
                    ? DesignSystem.error
                    : DesignSystem.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: _errorText != null
                    ? DesignSystem.error
                    : DesignSystem.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              borderSide: BorderSide(
                color: DesignSystem.error,
              ),
            ),
            filled: true,
            fillColor: DesignSystem.surface,
            contentPadding: EdgeInsets.all(DesignSystem.spacing4),
          ),
          style: DesignSystem.bodyMedium.copyWith(
            color: DesignSystem.textPrimary,
          ),
        ),
        if (widget.helperText != null) ...[
          SizedBox(height: DesignSystem.spacing2),
          Text(
            widget.helperText!,
            style: DesignSystem.bodySmall.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
        ],
        if (_errorText != null) ...[
          SizedBox(height: DesignSystem.spacing2),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: DesignSystem.error,
                size: 16,
              ),
              SizedBox(width: DesignSystem.spacing2),
              Expanded(
                child: Text(
                  _errorText!,
                  style: DesignSystem.bodySmall.copyWith(
                    color: DesignSystem.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
