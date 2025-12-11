import 'package:arwa_app/core/base/base_view_model.dart';
import 'package:arwa_app/features/home/domain/entities/booking_data.dart';
import 'package:arwa_app/features/home/domain/entities/patient.dart';
import 'package:arwa_app/features/home/domain/entities/reservation_item.dart';
import 'package:arwa_app/features/home/domain/repositories/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// State class for Home ViewModel
class HomeViewState extends BaseViewModelState {
  final Patient? patient;
  final BookingAppointmentData? bookingData;
  final List<ReservationItem> allReservations;
  final String selectedFilter; // 'all', 'upcoming', 'past'
  final int allCount;
  final int upcomingCount;
  final int pastCount;

  const HomeViewState({
    super.isLoading = true,
    super.errorMessage,
    super.isSuccess = false,
    this.patient,
    this.bookingData,
    this.allReservations = const [],
    this.selectedFilter = 'all',
    this.allCount = 0,
    this.upcomingCount = 0,
    this.pastCount = 0,
  });

  @override
  HomeViewState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
    Patient? patient,
    BookingAppointmentData? bookingData,
    List<ReservationItem>? allReservations,
    String? selectedFilter,
    int? allCount,
    int? upcomingCount,
    int? pastCount,
  }) {
    return HomeViewState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      patient: patient ?? this.patient,
      bookingData: bookingData ?? this.bookingData,
      allReservations: allReservations ?? this.allReservations,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      allCount: allCount ?? this.allCount,
      upcomingCount: upcomingCount ?? this.upcomingCount,
      pastCount: pastCount ?? this.pastCount,
    );
  }

  List<ReservationItem> get filteredReservations {
    if (selectedFilter == 'upcoming') {
      return allReservations.where((r) => _isUpcoming(r)).toList();
    } else if (selectedFilter == 'past') {
      return allReservations.where((r) => _isPast(r)).toList();
    }
    return allReservations;
  }

  bool _isUpcoming(ReservationItem item) {
    // Logic to determine if upcoming (simplified, assumes future dates or pending status)
    // Status 0: Pending, 1: Confirmed, 2: Completed, 3: Cancelled (Example)
    // Adjust based on actual status codes
    return item.date.isAfter(DateTime.now().subtract(const Duration(days: 1))) && 
           item.status != 'cancelled' && item.status != 'completed';
  }

  bool _isPast(ReservationItem item) {
    return item.date.isBefore(DateTime.now().subtract(const Duration(days: 1))) || 
           item.status == 'cancelled' || item.status == 'completed';
  }

  bool get hasPatientData => patient != null;
  bool get hasReservations => allReservations.isNotEmpty;
}

/// ViewModel for Home Screen
/// Handles patient info fetching and reservations management
class HomeViewModel extends BaseViewModel<HomeViewState> {
  final PatientRepository _patientRepository;

  HomeViewModel({
    required PatientRepository patientRepository,
  })  : _patientRepository = patientRepository,
        super(const HomeViewState());

  /// Fetch patient info from repository
  Future<void> fetchPatientInfo() async {
    await executeAsync(
      action: () => _patientRepository.getPatientInfo(),
      onSuccess: (response) {
        final unifiedReservations = _unifyReservations(
          clinicReservations: response.reservations ?? [],
          homeServices: response.homeServices ?? [],
        );

        state = state.copyWith(
          patient: response.patient,
          bookingData: response.bookingAppointmentData,
          allReservations: unifiedReservations,
          allCount: unifiedReservations.length,
          upcomingCount: unifiedReservations.where((r) => _isUpcoming(r)).length,
          pastCount: unifiedReservations.where((r) => _isPast(r)).length,
          isSuccess: true,
        );
      },
      onError: (error) {
        debugPrint('Error fetching patient info: $error');
      },
    );
  }

  /// Refresh patient data
  Future<void> refresh() async {
    await fetchPatientInfo();
  }

  /// Set the selected filter
  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// Unify clinic and home reservations into a single list
  List<ReservationItem> _unifyReservations({
    required List<dynamic> clinicReservations,
    required List<dynamic> homeServices,
  }) {
    final List<ReservationItem> items = [];

    // Map Clinic Reservations
    for (var res in clinicReservations) {
      try {
        DateTime? date;
        String time = res['time'] ?? '00:00';
        
        // Handle date parsing safely
        if (res['date'] != null) {
          date = DateTime.tryParse(res['date']);
        }
        date ??= DateTime.now(); // Fallback

        items.add(ReservationItem(
          id: res['id'] ?? 0,
          type: 'clinic',
          title: res['doctorName'] ?? 'Doctor',
          subtitle: res['specialty'] ?? 'Specialty',
          date: date,
          time: time,
          status: _mapStatus(res['status']),
          location: res['clinicName'] ?? 'Clinic',
          phone: res['clinicPhone'],
          notes: res['notes'],
        ));
      } catch (e) {
        debugPrint('Error parsing clinic reservation: $e');
      }
    }

    // Map Home Services
    for (var service in homeServices) {
      try {
        DateTime? date;
        String time = service['visitTime'] ?? '00:00';
        
        if (service['visitDate'] != null) {
          date = DateTime.tryParse(service['visitDate']);
        }
        date ??= DateTime.now();

        items.add(ReservationItem(
          id: service['id'] ?? 0,
          type: 'home',
          title: service['service'] ?? 'Home Service',
          subtitle: service['symptoms'] ?? 'Home Visit',
          date: date,
          time: time,
          status: _mapStatus(service['status']),
          location: service['address'] ?? 'Home Address',
          phone: service['mobileNumber'],
          notes: service['symptoms'],
        ));
      } catch (e) {
        debugPrint('Error parsing home service: $e');
      }
    }

    // Sort by date (newest first)
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  String _mapStatus(dynamic status) {
    // Map API status to standardized strings
    // Adjust logic based on actual API values
    if (status == 'pending' || status == 0) return 'pending';
    if (status == 'confirmed' || status == 1) return 'confirmed';
    if (status == 'completed' || status == 2) return 'completed';
    if (status == 'cancelled' || status == 3) return 'cancelled';
    return 'pending'; // Default
  }

  bool _isUpcoming(ReservationItem item) {
    final now = DateTime.now().subtract(const Duration(days: 1));
    return item.date.isAfter(now) && 
           item.status != 'cancelled' && item.status != 'completed';
  }

  bool _isPast(ReservationItem item) {
    final now = DateTime.now().subtract(const Duration(days: 1));
    return item.date.isBefore(now) || 
           item.status == 'cancelled' || item.status == 'completed';
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
    state = const HomeViewState();
  }
}

/// Provider for HomeViewModel
final homeViewModelProvider =
    StateNotifierProvider.autoDispose<HomeViewModel, HomeViewState>((ref) {
  final viewModel = HomeViewModel(
    patientRepository: GetIt.instance<PatientRepository>(),
  );
  // Auto-fetch patient info on creation
  viewModel.fetchPatientInfo();
  return viewModel;
});
