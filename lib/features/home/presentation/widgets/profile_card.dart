import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/features/home/domain/entities/patient.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable Profile Card widget for displaying user information
class ProfileCard extends StatelessWidget {
  final Patient patient;
  final String? fileNumberLabel;
  final String? nationalIdLabel;

  const ProfileCard({
    super.key,
    required this.patient,
    this.fileNumberLabel,
    this.nationalIdLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 40),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
            ),
            boxShadow: isDarkMode
                ? []
                : [
                    BoxShadow(
                      color: Colors.grey[200]!,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Text(
                patient.username ?? "-",
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatBirthDate(patient.birthDate, locale),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn(
                        label: fileNumberLabel ?? 'File Number',
                        value: patient.phone ?? "-",
                        isDarkMode: isDarkMode,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey[200],
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        label: nationalIdLabel ?? 'National ID',
                        value: patient.id.toString(),
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // Profile Circle Avatar
        _buildAvatar(),
      ],
    );
  }

  Widget _buildAvatar() {
    final initial = patient.username?.isNotEmpty == true
        ? patient.username![0].toUpperCase()
        : '';

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.1),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn({
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 12,
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  String _formatBirthDate(String? dateString, String locale) {
    if (dateString == null || dateString.isEmpty) return "-";
    try {
      final DateTime date = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat.yMMMMd(locale);
      return formatter.format(date);
    } catch (e) {
      return "-";
    }
  }
}
