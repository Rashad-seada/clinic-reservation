import 'package:arwa_app/core/base/base_view_model.dart';
import 'package:arwa_app/features/home/domain/entities/appointment_booking_request.dart';
import 'package:arwa_app/features/home/domain/entities/booking_data.dart';
import 'package:arwa_app/features/home/domain/entities/doctor.dart';
import 'package:arwa_app/features/home/domain/entities/doctor_schedule_response.dart';
import 'package:arwa_app/features/home/domain/entities/patient.dart';
import 'package:arwa_app/features/home/domain/entities/service.dart';
import 'package:arwa_app/features/home/domain/repositories/appointment_repository.dart';
import 'package:arwa_app/features/home/domain/repositories/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// State class for Clinic Visit ViewModel
class ClinicVisitViewState extends BaseViewModelState {
  // Selected values
  final int? selectedClinicId;
  final String? selectedClinicName;
  final int? selectedDoctorId;
  final String? selectedDoctorName;
  final int? selectedServiceId;
  final String? selectedServiceName;
  final DateTime? selectedDate;
  final String? selectedTimeValue;

  final String? selectedTimeText;
  final double? price; // Added price field
  
  // Data lists
  final List<Clinic> clinics;
  final List<Doctor> doctors;
  final List<Service> services;
  final List<DoctorSchedule> doctorSchedules;
  final DoctorSchedule? selectedSchedule;
  final List<TimeSlot> availableTimeSlots;
  final int? patientId;
  final Patient? patient;
  
  // Available date range
  final String? availableStartDate;
  final String? availableEndDate;
  
  // Loading states
  final bool isLoadingData;
  final bool isLoadingServices;
  final bool isLoadingSchedule;
  final bool isSubmitting;
  final bool isBookingSuccess;

  const ClinicVisitViewState({
    super.isLoading = false,
    super.errorMessage,
    super.isSuccess = false,
    this.selectedClinicId,
    this.selectedClinicName,
    this.selectedDoctorId,
    this.selectedDoctorName,
    this.selectedServiceId,
    this.selectedServiceName,
    this.selectedDate,
    this.selectedTimeValue,
    this.selectedTimeText,
    this.price,
    this.clinics = const [],
    this.doctors = const [],
    this.services = const [],
    this.doctorSchedules = const [],
    this.selectedSchedule,
    this.availableTimeSlots = const [],
    this.patientId,
    this.patient,
    this.availableStartDate,
    this.availableEndDate,
    this.isLoadingData = true,
    this.isLoadingServices = false,
    this.isLoadingSchedule = false,
    this.isSubmitting = false,
    this.isBookingSuccess = false,
  });

  @override
  ClinicVisitViewState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
    int? selectedClinicId,
    String? selectedClinicName,
    int? selectedDoctorId,
    String? selectedDoctorName,
    int? selectedServiceId,
    String? selectedServiceName,
    DateTime? selectedDate,
    String? selectedTimeValue,
    String? selectedTimeText,
    double? price,
    List<Clinic>? clinics,
    List<Doctor>? doctors,
    List<Service>? services,
    List<DoctorSchedule>? doctorSchedules,
    DoctorSchedule? selectedSchedule,
    List<TimeSlot>? availableTimeSlots,
    int? patientId,
    Patient? patient,
    String? availableStartDate,
    String? availableEndDate,
    bool? isLoadingData,
    bool? isLoadingServices,
    bool? isLoadingSchedule,
    bool? isSubmitting,
    bool? isBookingSuccess,
    bool clearSelections = false,
  }) {
    return ClinicVisitViewState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      selectedClinicId: clearSelections ? null : (selectedClinicId ?? this.selectedClinicId),
      selectedClinicName: clearSelections ? null : (selectedClinicName ?? this.selectedClinicName),
      selectedDoctorId: clearSelections ? null : (selectedDoctorId ?? this.selectedDoctorId),
      selectedDoctorName: clearSelections ? null : (selectedDoctorName ?? this.selectedDoctorName),
      selectedServiceId: clearSelections ? null : (selectedServiceId ?? this.selectedServiceId),
      selectedServiceName: clearSelections ? null : (selectedServiceName ?? this.selectedServiceName),
      selectedDate: clearSelections ? null : (selectedDate ?? this.selectedDate),
      selectedTimeValue: clearSelections ? null : (selectedTimeValue ?? this.selectedTimeValue),
      selectedTimeText: clearSelections ? null : (selectedTimeText ?? this.selectedTimeText),
      price: clearSelections ? null : (price ?? this.price),
      clinics: clinics ?? this.clinics,
      doctors: clearSelections ? [] : (doctors ?? this.doctors),
      services: clearSelections ? [] : (services ?? this.services),
      doctorSchedules: clearSelections ? [] : (doctorSchedules ?? this.doctorSchedules),
      selectedSchedule: clearSelections ? null : (selectedSchedule ?? this.selectedSchedule),
      availableTimeSlots: clearSelections ? [] : (availableTimeSlots ?? this.availableTimeSlots),
      patientId: patientId ?? this.patientId,
      patient: patient ?? this.patient,
      availableStartDate: clearSelections ? null : (availableStartDate ?? this.availableStartDate),
      availableEndDate: clearSelections ? null : (availableEndDate ?? this.availableEndDate),
      isLoadingData: isLoadingData ?? this.isLoadingData,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      isLoadingSchedule: isLoadingSchedule ?? this.isLoadingSchedule,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isBookingSuccess: isBookingSuccess ?? this.isBookingSuccess,
    );
  }

  bool get hasClinicSelected => selectedClinicId != null;
  bool get hasDoctorSelected => selectedDoctorId != null;
  bool get hasServiceSelected => selectedServiceId != null;
  bool get hasDateSelected => selectedDate != null;
  bool get hasTimeSelected => selectedTimeValue != null;
  bool get hasAvailableSchedules => doctorSchedules.isNotEmpty;
  
  TimeSlot? get selectedTimeSlot {
    if (selectedTimeValue == null) return null;
    return availableTimeSlots.where((slot) => slot.value == selectedTimeValue).firstOrNull;
  }
}

/// ViewModel for Clinic Visit Screen
class ClinicVisitViewModel extends BaseViewModel<ClinicVisitViewState> {
  final PatientRepository _patientRepository;
  final AppointmentRepository _appointmentRepository;
  
  // Text controllers
  final reasonController = TextEditingController();
  final phoneController = TextEditingController();

  ClinicVisitViewModel({
    required PatientRepository patientRepository,
    required AppointmentRepository appointmentRepository,
  })  : _patientRepository = patientRepository,
        _appointmentRepository = appointmentRepository,
        super(const ClinicVisitViewState());

  /// Load initial booking data
  Future<void> loadBookingData() async {
    try {
      final bookingData = _patientRepository.getStoredBookingData();
      int? patientId = _patientRepository.getPatientId();

      if (patientId == null) {
        final patientData = _patientRepository.getStoredPatientData();
        patientId = patientData?.id;
      }

      if (bookingData != null) {
        state = state.copyWith(
          clinics: bookingData.clinics,
          patientId: patientId,
          isLoadingData: false,
        );
      } else {
        final patientInfoResponse = await _patientRepository.getPatientInfo();
        state = state.copyWith(
          clinics: patientInfoResponse.bookingAppointmentData.clinics,
          patientId: patientInfoResponse.patient.id ?? patientId,
          patient: patientInfoResponse.patient,
          isLoadingData: false,
        );
      }
    } catch (e) {
      debugPrint('Error loading booking data: $e');
      state = state.copyWith(
        isLoadingData: false,
        errorMessage: 'Failed to load clinic data',
      );
    }
  }

  /// Load services for selected clinic
  Future<void> loadClinicServices(int clinicId, {String language = 'en'}) async {
    state = state.copyWith(
      isLoadingServices: true,
      selectedDoctorId: null,
      selectedDoctorName: null,
      selectedServiceId: null,
      selectedServiceName: null,
      doctors: [],
      services: [],
      doctorSchedules: [],
      selectedSchedule: null,
      availableTimeSlots: [],
      selectedDate: null,
      selectedTimeValue: null,
      selectedTimeText: null,
    );

    try {
      final clinicServicesResponse = await _appointmentRepository.getClinicServices(
        clinicId,
        language: language,
      );

      state = state.copyWith(
        doctors: clinicServicesResponse.doctors,
        services: clinicServicesResponse.services,
        availableStartDate: clinicServicesResponse.availableStartDate,
        availableEndDate: clinicServicesResponse.availableEndDate,
        isLoadingServices: false,
      );
    } catch (e) {
      debugPrint('Error loading clinic services: $e');
      state = state.copyWith(
        isLoadingServices: false,
        errorMessage: 'Failed to load services',
      );
    }
  }

  /// Load doctor schedule
  Future<void> loadDoctorSchedule({String language = 'en'}) async {
    if (state.selectedDoctorId == null || state.selectedClinicId == null) return;

    state = state.copyWith(
      isLoadingSchedule: true,
      doctorSchedules: [],
      selectedSchedule: null,
      availableTimeSlots: [],
      selectedDate: null,
      selectedTimeValue: null,
      selectedTimeText: null,
    );

    try {
      final doctorScheduleResponse = await _appointmentRepository.getDoctorSchedule(
        doctorId: state.selectedDoctorId!,
        clinicId: state.selectedClinicId!,
        language: language,
      );

      state = state.copyWith(
        doctorSchedules: doctorScheduleResponse.scheduleDoctor,
        isLoadingSchedule: false,
      );
    } catch (e) {
      debugPrint('Error loading doctor schedule: $e');
      state = state.copyWith(
        isLoadingSchedule: false,
        errorMessage: 'Failed to load schedule',
      );
    }
  }

  /// Select clinic
  void selectClinic(int clinicId, String clinicName, {String language = 'en'}) {
    state = state.copyWith(
      selectedClinicId: clinicId,
      selectedClinicName: clinicName,
    );
    loadClinicServices(clinicId, language: language);
  }

  /// Select doctor
  void selectDoctor(int doctorId, String doctorName, {String language = 'en'}) {
    state = state.copyWith(
      selectedDoctorId: doctorId,
      selectedDoctorName: doctorName,
      selectedDate: null,
      selectedTimeValue: null,
      selectedTimeText: null,
      doctorSchedules: [],
      selectedSchedule: null,
      availableTimeSlots: [],
    );
    loadDoctorSchedule(language: language);
  }

  /// Select service
  Future<void> selectService(int serviceId, String serviceName) async {
    state = state.copyWith(
      selectedServiceId: serviceId,
      selectedServiceName: serviceName,
    );
    
    // Fetch and store service price
    try {
      final priceData = await _appointmentRepository.getServicePrice(serviceId);
      final price = double.tryParse(priceData['price'].toString());
      state = state.copyWith(price: price);
      debugPrint('💰 Service Price Info: $price');
    } catch (e) {
      debugPrint('❌ Failed to get service price: $e');
      state = state.copyWith(price: null);
    }
  }

  /// Select date
  void selectDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      selectedTimeValue: null,
      selectedTimeText: null,
    );
    _updateAvailableTimeSlots();
  }

  /// Select time slot
  void selectTimeSlot(TimeSlot slot) {
    state = state.copyWith(
      selectedTimeValue: slot.value,
      selectedTimeText: slot.text,
    );
  }

  /// Select time
  void selectTime(String timeValue, String timeText) {
    state = state.copyWith(
      selectedTimeValue: timeValue,
      selectedTimeText: timeText,
    );
  }

  void _updateAvailableTimeSlots() {
    if (state.selectedDate == null || state.doctorSchedules.isEmpty) {
      state = state.copyWith(
        availableTimeSlots: [],
        selectedTimeValue: null,
        selectedTimeText: null,
      );
      return;
    }

    final selectedSchedule = state.doctorSchedules.firstWhere(
      (schedule) => DateUtils.isSameDay(schedule.date, state.selectedDate),
      orElse: () => DoctorSchedule(date: state.selectedDate!, timeSlots: []),
    );

    state = state.copyWith(
      selectedSchedule: selectedSchedule,
      availableTimeSlots: selectedSchedule.timeSlots.where((slot) => !slot.disabled).toList(),
      selectedTimeValue: null,
      selectedTimeText: null,
    );
  }

  /// Validate form
  String? validateForm() {
    if (!state.hasClinicSelected) return 'Please select a clinic';
    if (!state.hasDoctorSelected) return 'Please select a doctor';
    if (!state.hasServiceSelected) return 'Please select a service';
    if (!state.hasDateSelected) return 'Please select a date';
    if (!state.hasTimeSelected) return 'Please select a time';
    if (state.patientId == null) return 'Patient information not available';
    if (reasonController.text.isEmpty) return 'Please enter reason for visit';
    return null;
  }

  /// Submit reservation
  Future<bool> submitReservation() async {
    final validationError = validateForm();
    if (validationError != null) {
      setError(validationError);
      return false;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(state.selectedDate!);

      final request = AppointmentBookingRequest(
        clinicId: state.selectedClinicId!,
        doctorId: state.selectedDoctorId!,
        serviceId: state.selectedServiceId!,
        patientId: state.patientId!,
        availableDate: formattedDate,
        availableTime: state.selectedTimeValue!,
        symptoms: reasonController.text,
      );

      final response = await _appointmentRepository.bookAppointment(request: request);

      state = state.copyWith(isSubmitting: false);

      if (response['status'] == 'success') {
        state = state.copyWith(isBookingSuccess: true);
        return true;
      } else {
        setError(response['msg'] ?? 'Failed to book appointment');
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting reservation: $e');
      state = state.copyWith(isSubmitting: false);
      setError('Failed to book appointment');
      return false;
    }
  }

  @override
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  @override
  void setError(String? message) {
    state = state.copyWith(errorMessage: message);
  }

  @override
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void reset() {
    reasonController.clear();
    phoneController.clear();
    state = const ClinicVisitViewState();
  }

  @override
  void dispose() {
    reasonController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}

/// Provider for ClinicVisitViewModel
final clinicVisitViewModelProvider =
    StateNotifierProvider.autoDispose<ClinicVisitViewModel, ClinicVisitViewState>(
        (ref) {
  final viewModel = ClinicVisitViewModel(
    patientRepository: GetIt.instance<PatientRepository>(),
    appointmentRepository: GetIt.instance<AppointmentRepository>(),
  );
  viewModel.loadBookingData();
  return viewModel;
});
