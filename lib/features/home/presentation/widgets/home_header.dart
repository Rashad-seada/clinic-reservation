import 'package:arwa_app/core/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import '../screens/settings_screen.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onAddNewPressed;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final int allCount;
  final int upcomingCount;
  final int pastCount;

  const HomeHeader({
    super.key,
    required this.onAddNewPressed,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.allCount,
    required this.upcomingCount,
    required this.pastCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [

              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white,size: 32,),
                onPressed: () {},
              ),

              SizedBox(width: 12,),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('home.my_reservations'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Almarai',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('home.view_manage_appointments'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontFamily: 'Almarai',
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: () {
                    Get.to(
                      () => SettingsScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterTab(
                  context,
                  'all',
                  context.tr('home.filter_all'),
                  allCount,
                  Icons.list_alt,
                ),
                const SizedBox(width: 12),
                _buildFilterTab(
                  context,
                  'upcoming',
                  context.tr('home.filter_upcoming'),
                  upcomingCount,
                  Icons.upcoming,
                ),
                const SizedBox(width: 12),
                _buildFilterTab(
                  context,
                  'past',
                  context.tr('home.filter_past'),
                  pastCount,
                  Icons.history,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddNewPressed,
              icon: Icon(
                Icons.add_circle,
                color: AppColors.primary,
              ),
              label: Text(
                context.tr('home.add_new_reservation'),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Almarai',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(
    BuildContext context,
    String filter,
    String label,
    int count,
    IconData icon,
  ) {
    final isSelected = selectedFilter == filter;
    
    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontFamily: 'Almarai',
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
