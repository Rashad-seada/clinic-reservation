import 'package:arwa_app/features/home/domain/entities/booking_data.dart';
import 'package:arwa_app/features/home/domain/entities/patient.dart';

class PatientInfoResponse {
  final Patient patient;
  final BookingAppointmentData bookingAppointmentData;
  final List<dynamic>? reservations;
  final List<dynamic>? homeServices;

  PatientInfoResponse({
    required this.patient,
    required this.bookingAppointmentData,
    this.reservations,
    this.homeServices,
  });

  factory PatientInfoResponse.fromJson(Map<String, dynamic> json) {
    return PatientInfoResponse(
      patient: Patient.fromJson(json['patient']),
      bookingAppointmentData: BookingAppointmentData.fromJson(json['bookingAppointmentData']),
      reservations: json['reservations'] as List<dynamic>?,
      homeServices: json['homeServices'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient': patient.toJson(),
      'bookingAppointmentData': bookingAppointmentData.toJson(),
    };
  }
} 