import 'package:arwa_app/features/home/domain/entities/booking_data.dart';
import 'package:arwa_app/features/home/domain/entities/patient.dart';
import 'package:arwa_app/features/home/domain/entities/patient_info_response.dart';

abstract class PatientRepository {
  Future<PatientInfoResponse> getPatientInfo();
  int? getPatientId();
  Patient? getStoredPatientData();
  BookingAppointmentData? getStoredBookingData();
} 