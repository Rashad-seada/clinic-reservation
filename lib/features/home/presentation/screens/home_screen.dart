import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/loading_shimmer.dart';
import 'package:arwa_app/features/home/presentation/screens/clinic_visit_screen.dart';
import 'package:arwa_app/features/home/presentation/screens/home_visit_screen.dart';
import 'package:arwa_app/features/home/presentation/view_models/home_view_model.dart';
import 'package:arwa_app/features/home/presentation/widgets/home_header.dart';
import 'package:arwa_app/features/home/presentation/widgets/reservation_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart' hide Trans;

/// Home Screen - Redesigned to match new UI specs
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final viewModel = ref.read(homeViewModelProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5),
      body: homeState.isLoading
          ? _buildShimmerLoading(isDarkMode)
          : Stack(
              children: [
                Column(
                  children: [
                    // Custom Header with integrated filters
                    HomeHeader(
                      onAddNewPressed: _showAddAppointmentSheet,
                      selectedFilter: homeState.selectedFilter,
                      onFilterChanged: viewModel.setFilter,
                      allCount: homeState.allCount,
                      upcomingCount: homeState.upcomingCount,
                      pastCount: homeState.pastCount,
                    ),
                    const SizedBox(height: 16),
                    
                    // Reservations List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => await viewModel.refresh(),
                        child: homeState.filteredReservations.isEmpty
                            ? _buildEmptyState(context, isDarkMode)
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                itemCount: homeState.filteredReservations.length,
                                itemBuilder: (context, index) {
                                  final item = homeState.filteredReservations[index];
                                  return ReservationCard(
                                    item: item,
                                    onCancel: () {
                                      // TODO: Implement cancel logic
                                      Get.snackbar(
                                        context.tr('common.note'),
                                        context.tr('reservation.cancel_feature_coming_soon'),
                                      );
                                    },
                                    onReschedule: () {
                                      // TODO: Implement reschedule logic
                                      Get.snackbar(
                                        context.tr('common.note'),
                                        context.tr('reservation.reschedule_feature_coming_soon'),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: isDarkMode ? Colors.white24 : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('home.no_reservations'),
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
              fontSize: 16,
              fontFamily: 'Almarai',
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('home.add_new_reservation'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Almarai',
                color: isDarkMode ? Colors.white : AppColors.darkText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildOptionButton(
              context: context,
              icon: Icons.local_hospital_outlined,
              label: context.tr('home.clinic_visit'),
              color: AppColors.primary,
              isDarkMode: isDarkMode,
              onTap: () {
                Get.back();
                Get.to(
                  () => const ClinicVisitScreen(),
                  transition: Transition.rightToLeft,
                );
              },
            ),
            const SizedBox(height: 16),
            _buildOptionButton(
              context: context,
              icon: Icons.home_outlined,
              label: context.tr('home.home_visit'),
              color: AppColors.secondary,
              isDarkMode: isDarkMode,
              onTap: () {
                Get.back();
                Get.to(
                  () => const HomeVisitScreen(),
                  transition: Transition.rightToLeft,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.darkText,
                fontFamily: 'Almarai',
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShimmerLoading(bool isDarkMode) {
    return Column(
      children: [
        // Header Shimmer
        Container(
          height: 200,
          color: AppColors.primary,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        const SizedBox(height: 32),
        // List Shimmer
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.separated(
              itemCount: 3,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (c, i) => const ShimmerCard(
                height: 180,
                borderRadius: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}