import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/primary_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class ReservationSuccessScreen extends StatelessWidget {
  final String visitType; // 'clinic' or 'home'
  final String? clinicName;
  final String? doctorName;
  final String? serviceName;
  final DateTime date;
  final TimeOfDay time;

  const ReservationSuccessScreen({
    super.key,
    required this.visitType,
    this.clinicName,
    this.doctorName,
    this.serviceName,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        Get.until((route) => route.isFirst);
        return false;
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // Success Animation
              Lottie.asset(
                'assets/animations/success.json',
                width: 150,
                height: 150,
                repeat: false,
              ),
              const SizedBox(height: 20),

              // Success Title
              Text(
                context.tr('reservation.success_title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Success Message
              Text(
                visitType == 'clinic'
                    ? context.tr('reservation.clinic_success_message')
                    : context.tr('reservation.home_success_message'),
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Reservation Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (clinicName != null) _buildDetailRow(
                      context.tr('reservation.clinic'),
                      clinicName!,
                      Icons.local_hospital_outlined,
                      isDarkMode,
                    ),
                    if (doctorName != null) _buildDetailRow(
                      context.tr('reservation.doctor'),
                      doctorName!,
                      Icons.person_outline,
                      isDarkMode,
                    ),
                    if (serviceName != null) _buildDetailRow(
                      context.tr('reservation.service'),
                      serviceName!,
                      Icons.medical_services_outlined,
                      isDarkMode,
                    ),
                    _buildDetailRow(
                      context.tr('reservation.date'),
                      DateFormat('MMM dd, yyyy').format(date),
                      Icons.calendar_today_outlined,
                      isDarkMode,
                    ),
                    _buildDetailRow(
                      context.tr('reservation.time'),
                      time.format(context),
                      Icons.access_time_outlined,
                      isDarkMode,
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Back to Home Button
              PrimaryButton(
                text: context.tr('reservation.back_to_home'),
                onPressed: () => Get.until((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, bool isDarkMode, {bool showDivider = true}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showDivider) const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ),
      ],
    );
  }
} 