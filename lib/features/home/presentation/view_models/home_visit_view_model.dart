import 'package:arwa_app/core/base/base_view_model.dart';
import 'package:arwa_app/features/home/domain/entities/booking_data.dart';
import 'package:arwa_app/features/home/domain/entities/home_visit_request.dart';
import 'package:arwa_app/features/home/domain/entities/patient.dart';
import 'package:arwa_app/features/home/domain/entities/service.dart';
import 'package:arwa_app/features/home/domain/repositories/appointment_repository.dart';
import 'package:arwa_app/features/home/domain/repositories/home_visit_repository.dart';
import 'package:arwa_app/features/home/domain/repositories/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// State class for Home Visit ViewModel
class HomeVisitViewState extends BaseViewModelState {
  // Form data
  final int? selectedClinicId;
  final String? selectedClinicName;
  final int? selectedCityId;
  final int? selectedServiceId;
  final String? selectedServiceName;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? currentLocation;
  final double? price; // Added price field

  // Data lists
  final List<Clinic> clinics;
  final List<City> cities;
  final List<Service> services;
  final int? patientId;
  final Patient? patient;

  // Loading states
  final bool isLoadingData;
  final bool isLoadingServices;
  final bool isSubmitting;
  final bool isBookingSuccess;

  const HomeVisitViewState({
    super.isLoading = false,
    super.errorMessage,
    super.isSuccess = false,
    this.selectedClinicId,
    this.selectedClinicName,
    this.selectedCityId,
    this.selectedServiceId,
    this.selectedServiceName,
    this.selectedDate,
    this.selectedTime,
    this.currentLocation,
    this.price,
    this.clinics = const [],
    this.cities = const [],
    this.services = const [],
    this.patientId,
    this.patient,
    this.isLoadingData = true,
    this.isLoadingServices = false,
    this.isSubmitting = false,
    this.isBookingSuccess = false,
  });

  @override
  HomeVisitViewState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
    int? selectedClinicId,
    String? selectedClinicName,
    int? selectedCityId,
    int? selectedServiceId,
    String? selectedServiceName,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    String? currentLocation,
    double? price,
    List<Clinic>? clinics,
    List<City>? cities,
    List<Service>? services,
    int? patientId,
    Patient? patient,
    bool? isLoadingData,
    bool? isLoadingServices,
    bool? isSubmitting,
    bool? isBookingSuccess,
  }) {
    return HomeVisitViewState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      selectedClinicId: selectedClinicId ?? this.selectedClinicId,
      selectedClinicName: selectedClinicName ?? this.selectedClinicName,
      selectedCityId: selectedCityId ?? this.selectedCityId,
      selectedServiceId: selectedServiceId ?? this.selectedServiceId,
      selectedServiceName: selectedServiceName ?? this.selectedServiceName,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      currentLocation: currentLocation ?? this.currentLocation,
      price: price ?? this.price,
      clinics: clinics ?? this.clinics,
      cities: cities ?? this.cities,
      services: services ?? this.services,
      patientId: patientId ?? this.patientId,
      patient: patient ?? this.patient,
      isLoadingData: isLoadingData ?? this.isLoadingData,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isBookingSuccess: isBookingSuccess ?? this.isBookingSuccess,
    );
  }

  bool get hasClinicSelected => selectedClinicId != null;
  bool get hasCitySelected => selectedCityId != null;
  bool get hasServiceSelected => selectedServiceId != null;
  bool get hasDateSelected => selectedDate != null;
  bool get hasTimeSelected => selectedTime != null;
  bool get hasLocation => currentLocation != null;
}

/// ViewModel for Home Visit Screen
class HomeVisitViewModel extends BaseViewModel<HomeVisitViewState> {
  final PatientRepository _patientRepository;
  final HomeVisitRepository _homeVisitRepository;
  final AppointmentRepository _appointmentRepository;

  // Text controllers
  final addressController = TextEditingController();
  final mobileController = TextEditingController();
  final symptomsController = TextEditingController();

  HomeVisitViewModel({
    required PatientRepository patientRepository,
    required HomeVisitRepository homeVisitRepository,
    required AppointmentRepository appointmentRepository,
  })  : _patientRepository = patientRepository,
        _homeVisitRepository = homeVisitRepository,
        _appointmentRepository = appointmentRepository,
        super(const HomeVisitViewState());

  /// Load booking data (clinics, cities)
  Future<void> loadBookingData() async {
    try {
      final bookingData = _patientRepository.getStoredBookingData();
      final patientId = _patientRepository.getPatientId();

      if (bookingData != null && patientId != null) {
        state = state.copyWith(
          clinics: bookingData.clinics,
          cities: bookingData.cities,
          patientId: patientId,
          selectedClinicId: bookingData.clinics.isNotEmpty
              ? bookingData.clinics.first.id
              : null,
          selectedClinicName: bookingData.clinics.isNotEmpty
              ? bookingData.clinics.first.name
              : null,
          selectedCityId: bookingData.cities.isNotEmpty
              ? bookingData.cities.first.id
              : null,
          isLoadingData: false,
        );

        // Load services for default clinic
        if (state.selectedClinicId != null) {
          await loadClinicServices(state.selectedClinicId!);
        }
      } else {
        // Fetch from API
        final patientInfo = await _patientRepository.getPatientInfo();
        state = state.copyWith(
          clinics: patientInfo.bookingAppointmentData.clinics,
          cities: patientInfo.bookingAppointmentData.cities,
          patientId: patientInfo.patient.id,
          patient: patientInfo.patient,
          selectedClinicId: patientInfo.bookingAppointmentData.clinics.isNotEmpty
              ? patientInfo.bookingAppointmentData.clinics.first.id
              : null,
          selectedClinicName: patientInfo.bookingAppointmentData.clinics.isNotEmpty
              ? patientInfo.bookingAppointmentData.clinics.first.name
              : null,
          selectedCityId: patientInfo.bookingAppointmentData.cities.isNotEmpty
              ? patientInfo.bookingAppointmentData.cities.first.id
              : null,
          isLoadingData: false,
        );

        if (state.selectedClinicId != null) {
          await loadClinicServices(state.selectedClinicId!);
        }
      }
    } catch (e) {
      debugPrint('Error loading booking data: $e');
      state = state.copyWith(
        isLoadingData: false,
        errorMessage: 'Failed to load booking data',
      );
    }
  }

  /// Load services for selected clinic
  Future<void> loadClinicServices(int clinicId, {String language = 'en'}) async {
    state = state.copyWith(
      isLoadingServices: true,
      selectedServiceId: null,
      selectedServiceName: null,
      services: [],
    );

    try {
      final response = await _appointmentRepository.getClinicServices(
        clinicId,
        language: language,
      );
      state = state.copyWith(
        services: response.services,
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

  /// Select clinic
  void selectClinic(int clinicId, String clinicName, {String language = 'en'}) {
    state = state.copyWith(
      selectedClinicId: clinicId,
      selectedClinicName: clinicName,
    );
    loadClinicServices(clinicId, language: language);
  }

  /// Select city
  void selectCity(int cityId) {
    state = state.copyWith(selectedCityId: cityId);
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
    state = state.copyWith(selectedDate: date);
  }

  /// Select time
  void selectTime(TimeOfDay time) {
    state = state.copyWith(selectedTime: time);
  }

  /// Set location
  void setLocation(double lat, double lng, String address) {
    state = state.copyWith(currentLocation: "$lat,$lng");
    addressController.text = address;
  }

  /// Set symptoms from text field
  void setSymptoms(String value) {
    symptomsController.text = value;
  }

  /// Get current location
  Future<bool> getCurrentLocation() async {
    try {
      setLoading(true);
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _useFallbackLocation();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _useFallbackLocation();
        return false;
      }

      Position position = await Geolocator.getCurrentPosition();
      state = state.copyWith(
        currentLocation: "${position.latitude},${position.longitude}",
      );
      setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Error getting location: $e');
      _useFallbackLocation();
      return false;
    }
  }

  void _useFallbackLocation() {
    state = state.copyWith(currentLocation: "30.0444,31.2357");
    setLoading(false);
  }

  /// Validate form
  String? validateForm() {
    if (!state.hasDateSelected) return 'Please select a date';
    if (!state.hasTimeSelected) return 'Please select a time';
    if (!state.hasClinicSelected) return 'Please select a clinic';
    if (!state.hasCitySelected) return 'Please select a city';
    if (!state.hasServiceSelected) return 'Please select a service';
    if (state.patientId == null) return 'Patient not found';
    if (!state.hasLocation) return 'Location not available';
    if (mobileController.text.isEmpty) return 'Please enter mobile number';
    if (addressController.text.isEmpty) return 'Please enter address';
    if (symptomsController.text.isEmpty) return 'Please enter symptoms';
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
      final visitDate = DateFormat('yyyy-MM-dd').format(state.selectedDate!);
      final time = DateFormat('yyyy-MM-dd\'T\'HH:mm:ss').format(
        DateTime(
          state.selectedDate!.year,
          state.selectedDate!.month,
          state.selectedDate!.day,
          state.selectedTime!.hour,
          state.selectedTime!.minute,
        ),
      );

      final request = HomeVisitRequest(
        clinicId: state.selectedClinicId!,
        patientId: state.patientId!,
        cityId: state.selectedCityId!,
        mobile: mobileController.text,
        address: addressController.text,
        location: state.currentLocation!,
        visitDate: visitDate,
        time: time,
        serviceId: state.selectedServiceId!,
        service: state.selectedServiceName!,
        symptoms: symptomsController.text,
      );

      final response = await _homeVisitRepository.scheduleHomeVisit(request);

      state = state.copyWith(isSubmitting: false);

      if (response['status'] == 'success') {
        state = state.copyWith(isBookingSuccess: true);
        return true;
      } else {
        setError(response['msg'] ?? 'Failed to schedule home visit');
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting reservation: $e');
      state = state.copyWith(isSubmitting: false);
      setError('Failed to schedule home visit');
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
    addressController.clear();
    mobileController.clear();
    symptomsController.clear();
    state = const HomeVisitViewState();
  }

  @override
  void dispose() {
    addressController.dispose();
    mobileController.dispose();
    symptomsController.dispose();
    super.dispose();
  }
}

/// Provider for HomeVisitViewModel
final homeVisitViewModelProvider =
    StateNotifierProvider.autoDispose<HomeVisitViewModel, HomeVisitViewState>(
        (ref) {
  final viewModel = HomeVisitViewModel(
    patientRepository: GetIt.instance<PatientRepository>(),
    homeVisitRepository: GetIt.instance<HomeVisitRepository>(),
    appointmentRepository: GetIt.instance<AppointmentRepository>(),
  );
  viewModel.loadBookingData();
  return viewModel;
});
