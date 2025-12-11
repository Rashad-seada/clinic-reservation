import 'package:arwa_app/features/home/domain/entities/appointment_booking_request.dart';
import 'package:arwa_app/features/home/domain/entities/clinic_services_response.dart';
import 'package:arwa_app/features/home/domain/entities/doctor.dart';
import 'package:arwa_app/features/home/domain/entities/service.dart';
import 'package:arwa_app/features/home/domain/entities/doctor_schedule_response.dart';

abstract class AppointmentRepository {
  Future<Map<String, dynamic>> bookAppointment({
    required AppointmentBookingRequest request,
  });

  Future<Map<String, dynamic>> bookGuestAppointment({
    required Map<String, dynamic> requestBody,
    String language = 'ar',
  });
  
  Future<ClinicServicesResponse> getClinicServices(int clinicId, {String language = 'en'});
  
  Future<DoctorScheduleResponse> getDoctorSchedule({
    required int doctorId, 
    required int clinicId,
    String language = 'en'
  });

  Future<Map<String, dynamic>> getServicePrice(int serviceId);
  
  // Deprecated methods
  @Deprecated('Use getClinicServices instead')
  Future<List<Doctor>> getDoctorsByClinic(int clinicId);
  
  @Deprecated('Use getClinicServices instead')
  Future<List<Map<String, dynamic>>> getServicesByDoctor(int doctorId);
} 