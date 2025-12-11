import 'package:arwa_app/core/theme/colors.dart';
import 'package:flutter/material.dart';

/// Reusable error banner widget for displaying error messages
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final bool showIcon;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        );
      },
      child: message.isNotEmpty
          ? Container(
              key: ValueKey<String>(message),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showIcon) ...[
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (onDismiss != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDismiss,
                      child: Icon(
                        Icons.close,
                        color: AppColors.error,
                        size: 18,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// Success banner for displaying success messages
class SuccessBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final bool showIcon;

  const SuccessBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        );
      },
      child: message.isNotEmpty
          ? Container(
              key: ValueKey<String>(message),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showIcon) ...[
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (onDismiss != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDismiss,
                      child: const Icon(
                        Icons.close,
                        color: Colors.green,
                        size: 18,
                      ),
                    ),
                  ],
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
