import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/input_field.dart';
import 'package:arwa_app/core/widgets/primary_button.dart';
import 'package:arwa_app/features/home/domain/entities/booking_data.dart';
import 'package:arwa_app/features/home/domain/entities/home_visit_request.dart';
import 'package:arwa_app/features/home/domain/repositories/home_visit_repository.dart';
import 'package:arwa_app/features/home/domain/repositories/patient_repository.dart';
import 'package:arwa_app/features/home/presentation/screens/reservation_success_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:arwa_app/features/home/domain/entities/service.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/map_style.dart';
import '../../domain/repositories/appointment_repository.dart';

class HomeVisitScreen extends ConsumerStatefulWidget {
  const HomeVisitScreen({super.key});

  @override
  ConsumerState<HomeVisitScreen> createState() => _HomeVisitScreenState();
}

class _HomeVisitScreenState extends ConsumerState<HomeVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();
  final _symptomsController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isLoadingClinicServices = false;
  String? _currentLocation;
  LocationData? _selectedLocationData;
  bool _dataLoaded = false;

  // Selected values
  int? _selectedClinicId;
  String? _selectedClinicName;
  int? _selectedCityId;
  int? _selectedServiceId;
  String? _selectedServiceName;

  // Booking data
  List<Clinic> _clinics = [];
  List<City> _cities = [];
  List<Service> _services = [];
  int? _patientId;

  @override
  void initState() {
    super.initState();
    // Don't load data here - context isn't ready
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      _loadBookingData();
    }
  }

  Future<void> _loadClinicServices(int clinicId) async {
    if (!mounted) return;

    setState(() {
      _isLoadingClinicServices = true;
      _selectedServiceId = null;
      _selectedServiceName = null;
      _services = [];
    });

    try {
      final appointmentRepository = GetIt.instance<AppointmentRepository>();

      // Get locale safely from context
      final locale = Localizations.localeOf(context);

      debugPrint('🔄 Loading clinic services for clinic ID: $clinicId, language: ${locale.languageCode}');

      final clinicServicesResponse = await appointmentRepository.getClinicServices(
        clinicId,
        language: locale.languageCode,
      );

      debugPrint('✅ Clinic services loaded successfully: ${clinicServicesResponse.services.length} services found');

      if (!mounted) return;

      setState(() {
        _services = clinicServicesResponse.services;
        _isLoadingClinicServices = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading clinic services for home visit: $e');
      if (!mounted) return;

      setState(() {
        _isLoadingClinicServices = false;
      });

      // Show snackbar safely
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          context.tr('error'),
          context.tr('home_visit.failed_to_load_services'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.9),
          colorText: Colors.white,
        );
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar(
              context.tr('location.permission_denied'),
              context.tr('location.permission_denied_message'),
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error.withOpacity(0.9),
              colorText: Colors.white,
            );
          });
          _useFallbackLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            context.tr('location.permission_denied'),
            context.tr('location.permission_denied_message'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error.withOpacity(0.9),
            colorText: Colors.white,
          );
        });
        _useFallbackLocation();
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      setState(() {
        _currentLocation = "${position.latitude},${position.longitude}";
        _isLoading = false;
      });

      debugPrint('📍 Current location: $_currentLocation');
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      _useFallbackLocation();
    }
  }

  void _useFallbackLocation() {
    if (!mounted) return;

    setState(() {
      _currentLocation = "30.0444,31.2357";
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        context.tr('location.unavailable'),
        context.tr('location.using_default_location'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
      );
    });
  }

  Future<void> _loadBookingData() async {
    if (!mounted || _dataLoaded) return;

    setState(() {
      _isLoadingData = true;
    });

    try {
      final patientRepository = GetIt.instance<PatientRepository>();
      final bookingData = patientRepository.getStoredBookingData();
      final patientId = patientRepository.getPatientId();

      debugPrint('🔄 Loading booking data...');

      if (bookingData != null && patientId != null) {
        debugPrint('✅ Using stored booking data: ${bookingData.clinics.length} clinics, ${bookingData.cities.length} cities');

        if (!mounted) return;

        setState(() {
          _clinics = bookingData.clinics;
          _cities = bookingData.cities;
          _patientId = patientId;

          if (_clinics.isNotEmpty) {
            _selectedClinicId = _clinics.first.id;
            _selectedClinicName = _clinics.first.name;
          }
          if (_cities.isNotEmpty) {
            _selectedCityId = _cities.first.id;
          }

          _isLoadingData = false;
          _dataLoaded = true;
        });

        // Load services for the default clinic
        if (_selectedClinicId != null) {
          await _loadClinicServices(_selectedClinicId!);
        }
      } else {
        try {
          debugPrint('🔄 Fetching patient info from API...');
          final patientInfoResponse = await patientRepository.getPatientInfo();

          debugPrint('✅ Patient info loaded: ${patientInfoResponse.bookingAppointmentData.clinics.length} clinics');

          if (!mounted) return;

          setState(() {
            _clinics = patientInfoResponse.bookingAppointmentData.clinics;
            _cities = patientInfoResponse.bookingAppointmentData.cities;
            _patientId = patientInfoResponse.patient.id;

            if (_clinics.isNotEmpty) {
              _selectedClinicId = _clinics.first.id;
              _selectedClinicName = _clinics.first.name;
            }
            if (_cities.isNotEmpty) {
              _selectedCityId = _cities.first.id;
            }

            _isLoadingData = false;
            _dataLoaded = true;
          });

          if (_selectedClinicId != null) {
            await _loadClinicServices(_selectedClinicId!);
          }
        } catch (apiError) {
          debugPrint('❌ API Error loading patient info: $apiError');
          _provideFallbackData();
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading booking data: $e');
      _provideFallbackData();
    }
  }

  void _provideFallbackData() {
    if (!mounted) return;

    final fallbackClinics = [
      Clinic(id: 1, name: "Main Clinic"),
      Clinic(id: 2, name: "Branch Clinic"),
      Clinic(id: 3, name: "Specialty Clinic"),
    ];

    final fallbackCities = [
      City(id: 1, name: "Cairo"),
      City(id: 2, name: "Alexandria"),
      City(id: 5, name: "Giza"),
    ];

    debugPrint('🔄 Using fallback data: ${fallbackClinics.length} clinics, ${fallbackCities.length} cities');

    setState(() {
      _clinics = fallbackClinics;
      _cities = fallbackCities;
      _patientId = _patientId ?? 9284;

      _selectedClinicId = fallbackClinics.first.id;
      _selectedClinicName = fallbackClinics.first.name;
      _selectedCityId = fallbackCities.first.id;

      _isLoadingData = false;
      _dataLoaded = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        context.tr('location.offline_mode'),
        context.tr('location.using_sample_data'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mobileController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
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

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      Get.snackbar(
        context.tr('error'),
        context.tr('home_visit.please_select_date'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedTime == null) {
      Get.snackbar(
        context.tr('error'),
        context.tr('home_visit.please_select_time'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedClinicId == null) {
      Get.snackbar(
        context.tr('error'),
        context.tr('home_visit.please_select_clinic'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedCityId == null) {
      Get.snackbar(
        context.tr('error'),
        context.tr('home_visit.please_select_city'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    // NEW VALIDATION: Check if service is selected
    if (_selectedServiceId == null) {
      Get.snackbar(
        context.tr('error'),
        context.tr('home_visit.please_select_service'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (_patientId == null) {
      Get.snackbar(
        context.tr('error'),
        context.tr('home_visit.patient_not_found'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    if (_currentLocation == null) {
      Get.snackbar(
        context.tr('error'),
        context.tr('home_visit.location_not_available'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final homeVisitRepository = GetIt.instance<HomeVisitRepository>();

      final visitDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final time = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').format(
        DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ),
      );

      // Create request - UPDATED to use serviceId instead of free-text service
      final request = HomeVisitRequest(
        clinicId: _selectedClinicId!,
        patientId: _patientId!,
        cityId: _selectedCityId!,
        mobile: _mobileController.text,
        address: _addressController.text,
        location: _currentLocation!,
        visitDate: visitDate,
        time: time,
        serviceId: _selectedServiceId!,
        service: _selectedServiceName!,
        symptoms: _symptomsController.text,
      );

      debugPrint('📤 Submitting home visit request:');
      debugPrint('   - Clinic ID: ${request.clinicId}');
      debugPrint('   - Patient ID: ${request.patientId}');
      debugPrint('   - City ID: ${request.cityId}');
      debugPrint('   - Service ID: ${request.serviceId}');
      debugPrint('   - Service: ${request.service}');
      debugPrint('   - Date: ${request.visitDate}');
      debugPrint('   - Time: ${request.time}');
      debugPrint('   - Location: ${request.location}');
      debugPrint('   - Mobile: ${request.mobile}');
      debugPrint('   - Address: ${request.address}');

      final response = await homeVisitRepository.scheduleHomeVisit(request);

      debugPrint('📥 Home visit response: $response');

      setState(() {
        _isLoading = false;
      });

      if (response['status'] == 'success') {
        final clinicName = _clinics.firstWhere((clinic) => clinic.id == _selectedClinicId).name;

        debugPrint('✅ Home visit booked successfully for clinic: $clinicName');

        Get.off(() => ReservationSuccessScreen(
          visitType: 'home',
          clinicName: clinicName,
          serviceName: _selectedServiceName!,
          date: _selectedDate!,
          time: _selectedTime!,
        ));
      } else {
        debugPrint('❌ Home visit booking failed: ${response['msg']}');
        Get.snackbar(
          context.tr('error'),
          response['msg'] ?? context.tr('home_visit.failed_schedule'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Exception during home visit booking: $e');
      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        context.tr('error'),
        context.tr('home_visit.failed_schedule'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  Future<void> _selectLocationFromMap() async {
    try {
      final result = await Get.to<LocationData>(() => const LocationSelectorScreen());
      if (result != null) {
        setState(() {
          _selectedLocationData = result;
          _currentLocation = result.coordinates;
        });
        debugPrint('📍 Location selected from map: $_currentLocation');
      }
    } catch (e) {
      debugPrint('❌ Error selecting location from map: $e');
      Get.snackbar(
        context.tr('error'),
        context.tr('home_visit.failed_select_location'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('home_visit.book_home_visit'),
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoadingData
          ? Center(child: Text(context.tr('common.loading')))
          : SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  context.tr('home_visit.home_visit_request'),
                  context.tr('home_visit.doctor_visit_message'),
                  Icons.home_outlined,
                  isDarkMode,
                ),
                const SizedBox(height: 32),

                _buildSectionTitle(context.tr('home_visit.select_clinic'), isDarkMode),
                const SizedBox(height: 8),
                _buildClinicDropdown(isDarkMode),
                const SizedBox(height: 24),

                _buildSectionTitle(context.tr('home_visit.select_city'), isDarkMode),
                const SizedBox(height: 8),
                _buildCityDropdown(isDarkMode),
                const SizedBox(height: 24),

                // NEW: Service Selection (only show after clinic is selected)
                if (_selectedClinicId != null) ...[
                  _buildSectionTitle(context.tr('clinic_visit.select_service'), isDarkMode),
                  const SizedBox(height: 8),
                  _buildServiceDropdown(isDarkMode),
                  const SizedBox(height: 24),
                ],

                _buildSectionTitle(context.tr('home_visit.mobile_number'), isDarkMode),
                const SizedBox(height: 8),
                InputField(
                  controller: _mobileController,
                  hint: context.tr('home_visit.enter_mobile'),
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('home_visit.enter_mobile');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                _buildSectionTitle(context.tr('home_visit.address'), isDarkMode),
                const SizedBox(height: 8),
                InputField(
                  controller: _addressController,
                  hint: context.tr('home_visit.enter_address'),
                  prefixIcon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('home_visit.enter_address');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildSectionTitle(context.tr('home_visit.location_coordinates'), isDarkMode),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.mediumGrey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.gps_fixed,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentLocation ?? context.tr('home_visit.no_location'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.white
                                      : AppColors.darkText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.map, color: Colors.white),
                        onPressed: _selectLocationFromMap,
                        tooltip: context.tr('home_visit.select_on_map'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.my_location, color: Colors.white),
                        onPressed: _getCurrentLocation,
                        tooltip: context.tr('home_visit.use_current_location'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSectionTitle(context.tr('home_visit.select_date_time'), isDarkMode),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(isDarkMode),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimePicker(isDarkMode),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSectionTitle(context.tr('home_visit.symptoms'), isDarkMode),
                const SizedBox(height: 8),
                InputField(
                  controller: _symptomsController,
                  hint: context.tr('home_visit.enter_symptoms'),
                  prefixIcon: Icons.sick_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('home_visit.enter_symptoms');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                PrimaryButton(
                  text: context.tr('home_visit.book_home_visit'),
                  isLoading: _isLoading,
                  onPressed: _submitReservation,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? Colors.white : AppColors.darkText,
      ),
    );
  }

  Widget _buildClinicDropdown(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mediumGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedClinicId,
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
          elevation: 16,
          isExpanded: true,
          dropdownColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.darkText,
            fontSize: 16,
          ),
          hint: Row(
            children: [
              Icon(
                Icons.local_hospital_outlined,
                color: AppColors.mediumGrey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('home_visit.select_clinic'),
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          onChanged: (int? newValue) {
            setState(() {
              _selectedClinicId = newValue;
              _selectedClinicName = _clinics.firstWhere((clinic) => clinic.id == newValue).name;
              _selectedServiceId = null;
              _selectedServiceName = null;
            });

            if (newValue != null) {
              _loadClinicServices(newValue);
            }
          },
          items: _clinics.map<DropdownMenuItem<int>>((Clinic clinic) {
            return DropdownMenuItem<int>(
              value: clinic.id,
              child: Row(
                children: [
                  Icon(
                    Icons.local_hospital_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    clinic.name,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildServiceDropdown(bool isDarkMode) {
    if (_isLoadingClinicServices) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mediumGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedServiceId,
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
          elevation: 16,
          isExpanded: true,
          dropdownColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.darkText,
            fontSize: 16,
          ),
          hint: Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: AppColors.mediumGrey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('clinic_visit.select_service'),
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          onChanged: (int? newValue) {
            setState(() {
              _selectedServiceId = newValue;
              _selectedServiceName = _services.firstWhere((service) => service.id == newValue).name;
            });
          },
          items: _services.map<DropdownMenuItem<int>>((Service service) {
            return DropdownMenuItem<int>(
              value: service.id,
              child: Row(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      service.name,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : AppColors.darkText,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCityDropdown(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mediumGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedCityId,
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
          elevation: 16,
          isExpanded: true,
          dropdownColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.darkText,
            fontSize: 16,
          ),
          hint: Row(
            children: [
              Icon(
                Icons.location_city,
                color: AppColors.mediumGrey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('home_visit.select_city'),
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          onChanged: (int? newValue) {
            setState(() {
              _selectedCityId = newValue;
            });
          },
          items: _cities.map<DropdownMenuItem<int>>((City city) {
            return DropdownMenuItem<int>(
              value: city.id,
              child: Row(
                children: [
                  Icon(
                    Icons.location_city,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    city.name,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool isDarkMode) {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.mediumGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _selectedDate != null ? AppColors.primary : AppColors.mediumGrey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _selectedDate != null
                  ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                  : context.tr('home_visit.select_date'),
              style: TextStyle(
                color: _selectedDate != null
                    ? (isDarkMode ? Colors.white : AppColors.darkText)
                    : AppColors.mediumGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(bool isDarkMode) {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.mediumGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: _selectedTime != null ? AppColors.primary : AppColors.mediumGrey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              _selectedTime != null
                  ? _selectedTime!.format(context)
                  : context.tr('home_visit.select_time'),
              style: TextStyle(
                color: _selectedTime != null
                    ? (isDarkMode ? Colors.white : AppColors.darkText)
                    : AppColors.mediumGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class LocationData {
  final String coordinates;
  final LatLng latLng;

  LocationData({
    required this.coordinates,
    required this.latLng,
  });
}

class LocationSelectorScreen extends StatefulWidget {
  const LocationSelectorScreen({super.key});

  @override
  State<LocationSelectorScreen> createState() => _LocationSelectorScreenState();
}

class _LocationSelectorScreenState extends State<LocationSelectorScreen> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(30.0444, 31.2357); // Default to Cairo
  LatLng? _currentLocation;
  bool _isLoading = false;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            context.tr('location.permission_denied'),
            context.tr('location.permission_denied_message'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error.withOpacity(0.9),
            colorText: Colors.white,
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          context.tr('location.permission_denied'),
          context.tr('location.permission_denied_message'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.9),
          colorText: Colors.white,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      final currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = currentLatLng;
        _selectedLocation = currentLatLng;
        _updateMarker(currentLatLng);
        _isLoading = false;
      });

      // Move camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLatLng,
            zoom: 15,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      Get.snackbar(
        context.tr('error'),
        context.tr('home_visit.failed_get_location'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: '${position.latitude}, ${position.longitude}',
          ),
        ),
      );
    });
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
      _updateMarker(latLng);
    });
  }

  void _confirmLocation() {
    final result = LocationData(
      coordinates: '${_selectedLocation.latitude},${_selectedLocation.longitude}',
      latLng: _selectedLocation,
    );
    Get.back(result: result);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('location.select_location'),
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (isDarkMode) {
                _setMapDarkMode(controller);
              }
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onTap: _onMapTap,
          ),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Bottom panel with coordinates and buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('location.selected_coordinates'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.mediumGrey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.gps_fixed,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_selectedLocation.latitude}, ${_selectedLocation.longitude}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.darkText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Current location button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: Text(context.tr('location.current_location')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey[200],
                            foregroundColor: isDarkMode
                                ? Colors.white
                                : AppColors.darkText,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Confirm button
                      Expanded(
                        child: PrimaryButton(
                          text: context.tr('location.confirm_location'),
                          onPressed: _confirmLocation,
                          height: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setMapDarkMode(GoogleMapController controller) {
    controller.setMapStyle(darkMapStyle);
  }
}



