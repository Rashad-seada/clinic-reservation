import 'package:arwa_app/core/services/auth_service.dart';
import 'package:arwa_app/features/home/data/services/appointment_service.dart';
import 'package:arwa_app/features/home/domain/entities/appointment_booking_request.dart';
import 'package:arwa_app/features/home/domain/entities/clinic_services_response.dart';
import 'package:arwa_app/features/home/domain/entities/doctor.dart';
import 'package:arwa_app/features/home/domain/entities/doctor_schedule_response.dart';
import 'package:arwa_app/features/home/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentService _appointmentService;
  final AuthService _authService;
  
  AppointmentRepositoryImpl(this._appointmentService, this._authService);
  
  @override
  Future<Map<String, dynamic>> bookAppointment({
    required AppointmentBookingRequest request,
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    return await _appointmentService.bookAppointment(
      token: token,
      request: request,
    );
  }
  
  @override
  Future<ClinicServicesResponse> getClinicServices(int clinicId, {String language = 'en'}) {
    return _appointmentService.getClinicServices(clinicId, language: language);
  }
  
  @override
  Future<DoctorScheduleResponse> getDoctorSchedule({
    required int doctorId, 
    required int clinicId,
    String language = 'en'
  }) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    
    return await _appointmentService.getDoctorSchedule(
      token: token,
      doctorId: doctorId,
      clinicId: clinicId,
      language: language,
    );
  }
  
  @override
  Future<List<Doctor>> getDoctorsByClinic(int clinicId) {
    return _appointmentService.getDoctorsByClinic(clinicId);
  }
  
  @override
  Future<List<Map<String, dynamic>>> getServicesByDoctor(int doctorId) {
    return _appointmentService.getServicesByDoctor(doctorId);
  }
} 