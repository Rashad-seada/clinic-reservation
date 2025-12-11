import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/primary_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReceiptScreen extends StatelessWidget {
  final String patientName;
  final String serviceName;
  final String providerName; // Doctor or Clinic/City
  final String date;
  final String time;
  final double? price;
  final String visitType; // 'clinic' or 'home'
  final VoidCallback onConfirm;
  final bool isLoading;

  const ReceiptScreen({
    super.key,
    required this.patientName,
    required this.serviceName,
    required this.providerName,
    required this.date,
    required this.time,
    required this.price,
    required this.visitType,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          context.tr('common.confirmation'),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Almarai',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Receipt Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    context.tr('common.reservation_details'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                      fontFamily: 'Almarai',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Details
                  _buildDetailRow(
                    context,
                    context.tr('home_visit.patient_name'),
                    patientName,
                    isDarkMode,
                  ),
                  _buildDivider(isDarkMode),
                  
                  _buildDetailRow(
                    context,
                    context.tr('common.service'),
                    serviceName,
                    isDarkMode,
                  ),
                  _buildDivider(isDarkMode),

                  _buildDetailRow(
                    context,
                    visitType == 'clinic' 
                        ? context.tr('clinic_visit.doctor') 
                        : context.tr('common.location'),
                    providerName,
                    isDarkMode,
                  ),
                  _buildDivider(isDarkMode),

                  _buildDetailRow(
                    context,
                    context.tr('common.date'),
                    date,
                    isDarkMode,
                  ),
                  _buildDivider(isDarkMode),

                  _buildDetailRow(
                    context,
                    context.tr('common.time'),
                    time,
                    isDarkMode,
                  ),
                  _buildDivider(isDarkMode),

                  // Price
                  if (price != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('common.total_price'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontFamily: 'Almarai',
                            ),
                          ),
                          Text(
                            '$price ${context.tr('common.currency')}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontFamily: 'Almarai',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Confirm Button
            PrimaryButton(
              text: context.tr('common.confirm_reservation'),
              onPressed: onConfirm,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : AppColors.mediumGrey,
              fontFamily: 'Almarai',
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppColors.darkText,
                fontFamily: 'Almarai',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      color: isDarkMode ? Colors.white12 : Colors.black.withOpacity(0.05),
      height: 1,
    );
  }
}
