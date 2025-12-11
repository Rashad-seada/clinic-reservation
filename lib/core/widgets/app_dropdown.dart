import 'package:arwa_app/core/theme/colors.dart';
import 'package:flutter/material.dart';

/// Reusable dropdown widget with consistent styling and dark mode support
class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String? hint;
  final IconData? prefixIcon;
  final bool isLoading;
  final String? errorText;
  final bool enabled;

  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.hint,
    this.prefixIcon,
    this.isLoading = false,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? AppColors.error
                  : AppColors.mediumGrey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: isLoading
              ? _buildLoadingIndicator(isDarkMode)
              : DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    isExpanded: true,
                    hint: Row(
                      children: [
                        if (prefixIcon != null) ...[
                          Icon(
                            prefixIcon,
                            color: AppColors.mediumGrey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          hint ?? '',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white54 : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                    dropdownColor: isDarkMode ? const Color(0xFF2A2A3E) : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    borderRadius: BorderRadius.circular(12),
                    items: items.map((item) {
                      return DropdownMenuItem<T>(
                        value: item,
                        child: Row(
                          children: [
                            if (prefixIcon != null) ...[
                              Icon(
                                prefixIcon,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Text(
                                itemLabel(item),
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : AppColors.darkText,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: enabled ? onChanged : null,
                  ),
                ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          if (prefixIcon != null) ...[
            Icon(
              prefixIcon,
              color: AppColors.mediumGrey,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? Colors.white54 : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading...',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
