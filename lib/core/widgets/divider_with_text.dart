import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;
  final TextStyle? textStyle;

  const DividerWithText({
    Key? key,
    required this.text,
    this.thickness = 1,
    this.indent = 24,
    this.endIndent = 24,
    this.color,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = color ?? (isDarkMode ? Colors.white24 : Colors.black12);
    
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: thickness,
            indent: indent,
            endIndent: 16,
            color: dividerColor,
          ),
        ),
        Text(
          text,
          style: textStyle ?? 
            TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
        ),
        Expanded(
          child: Divider(
            thickness: thickness,
            indent: 16,
            endIndent: endIndent,
            color: dividerColor,
          ),
        ),
      ],
    );
  }
} 