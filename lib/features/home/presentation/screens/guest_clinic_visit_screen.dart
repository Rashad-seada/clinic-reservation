import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/app_dropdown.dart';
import 'package:arwa_app/core/widgets/loading_shimmer.dart';
import 'package:arwa_app/core/widgets/primary_button.dart';
import 'package:arwa_app/core/widgets/status_banners.dart';
import 'package:arwa_app/features/home/domain/entities/booking_data.dart';
import 'package:arwa_app/features/home/domain/entities/doctor.dart';
import 'package:arwa_app/features/home/domain/entities/doctor_schedule_response.dart';
import 'package:arwa_app/features/home/domain/entities/service.dart';
import 'package:arwa_app/features/home/presentation/screens/reservation_success_screen.dart';
import 'package:arwa_app/features/home/presentation/screens/receipt_screen.dart';
import 'package:arwa_app/features/home/presentation/view_models/guest_clinic_visit_view_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Guest Clinic Visit Screen - For unregistered users
class GuestClinicVisitScreen extends ConsumerStatefulWidget {
  const GuestClinicVisitScreen({super.key});

  @override
  ConsumerState<GuestClinicVisitScreen> createState() => _GuestClinicVisitScreenState();
}

class _GuestClinicVisitScreenState extends ConsumerState<GuestClinicVisitScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initial data loading happens in ViewModel provider creation
  }

  Future<void> _selectDate(BuildContext context) async {
    final viewModel = ref.read(guestClinicVisitViewModelProvider.notifier);
    final viewState = ref.read(guestClinicVisitViewModelProvider);

    if (!viewState.hasDoctorSelected) {
      Get.snackbar(
        context.tr('common.error'),
        context.tr('clinic_visit.please_select_doctor_first'), // Reuse existing keys
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    // Note: If schedule loading fails (due to auth), this might be empty.
    if (!viewState.hasAvailableSchedules) {
      Get.snackbar(
        context.tr('common.error'),
        context.tr('clinic_visit.no_available_dates'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final availableDates = viewState.doctorSchedules.map((s) => s.date).toList();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: availableDates.first,
      firstDate: availableDates.first,
      lastDate: availableDates.last,
      selectableDayPredicate: (DateTime day) {
        return availableDates.any((date) => DateUtils.isSameDay(date, day));
      },
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
      viewModel.selectDate(picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final viewState = ref.read(guestClinicVisitViewModelProvider);
    final viewModel = ref.read(guestClinicVisitViewModelProvider.notifier);

    // Navigate to Receipt Screen
    Get.to(() => ReceiptScreen(
      patientName: viewState.fullName ?? '', // Use entered full name
      serviceName: viewState.selectedServiceName ?? '',
      providerName: viewState.selectedDoctorName ?? '',
      date: DateFormat('dd/MM/yyyy').format(viewState.selectedDate!),
      time: viewState.selectedTimeText ?? '',
      price: viewState.price,
      visitType: 'clinic',
      isLoading: viewState.isSubmitting,
      onConfirm: () async {
        final success = await viewModel.submitGuestReservation();
        if (success) {
          final timeValue = viewState.selectedTimeSlot?.value ?? '00:00';
          final timeParts = timeValue.split(':');
          final timeOfDay = TimeOfDay(
            hour: int.tryParse(timeParts[0]) ?? 0,
            minute: int.tryParse(timeParts[1]) ?? 0,
          );

          Get.off(() => ReservationSuccessScreen(
            visitType: 'clinic',
            clinicName: viewState.selectedClinicName,
            doctorName: viewState.selectedDoctorName,
            serviceName: viewState.selectedServiceName,
            date: viewState.selectedDate ?? DateTime.now(),
            time: timeOfDay,
          ));
        }
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(guestClinicVisitViewModelProvider);
    final viewModel = ref.read(guestClinicVisitViewModelProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final language = context.locale.languageCode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5),
      body: viewState.isLoadingData
          ? _buildShimmerLoading(isDarkMode)
          : CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverAppBar(
                  expandedHeight: 160,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              context.tr('clinic_visit.book_clinic_visit'), 
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Almarai',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                             context.tr('clinic_visit.doctor_visit_message'),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontFamily: 'Almarai',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Form Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Error Banner
                          if (viewState.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ErrorBanner(
                                message: viewState.errorMessage!,
                                onDismiss: () => viewModel.clearError(),
                              ),
                            ),

                          // Full Name Field (NEW)
                          _buildTextField(
                            label: context.tr('auth.full_name'), // Reuse or add key
                            controller: viewModel.fullNameController,
                            hint: context.tr('auth.full_name'),
                            isDarkMode: isDarkMode,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.tr('common.error_required'); // "Required"
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Clinic Dropdown
                          _buildDropdownField(
                            label: context.tr('clinic_visit.select_clinic'),
                            child: AppDropdown<Clinic>(
                              items: viewState.clinics,
                              value: viewState.clinics
                                  .where((c) => c.id == viewState.selectedClinicId)
                                  .firstOrNull,
                              hint: context.tr('clinic_visit.select_clinic'),
                              itemLabel: (clinic) => clinic.name ?? '',
                              onChanged: (clinic) {
                                if (clinic != null) {
                                  viewModel.selectClinic(clinic.id!, clinic.name ?? '', language: language);
                                }
                              },
                            ),
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 16),

                          // Service Dropdown
                          _buildDropdownField(
                            label: context.tr('clinic_visit.select_service'),
                            child: AppDropdown<Service>(
                              items: viewState.services,
                              value: viewState.services
                                  .where((s) => s.id == viewState.selectedServiceId)
                                  .firstOrNull,
                              hint: context.tr('clinic_visit.select_service'),
                              itemLabel: (service) => service.name ?? '',
                              onChanged: (service) {
                                if (service != null) {
                                  viewModel.selectService(service.id!, service.name ?? '');
                                }
                              },
                            ),
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 16),

                          // Doctor Dropdown
                          _buildDropdownField(
                            label: context.tr('clinic_visit.select_doctor'),
                            child: AppDropdown<Doctor>(
                              items: viewState.doctors,
                              value: viewState.doctors
                                  .where((d) => d.id == viewState.selectedDoctorId)
                                  .firstOrNull,
                              hint: context.tr('clinic_visit.select_doctor'),
                              itemLabel: (doctor) => doctor.name ?? '',
                              onChanged: (doctor) {
                                if (doctor != null) {
                                  viewModel.selectDoctor(doctor.id!, doctor.name ?? '');
                                }
                              },
                            ),
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 16),

                          // Date Picker
                          _buildDateTimePicker(
                            label: context.tr('clinic_visit.select_date'),
                            value: viewState.selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(viewState.selectedDate!)
                                : null,
                            hint: context.tr('clinic_visit.select_date'),
                            icon: Icons.calendar_today,
                            onTap: () => _selectDate(context),
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 16),

                          // Time Slot Dropdown
                          if (viewState.hasDateSelected) ...[
                            _buildDropdownField(
                              label: context.tr('clinic_visit.select_time'),
                              child: AppDropdown<TimeSlot>(
                                items: viewState.availableTimeSlots,
                                value: viewState.selectedTimeSlot,
                                hint: context.tr('clinic_visit.select_time'),
                                itemLabel: (slot) => slot.text,
                                onChanged: (slot) {
                                  if (slot != null) {
                                    viewModel.selectTimeSlot(slot);
                                  }
                                },
                              ),
                              isDarkMode: isDarkMode,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Phone Number
                          _buildTextField(
                            label: context.tr('auth.phone'),
                            controller: viewModel.phoneController,
                            hint: context.tr('auth.enter_mobile'),
                            keyboardType: TextInputType.phone,
                            isDarkMode: isDarkMode,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.tr('auth.enter_mobile');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Reason for Visit (Optional)
                          _buildTextField(
                            label: '${context.tr('common.reason_for_visit')} (${context.tr('common.optional')})',
                            controller: viewModel.reasonController,
                            hint: context.tr('common.enter_reason'),
                            maxLines: 4,
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 32),

                          // Submit Button
                          PrimaryButton(
                            text: context.tr('common.book_appointment'),
                            onPressed: _handleSubmit,
                            isLoading: viewState.isLoading,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    TextEditingController? controller,
    required bool isDarkMode,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.darkText,
            fontFamily: 'Almarai',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: controller == null ? initialValue : null,
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          validator: validator,
          onChanged: onChanged,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.darkText,
            fontFamily: 'Almarai',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.mediumGrey,
              fontFamily: 'Almarai',
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.mediumGrey.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.mediumGrey.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.mediumGrey.withOpacity(0.2),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required Widget child,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.darkText,
            fontFamily: 'Almarai',
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.darkText,
            fontFamily: 'Almarai',
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.mediumGrey.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                Text(
                  value ?? hint,
                  style: TextStyle(
                    color: value != null
                        ? (isDarkMode ? Colors.white : AppColors.darkText)
                        : AppColors.mediumGrey,
                    fontFamily: 'Almarai',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(
          8,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ShimmerCard(
              height: index == 7 ? 100 : 56,
              borderRadius: 12,
            ),
          ),
        ),
      ),
    );
  }
}
