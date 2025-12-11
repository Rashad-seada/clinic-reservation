import 'package:arwa_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable date picker button widget
class AppDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? hint;
  final IconData icon;
  final String? errorText;

  const AppDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.hint,
    this.icon = Icons.calendar_today_outlined,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat.yMMMd(locale).format(selectedDate!)
                        : (hint ?? 'Select Date'),
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedDate != null
                          ? (isDarkMode ? Colors.white : AppColors.darkText)
                          : (isDarkMode ? Colors.white54 : Colors.grey[600]),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ],
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}

/// Reusable time picker button widget
class AppTimePicker extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final void Function(TimeOfDay) onTimeSelected;
  final String? hint;
  final IconData icon;
  final String? errorText;

  const AppTimePicker({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
    this.hint,
    this.icon = Icons.access_time_outlined,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _selectTime(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedTime != null
                        ? selectedTime!.format(context)
                        : (hint ?? 'Select Time'),
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedTime != null
                          ? (isDarkMode ? Colors.white : AppColors.darkText)
                          : (isDarkMode ? Colors.white54 : Colors.grey[600]),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ],
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeSelected(picked);
    }
  }
}
