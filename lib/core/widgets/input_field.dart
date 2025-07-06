import 'package:arwa_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool useFloatingLabel;
  final double borderRadius;
  final Color? fillColor;
  final TextInputAction? textInputAction;
  final String? helperText;
  final List<String>? autofillHints;

  const InputField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.useFloatingLabel = true,
    this.borderRadius = 8.0,
    this.fillColor,
    this.textInputAction,
    this.helperText,
    this.autofillHints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!useFloatingLabel && label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onTap: onTap,
          readOnly: readOnly,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            labelText: useFloatingLabel ? label : null,
            hintText: hint,
            helperText: helperText,
            helperMaxLines: 2,
            helperStyle: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillColor ?? (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.white24 : Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            labelStyle: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.white38 : Colors.grey[400],
            ),
            errorStyle: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
} 