import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/input_field.dart';
import 'package:arwa_app/core/widgets/primary_button.dart';
import 'package:arwa_app/features/home/domain/entities/appointment_booking_request.dart';
import 'package:arwa_app/features/home/domain/entities/booking_data.dart';
import 'package:arwa_app/features/home/domain/entities/clinic_services_response.dart';
import 'package:arwa_app/features/home/domain/entities/doctor.dart';
import 'package:arwa_app/features/home/domain/entities/doctor_schedule_response.dart';
import 'package:arwa_app/features/home/domain/entities/service.dart';
import 'package:arwa_app/features/home/domain/repositories/appointment_repository.dart';
import 'package:arwa_app/features/home/domain/repositories/patient_repository.dart';
import 'package:arwa_app/features/home/presentation/screens/reservation_success_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class ClinicVisitScreen extends ConsumerStatefulWidget {
  const ClinicVisitScreen({super.key});

  @override
  ConsumerState<ClinicVisitScreen> createState() => _ClinicVisitScreenState();
}

class _ClinicVisitScreenState extends ConsumerState<ClinicVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTimeValue;
  String? _selectedTimeText;
  int? _selectedClinicId;
  String? _selectedClinicName;
  int? _selectedDoctorId;
  String? _selectedDoctorName;
  int? _selectedServiceId;
  String? _selectedServiceName;
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isLoadingClinicServices = false;
  bool _isLoadingDoctorSchedule = false;
  
  // Booking data
  List<Clinic> _clinics = [];
  List<InsuranceCompany> _insuranceCompanies = [];
  List<DiscountCard> _discountCards = [];
  List<WorkplaceCard> _workplaceCards = [];
  List<City> _cities = [];
  List<Doctor> _doctors = [];
  List<Service> _services = [];
  String? _availableStartDate;
  String? _availableEndDate;
  int? _patientId;
  
  // Doctor schedule data
  List<DoctorSchedule> _doctorSchedules = [];
  DoctorSchedule? _selectedSchedule;
  List<TimeSlot> _availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadBookingData();
  }

  Future<void> _loadBookingData() async {
    setState(() {
      _isLoadingData = true;
    });
    
    try {
      final patientRepository = GetIt.instance<PatientRepository>();
      final bookingData = patientRepository.getStoredBookingData();
      
      // Get patient ID
      _patientId = patientRepository.getPatientId();
      
      if (_patientId == null) {
        final patientData = patientRepository.getStoredPatientData();
        _patientId = patientData?.id;
      }
      
      if (bookingData != null) {
        setState(() {
          _clinics = bookingData.clinics;
          _insuranceCompanies = bookingData.insuranceCompanies;
          _discountCards = bookingData.discountCards;
          _workplaceCards = bookingData.workplaceCards;
          _cities = bookingData.cities;
          _isLoadingData = false;
        });
      } else {
        // If no stored data, fetch from API
        final patientInfoResponse = await patientRepository.getPatientInfo();
        setState(() {
          _clinics = patientInfoResponse.bookingAppointmentData.clinics;
          _insuranceCompanies = patientInfoResponse.bookingAppointmentData.insuranceCompanies;
          _discountCards = patientInfoResponse.bookingAppointmentData.discountCards;
          _workplaceCards = patientInfoResponse.bookingAppointmentData.workplaceCards;
          _cities = patientInfoResponse.bookingAppointmentData.cities;
          _isLoadingData = false;
          
          // Update patient ID if needed
          if (_patientId == null && patientInfoResponse.patient.id != null) {
            _patientId = patientInfoResponse.patient.id;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading booking data: $e');
      setState(() {
        _isLoadingData = false;
      });
      Get.snackbar(
        context.tr('error'),
        context.tr('clinic_visit.failed_to_load_clinic_data'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Future<void> _loadClinicServices(int clinicId) async {
    setState(() {
      _isLoadingClinicServices = true;
      _selectedDoctorId = null;
      _selectedDoctorName = null;
      _selectedServiceId = null;
      _selectedServiceName = null;
      _doctors = [];
      _services = [];
      _doctorSchedules = [];
      _selectedSchedule = null;
      _availableTimeSlots = [];
      _selectedDate = null;
      _selectedTimeValue = null;
      _selectedTimeText = null;
    });
    
    try {
      final appointmentRepository = GetIt.instance<AppointmentRepository>();
      final clinicServicesResponse = await appointmentRepository.getClinicServices(
        clinicId, 
        language: context.locale.languageCode,
      );
      
      setState(() {
        _doctors = clinicServicesResponse.doctors;
        _services = clinicServicesResponse.services;
        _availableStartDate = clinicServicesResponse.availableStartDate;
        _availableEndDate = clinicServicesResponse.availableEndDate;
        _isLoadingClinicServices = false;
      });
    } catch (e) {
      debugPrint('Error loading clinic services: $e');
      setState(() {
        _isLoadingClinicServices = false;
      });
      Get.snackbar(
        context.tr('error'),
        context.tr('clinic_visit.failed_to_load_services'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
  
  Future<void> _loadDoctorSchedule() async {
    if (_selectedDoctorId == null || _selectedClinicId == null) return;
    
    setState(() {
      _isLoadingDoctorSchedule = true;
      _doctorSchedules = [];
      _selectedSchedule = null;
      _availableTimeSlots = [];
      _selectedDate = null;
      _selectedTimeValue = null;
      _selectedTimeText = null;
    });
    
    try {
      final appointmentRepository = GetIt.instance<AppointmentRepository>();
      final doctorScheduleResponse = await appointmentRepository.getDoctorSchedule(
        doctorId: _selectedDoctorId!,
        clinicId: _selectedClinicId!,
        language: context.locale.languageCode,
      );
      
      setState(() {
        _doctorSchedules = doctorScheduleResponse.scheduleDoctor;
        _isLoadingDoctorSchedule = false;
      });
    } catch (e) {
      debugPrint('Error loading doctor schedule: $e');
      setState(() {
        _isLoadingDoctorSchedule = false;
      });
      Get.snackbar(
        context.tr('error'),
        context.tr('clinic_visit.failed_to_load_schedule'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
  
  void _updateAvailableTimeSlots() {
    if (_selectedDate == null || _doctorSchedules.isEmpty) {
      setState(() {
        _availableTimeSlots = [];
        _selectedTimeValue = null;
        _selectedTimeText = null;
      });
      return;
    }
    
    // Find the schedule for the selected date
    final selectedSchedule = _doctorSchedules.firstWhere(
      (schedule) => DateUtils.isSameDay(schedule.date, _selectedDate),
      orElse: () => DoctorSchedule(date: _selectedDate!, timeSlots: []),
    );
    
    setState(() {
      _selectedSchedule = selectedSchedule;
      _availableTimeSlots = selectedSchedule.timeSlots.where((slot) => !slot.disabled).toList();
      _selectedTimeValue = null;
      _selectedTimeText = null;
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    if (_selectedDoctorId == null) {
      Get.snackbar(
        context.tr('error'),
        context.tr('clinic_visit.please_select_doctor_first'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    
    if (_doctorSchedules.isEmpty) {
      Get.snackbar(
        context.tr('error'),
        context.tr('clinic_visit.no_available_dates'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    
    // Get the available dates from the doctor schedules
    final availableDates = _doctorSchedules.map((schedule) => schedule.date).toList();
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: availableDates.first,
      firstDate: availableDates.first,
      lastDate: availableDates.last,
      selectableDayPredicate: (DateTime day) {
        // Only allow dates that are in the available dates list
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
    
    if (picked != null && (picked != _selectedDate)) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeValue = null;
        _selectedTimeText = null;
      });
      
      // Update available time slots for the selected date
      _updateAvailableTimeSlots();
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null) {
      Get.snackbar(
        context.tr('error'),
        context.tr('clinic_visit.please_select_date'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    
    if (_selectedTimeValue == null) {
      Get.snackbar(
        context.tr('error'),
        context.tr('clinic_visit.please_select_time'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    
    if (_selectedClinicId == null) {
      Get.snackbar(
        context.tr('error'),
        context.tr('clinic_visit.please_select_clinic'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    
    if (_selectedDoctorId == null) {
      Get.snackbar(
        context.tr('error'),
        context.tr('clinic_visit.please_select_doctor'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    
    if (_selectedServiceId == null) {
      Get.snackbar(
        context.tr('error'),
        context.tr('clinic_visit.please_select_service'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    
    if (_patientId == null) {
      Get.snackbar(
        context.tr('error'),
        'Patient information not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Format date as "YYYY-MM-DD"
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      
      // Create booking request
      final request = AppointmentBookingRequest(
        clinicId: _selectedClinicId!,
        doctorId: _selectedDoctorId!,
        serviceId: _selectedServiceId!,
        patientId: _patientId!,
        availableDate: formattedDate,
        availableTime: _selectedTimeValue!,
        symptoms: _reasonController.text,
      );
      
      // Submit booking
      final appointmentRepository = GetIt.instance<AppointmentRepository>();
      final response = await appointmentRepository.bookAppointment(request: request);
    
    setState(() {
      _isLoading = false;
    });
    
      // Check response status
      if (response['status'] == 'success') {
        // Create TimeOfDay from the selected time value
        final timeParts = _selectedTimeValue!.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final timeOfDay = TimeOfDay(hour: hour, minute: minute);
        
        // Navigate to success screen
        Get.off(() => ReservationSuccessScreen(
          visitType: 'clinic',
          clinicName: _selectedClinicName,
          doctorName: _selectedDoctorName,
          serviceName: _selectedServiceName,
          date: _selectedDate!,
          time: timeOfDay,
        ));
      } else {
        // Show error message
    Get.snackbar(
          context.tr('error'),
          response['msg'] ?? context.tr('clinic_visit.failed_to_book'),
      snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      Get.snackbar(
        context.tr('error'),
        '${context.tr('clinic_visit.failed_to_book')}: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
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
          context.tr('clinic_visit.book_clinic_visit'),
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
                      // Header with icon
                      _buildSectionHeader(
                        context.tr('clinic_visit.clinic_visit_request'),
                        context.tr('clinic_visit.doctor_visit_message'),
                        Icons.local_hospital_outlined,
                        isDarkMode,
                      ),
                      const SizedBox(height: 32),
                      
                      Text(
                        context.tr('clinic_visit.select_clinic'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildClinicDropdown(isDarkMode),
                      const SizedBox(height: 24),
                      
                      if (_selectedClinicId != null) ...[
                        _isLoadingClinicServices
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr('clinic_visit.select_doctor'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.white : AppColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDoctorDropdown(isDarkMode),
                                  const SizedBox(height: 24),
                                  
                                  Text(
                                    context.tr('clinic_visit.select_service'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.white : AppColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildServiceDropdown(isDarkMode),
                                  const SizedBox(height: 24),
                                ],
                              ),
                      ],
                      
                      if (_selectedDoctorId != null) ...[
                        _isLoadingDoctorSchedule
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                      Text(
                        context.tr('clinic_visit.date_time'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                                  _buildDatePicker(isDarkMode),
                                  const SizedBox(height: 16),
                                  
                                  if (_selectedDate != null) ...[
                                    Text(
                                      context.tr('clinic_visit.select_time'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isDarkMode ? Colors.white : AppColors.darkText,
                                      ),
                          ),
                                    const SizedBox(height: 8),
                                    _buildTimeSlotGrid(isDarkMode),
                      const SizedBox(height: 24),
                                  ],
                                ],
                              ),
                      ],
                      
                      Text(
                        context.tr('common.reason_for_visit'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InputField(
                        controller: _reasonController,
                        hint: context.tr('common.enter_reason'),
                        prefixIcon: Icons.description_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.tr('common.enter_reason');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      
                      PrimaryButton(
                        text: context.tr('common.book_appointment'),
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
                context.tr('clinic_visit.select_clinic'),
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
              
              // Load clinic services for this clinic
              if (newValue != null) {
                _loadClinicServices(newValue);
              }
            });
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
  
  Widget _buildDoctorDropdown(bool isDarkMode) {
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
          value: _selectedDoctorId,
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
                Icons.person_outlined,
                color: AppColors.mediumGrey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('clinic_visit.select_doctor'),
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          onChanged: (int? newValue) {
            setState(() {
              _selectedDoctorId = newValue;
              _selectedDoctorName = _doctors.firstWhere((doctor) => doctor.id == newValue).name;
              
              // Reset time-related selections when doctor changes
              _selectedDate = null;
              _selectedTimeValue = null;
              _selectedTimeText = null;
              _doctorSchedules = [];
              _selectedSchedule = null;
              _availableTimeSlots = [];
            });
            
            // Load doctor schedule
            _loadDoctorSchedule();
          },
          items: _doctors.map<DropdownMenuItem<int>>((Doctor doctor) {
            return DropdownMenuItem<int>(
              value: doctor.id,
              child: Row(
                children: [
                  Icon(
                    Icons.person_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      doctor.name,
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
  
  Widget _buildServiceDropdown(bool isDarkMode) {
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

  Widget _buildDatePicker(bool isDarkMode) {
    // If doctor is selected but has no schedule, show warning message
    if (_selectedDoctorId != null && _doctorSchedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
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
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.tr('clinic_visit.no_available_dates'),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

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
                  ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                  : context.tr('clinic_visit.select_date'),
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

  Widget _buildTimeSlotGrid(bool isDarkMode) {
    if (_availableTimeSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
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
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.tr('clinic_visit.no_available_slots'),
              style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _availableTimeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = _availableTimeSlots[index];
        final isSelected = _selectedTimeValue == timeSlot.value;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTimeValue = timeSlot.value;
              _selectedTimeText = timeSlot.text;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.mediumGrey.withOpacity(0.3),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              timeSlot.text,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white : AppColors.darkText),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
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
}
