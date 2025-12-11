import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/app_dropdown.dart';
import 'package:arwa_app/core/widgets/input_field.dart';
import 'package:arwa_app/core/widgets/loading_shimmer.dart';
import 'package:arwa_app/core/widgets/primary_button.dart';
import 'package:arwa_app/core/widgets/status_banners.dart';
import 'package:arwa_app/features/home/domain/entities/booking_data.dart';
import 'package:arwa_app/features/home/domain/entities/service.dart';
import 'package:arwa_app/features/home/presentation/screens/reservation_success_screen.dart';
import 'package:arwa_app/features/home/presentation/screens/receipt_screen.dart';
import 'package:arwa_app/features/home/presentation/view_models/home_visit_view_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/map_style.dart';

/// Home Visit Screen - Redesigned to match UI specifications
class HomeVisitScreen extends ConsumerStatefulWidget {
  const HomeVisitScreen({super.key});

  @override
  ConsumerState<HomeVisitScreen> createState() => _HomeVisitScreenState();
}

class _HomeVisitScreenState extends ConsumerState<HomeVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  LocationData? _selectedLocationData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
      _initializeControllers();
    });
  }

  Future<void> _initializeLocation() async {
    await ref.read(homeVisitViewModelProvider.notifier).getCurrentLocation();
  }

  void _initializeControllers() {
    final viewModel = ref.read(homeVisitViewModelProvider.notifier);
    final viewState = ref.read(homeVisitViewModelProvider);
    
    // Initialize mobile controller with patient phone
    if (viewState.patient?.phone != null && viewModel.mobileController.text.isEmpty) {
      viewModel.mobileController.text = viewState.patient!.phone!;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final viewModel = ref.read(homeVisitViewModelProvider.notifier);
    final viewState = ref.read(homeVisitViewModelProvider);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewState.selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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

  Future<void> _selectTime(BuildContext context) async {
    final viewModel = ref.read(homeVisitViewModelProvider.notifier);
    final viewState = ref.read(homeVisitViewModelProvider);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: viewState.selectedTime ?? TimeOfDay.now(),
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
      viewModel.selectTime(picked);
    }
  }

  Future<void> _handleLocationSelection() async {
    final result = await Get.to<LocationData>(
      () => LocationSelectorScreen(
        initialLocation: _selectedLocationData,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocationData = result;
      });
      ref.read(homeVisitViewModelProvider.notifier).setLocation(
            result.latitude,
            result.longitude,
            result.address,
          );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final viewState = ref.read(homeVisitViewModelProvider);
    final viewModel = ref.read(homeVisitViewModelProvider.notifier);

    // Navigate to Receipt Screen
    Get.to(() => ReceiptScreen(
      patientName: viewState.patient?.username ?? '',
      serviceName: viewState.selectedServiceName ?? '',
      providerName: viewState.currentLocation?.split(',').map((e) => double.parse(e).toStringAsFixed(4)).join(', ') ?? '',
      date: DateFormat('dd/MM/yyyy').format(viewState.selectedDate!),
      time: viewState.selectedTime?.format(context) ?? '',
      price: viewState.price,
      visitType: 'home',
      isLoading: viewState.isSubmitting,
      onConfirm: () async {
        final success = await viewModel.submitReservation();
        if (success) {
          final now = TimeOfDay.now();
          Get.off(() => ReservationSuccessScreen(
            visitType: 'home',
            clinicName: viewState.selectedClinicName,
            serviceName: viewState.selectedServiceName,
            date: viewState.selectedDate ?? DateTime.now(),
            time: viewState.selectedTime ?? now,
          ));
        }
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(homeVisitViewModelProvider);
    final viewModel = ref.read(homeVisitViewModelProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final language = context.locale.languageCode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5),
      body: viewState.isLoading
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
                              context.tr('home_visit.book_home_visit'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Almarai',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.tr('home_visit.doctor_visit_message'),
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

                          // Clinic Dropdown
                          _buildDropdownField(
                            label: context.tr('home_visit.select_clinic'),
                            child: AppDropdown<Clinic>(
                              items: viewState.clinics,
                              value: viewState.clinics
                                  .where((c) => c.id == viewState.selectedClinicId)
                                  .firstOrNull,
                              hint: context.tr('home_visit.select_clinic'),
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

                          // City Dropdown
                          _buildDropdownField(
                            label: context.tr('home_visit.select_city'),
                            child: AppDropdown<City>(
                              items: viewState.cities,
                              value: viewState.cities
                                  .where((c) => c.id == viewState.selectedCityId)
                                  .firstOrNull,
                              hint: context.tr('home_visit.select_city'),
                              itemLabel: (city) => city.name ?? '',
                              onChanged: (city) {
                                if (city != null) {
                                  viewModel.selectCity(city.id!);
                                }
                              },
                            ),
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 16),

                          // Service Dropdown
                          _buildDropdownField(
                            label: context.tr('home_visit.service'),
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

                          // Date Picker
                          _buildDateTimePicker(
                            label: context.tr('home_visit.select_date'),
                            value: viewState.selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(viewState.selectedDate!)
                                : null,
                            hint: context.tr('home_visit.select_date'),
                            icon: Icons.calendar_today,
                            onTap: () => _selectDate(context),
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 16),

                          // Time Picker
                          _buildDateTimePicker(
                            label: context.tr('home_visit.select_time'),
                            value: viewState.selectedTime?.format(context),
                            hint: context.tr('home_visit.select_time'),
                            icon: Icons.access_time,
                            onTap: () => _selectTime(context),
                            isDarkMode: isDarkMode,
                          ),
                          const SizedBox(height: 16),

                          // Phone Number
                          _buildTextField(
                            label: context.tr('home_visit.mobile_number'),
                            controller: viewModel.mobileController,
                            hint: context.tr('home_visit.enter_mobile'),
                            keyboardType: TextInputType.phone,
                            isDarkMode: isDarkMode,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return context.tr('home_visit.enter_mobile');
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Location Selection
                          _buildLocationSelector(isDarkMode),
                          const SizedBox(height: 16),

                          // Symptoms/Notes (Optional)
                          _buildTextField(
                            label: '${context.tr('home_visit.symptoms')} (${context.tr('common.optional')})',
                            controller: viewModel.symptomsController,
                            hint: context.tr('home_visit.enter_symptoms'),
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

  Widget _buildLocationSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          context.tr('home_visit.address'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.darkText,
            fontFamily: 'Almarai',
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _handleLocationSelection,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.mediumGrey.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedLocationData?.address ?? context.tr('home_visit.select_on_map'),
                    style: TextStyle(
                      color: _selectedLocationData != null
                          ? (isDarkMode ? Colors.white : AppColors.darkText)
                          : AppColors.mediumGrey,
                      fontFamily: 'Almarai',
                    ),
                    textAlign: TextAlign.right,
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

// Location Data Model
class LocationData {
  final double latitude;
  final double longitude;
  final String address;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

// Location Selector Screen
class LocationSelectorScreen extends StatefulWidget {
  final LocationData? initialLocation;

  const LocationSelectorScreen({
    super.key,
    this.initialLocation,
  });

  @override
  State<LocationSelectorScreen> createState() => _LocationSelectorScreenState();
}

class _LocationSelectorScreenState extends State<LocationSelectorScreen> {
  GoogleMapController? _mapController;
  LatLng _selectedPosition = const LatLng(24.7136, 46.6753); // Riyadh default
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedPosition = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_selectedPosition),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController?.setMapStyle(darkMapStyle);
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
  }

  void _confirmLocation() {
    Get.back(
      result: LocationData(
        latitude: _selectedPosition.latitude,
        longitude: _selectedPosition.longitude,
        address: '${_selectedPosition.latitude.toStringAsFixed(6)}, ${_selectedPosition.longitude.toStringAsFixed(6)}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('location.select_location')),
        backgroundColor: AppColors.primary,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 15,
            ),
            onTap: _onMapTap,
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedPosition,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.white,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Icon(Icons.my_location, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: context.tr('location.confirm_location'),
                  onPressed: _confirmLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
