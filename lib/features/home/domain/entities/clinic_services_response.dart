import 'package:arwa_app/features/home/domain/entities/doctor.dart';
import 'package:arwa_app/features/home/domain/entities/service.dart';

class ClinicServicesResponse {
  final String status;
  final List<Service> services;
  final List<Doctor> doctors;
  final String availableStartDate;
  final String availableEndDate;

  ClinicServicesResponse({
    required this.status,
    required this.services,
    required this.doctors,
    required this.availableStartDate,
    required this.availableEndDate,
  });

  factory ClinicServicesResponse.fromJson(Map<String, dynamic> json) {
    return ClinicServicesResponse(
      status: json['status'],
      services: (json['services'] as List)
          .map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList(),
      doctors: (json['doctors'] as List)
          .map((e) => Doctor.fromJson(e as Map<String, dynamic>))
          .toList(),
      availableStartDate: json['availableStartDate'],
      availableEndDate: json['availableEndDate'],
    );
  }
} 