import 'package:arwa_app/core/theme/colors.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final bool useGradient;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final bool isOutlined;
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.useGradient = true,
    this.height = 56,
    this.borderRadius = 12,
    this.backgroundColor,
    this.isOutlined = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final buttonContent = Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: isLoading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOutlined ? AppColors.primary : Colors.white,
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 12),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
    );

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: buttonContent,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: useGradient
          ? DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: buttonContent,
              ),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: 2,
              ),
              child: buttonContent,
            ),
    );
  }
} 