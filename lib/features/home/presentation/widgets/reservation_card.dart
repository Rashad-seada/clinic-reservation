import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/features/home/domain/entities/reservation_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ReservationCard extends StatelessWidget {
  final ReservationItem item;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  const ReservationCard({
    super.key,
    required this.item,
    this.onCancel,
    this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isClinic = item.type == 'clinic';
    final statusColor = _getStatusColor(item.status);
    final statusText = item.status == 'pending' ? context.tr('reservation.pending') :
                       item.status == 'confirmed' ? context.tr('reservation.confirmed') :
                       item.status == 'completed' ? context.tr('reservation.done') :
                       context.tr('reservation.cancelled');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Align(
            alignment: AlignmentDirectional.topStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Almarai',
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Doctor Name & Specialty
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : AppColors.darkText,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Almarai',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.grey[600],
                              fontSize: 14,
                              fontFamily: 'Almarai',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 4,
                      decoration: BoxDecoration(
                        color: isClinic ? AppColors.primary : AppColors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Details Row 1
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        context.tr('reservation.date'),
                        DateFormat('d MMMM yyyy', context.locale.languageCode).format(item.date),
                        Icons.calendar_today,
                        isDarkMode,
                        endAligned: true,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        context.tr('reservation.time'),
                        item.time,
                        Icons.access_time,
                        isDarkMode,
                        endAligned: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Details Row 2
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        isClinic ? context.tr('reservation.location') : context.tr('reservation.address'),
                        item.location ?? '-',
                        Icons.location_on,
                        isDarkMode,
                        endAligned: true,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        context.tr('reservation.phone'),
                        item.phone ?? '-',
                        Icons.phone,
                        isDarkMode,
                        endAligned: true,
                      ),
                    ),
                  ],
                ),
                
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('reservation.notes'),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.grey[600],
                            fontSize: 12,
                            fontFamily: 'Almarai',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.notes!,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : AppColors.darkText,
                            fontSize: 14,
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
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isDarkMode, {
    bool endAligned = false,
  }) {
    return Row(
      mainAxisAlignment: endAligned ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (endAligned) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.grey[500],
                    fontSize: 11,
                    fontFamily: 'Almarai',
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Almarai',
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: AppColors.primary),
        ] else ...[
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.grey[500],
                    fontSize: 11,
                    fontFamily: 'Almarai',
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Almarai',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case '1':
        return const Color(0xFF2ECC71); // Green
      case 'completed':
      case '2':
        return Colors.blue;
      case 'cancelled':
      case '3':
        return AppColors.error;
      default:
        return const Color(0xFFFFA500); // Orange for pending
    }
  }

  bool isUpcoming() {
    final now = DateTime.now().subtract(const Duration(days: 1));
    return item.date.isAfter(now) && 
           item.status != 'cancelled' && item.status != 'completed';
  }
}
