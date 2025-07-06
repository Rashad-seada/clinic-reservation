import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;

  const SocialButton({
    Key? key,
    required this.text,
    required this.iconPath,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height = 56,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? (isDarkMode ? Colors.white12 : Colors.white),
          foregroundColor: textColor ?? (isDarkMode ? Colors.white : Colors.black87),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: isDarkMode ? Colors.white24 : Colors.black12,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double height;
  final double borderRadius;

  const GoogleSignInButton({
    Key? key,
    required this.onPressed,
    this.text = 'Continue with Google',
    this.height = 56,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SocialButton(
      text: text,
      iconPath: 'assets/icons/google.png',
      onPressed: onPressed,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

class AppleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double height;
  final double borderRadius;

  const AppleSignInButton({
    Key? key,
    required this.onPressed,
    this.text = 'Continue with Apple',
    this.height = 56,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return SocialButton(
      text: text,
      iconPath: 'assets/icons/apple.png',
      onPressed: onPressed,
      backgroundColor: isDarkMode ? Colors.white : Colors.black,
      textColor: isDarkMode ? Colors.black : Colors.white,
      height: height,
      borderRadius: borderRadius,
    );
  }
} 