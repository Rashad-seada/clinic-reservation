import 'package:arwa_app/core/services/patient_service.dart';
import 'package:arwa_app/features/home/domain/entities/booking_data.dart';
import 'package:arwa_app/features/home/domain/entities/patient.dart';
import 'package:arwa_app/features/home/domain/entities/patient_info_response.dart';
import 'package:arwa_app/features/home/domain/repositories/patient_repository.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientService _patientService;
  
  PatientRepositoryImpl(this._patientService);
  
  @override
  Future<PatientInfoResponse> getPatientInfo() {
    return _patientService.getPatientInfo();
  }
  
  @override
  int? getPatientId() {
    return _patientService.getPatientId();
  }
  
  @override
  Patient? getStoredPatientData() {
    return _patientService.getStoredPatientData();
  }
  
  @override
  BookingAppointmentData? getStoredBookingData() {
    return _patientService.getStoredBookingData();
  }
} 