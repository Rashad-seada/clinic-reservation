import 'dart:convert';
import 'package:arwa_app/features/home/domain/entities/appointment_booking_request.dart';
import 'package:arwa_app/features/home/domain/entities/clinic_services_response.dart';
import 'package:arwa_app/features/home/domain/entities/doctor.dart';
import 'package:arwa_app/features/home/domain/entities/doctor_schedule_response.dart';
import 'package:arwa_app/features/home/domain/entities/service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AppointmentService {
  final Dio _dio;
  
  AppointmentService(this._dio);
  
  /// Book a clinic appointment
  Future<Map<String, dynamic>> bookAppointment({
    required String token,
    required AppointmentBookingRequest request,
  }) async {
    try {
      final response = await _dio.post(
        'PatientApi/book-appointment',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      return response.data;
    } on DioException catch (e) {
      debugPrint('Book Appointment API Error: ${e.response?.statusCode}');
      debugPrint('Error Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Book Appointment API Error: $e');
      rethrow;
    }
  }
  
  /// Book a guest appointment (for unregistered users)
  Future<Map<String, dynamic>> bookGuestAppointment({
    required Map<String, dynamic> requestBody,
    String language = 'ar',
  }) async {
    try {
      final response = await _dio.post(
        'PatientApi/onlineBooking',
        data: requestBody,
        queryParameters: {
          'language': language,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      debugPrint('Guest Booking API Response: ${response.data}');
      
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      debugPrint('Guest Booking API Error: ${e.response?.statusCode}');
      debugPrint('Error Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Guest Booking API Error: $e');
      rethrow;
    }
  }
  
  /// Get clinic services and doctors using the new API endpoint
  Future<ClinicServicesResponse> getClinicServices(int clinicId, {String language = 'en'}) async {
    try {
      final response = await _dio.get(
        'PatientApi/services',
        queryParameters: {
          'clinicId': clinicId,
          'language': language,
        },
      );
      
      // Log the response for debugging
      debugPrint('Clinic Services API Response: ${response.data}');
      
      if (response.data is Map<String, dynamic> && response.data['status'] == 'success') {
        return ClinicServicesResponse.fromJson(response.data);
      } else {
        debugPrint('Invalid response format: ${response.data}');
        throw Exception('Failed to parse clinic services response');
      }
    } on DioException catch (e) {
      debugPrint('Get Clinic Services API Error: ${e.response?.statusCode}');
      debugPrint('Error Response: ${e.response?.data}');
      
      // If API fails, fallback to dummy data
      debugPrint('Falling back to dummy data for clinic services');
      return _getDummyClinicServices(clinicId);
    } catch (e) {
      debugPrint('Get Clinic Services API Error: $e');
      return _getDummyClinicServices(clinicId);
    }
  }

  /// Get service price
  Future<Map<String, dynamic>> getServicePrice(int serviceId) async {
    try {
      final response = await _dio.get(
        'PatientApi/Service-price',
        queryParameters: {
          'ServiceId': serviceId,
        },
      );
      
      debugPrint('Service Price API Response: ${response.data}');
      
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      debugPrint('Get Service Price API Error: $e');
      rethrow;
    }
  }
  
  /// Get doctor schedule with available time slots
  Future<DoctorScheduleResponse> getDoctorSchedule({
    String? token,
    required int doctorId,
    required int clinicId,
    String language = 'en',
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get(
        'PatientApi/get-DoctorSchedule',
        queryParameters: {
          'doctorId': doctorId,
          'ClinicId': clinicId,
          'language': language,
        },
        options: Options(
          headers: headers,
        ),
      );
      
      // Log the response for debugging
      debugPrint('Doctor Schedule API Response: ${response.data}');
      
      if (response.data is Map<String, dynamic> && response.data['status'] == 'success') {
        return DoctorScheduleResponse.fromJson(response.data);
      } else {
        debugPrint('Invalid response format: ${response.data}');
        throw Exception('Failed to parse doctor schedule response');
      }
    } on DioException catch (e) {
      debugPrint('Get Doctor Schedule API Error: ${e.response?.statusCode}');
      debugPrint('Error Response: ${e.response?.data}');
      
      // If API fails, fallback to dummy data
      debugPrint('Falling back to dummy data for doctor schedule');
      return _getDummyDoctorSchedule(doctorId, clinicId);
    } catch (e) {
      debugPrint('Get Doctor Schedule API Error: $e');
      // If parsing fails, fallback to dummy data
      return _getDummyDoctorSchedule(doctorId, clinicId);
    }
  }
  
  /// Get dummy doctor schedule data (fallback)
  DoctorScheduleResponse _getDummyDoctorSchedule(int doctorId, int clinicId) {
    // Create dummy schedule with time slots for the next 3 days
    final now = DateTime.now();
    final schedules = List.generate(3, (index) {
      final date = DateTime(now.year, now.month, now.day + index + 1);
      
      // Generate time slots from 9 AM to 5 PM with 30-minute intervals
      final timeSlots = <TimeSlot>[];
      for (int hour = 9; hour < 17; hour++) {
        // Full hour slot
        timeSlots.add(
          TimeSlot(
            disabled: false,
            selected: false,
            text: '${hour.toString().padLeft(2, '0')}:00 ${hour < 12 ? 'AM' : 'PM'}',
            value: '${hour.toString().padLeft(2, '0')}:00',
          ),
        );
        
        // Half hour slot
        timeSlots.add(
          TimeSlot(
            disabled: false,
            selected: false,
            text: '${hour.toString().padLeft(2, '0')}:30 ${hour < 12 ? 'AM' : 'PM'}',
            value: '${hour.toString().padLeft(2, '0')}:30',
          ),
        );
      }
      
      return DoctorSchedule(
        date: date,
        timeSlots: timeSlots,
      );
    });
    
    return DoctorScheduleResponse(
      status: 'success',
      scheduleDoctor: schedules,
    );
  }
  
  /// Get dummy clinic services data (fallback)
  ClinicServicesResponse _getDummyClinicServices(int clinicId) {
    // Create dummy doctors
    final doctors = [
      Doctor(id: 9283, name: "طارق محمد الخولي"),
      Doctor(id: 9319, name: "د / محمد عبد العزيز"),
      Doctor(id: 10330, name: "د/رامى ابراهيم"),
      Doctor(id: 10338, name: "د/ باسل وجدي ( قلب)"),
      Doctor(id: 10355, name: "بيشوي مجدي سدره"),
    ];
    
    // Create dummy services
    final services = [
      Service(id: 4, name: "كشف د/ طارق الخولي"),
      Service(id: 7, name: "رسم قلب بالمجهود د/طارق الخولي"),
      Service(id: 8, name: "مونتر لضربات القلب د/طارق الخولي"),
      Service(id: 188, name: "كشف ( د/ محمد عبد العزيز ) قلب"),
      Service(id: 189, name: "استشارة ( د/ محمد عبد العزيز )"),
      Service(id: 1312, name: "كشف (د/رامى ابراهيم) قلب"),
      Service(id: 1377, name: "كشف د/ باسل وجدي ( قلب)"),
      Service(id: 2695, name: "كشف د/بيشوي مجدي"),
    ];
    
    return ClinicServicesResponse(
      status: 'success',
      services: services,
      doctors: doctors,
      availableStartDate: '2025/07/09',
      availableEndDate: '2025/10/01',
    );
  }
  
  /// Get doctors by clinic ID (deprecated - use getClinicServices instead)
  @Deprecated('Use getClinicServices instead')
  Future<List<Doctor>> getDoctorsByClinic(int clinicId) async {
    try {
      final clinicServices = await getClinicServices(clinicId);
      return clinicServices.doctors;
    } catch (e) {
      debugPrint('Get Doctors API Error: $e');
      // If parsing fails, fallback to dummy data
      return _getDummyDoctors(clinicId);
    }
  }
  
  /// Get dummy doctors data (fallback)
  List<Doctor> _getDummyDoctors(int clinicId) {
    // Different doctors for different clinics to simulate real data
    switch (clinicId) {
      case 10:
        return [
          Doctor(id: 9283, name: "طارق محمد الخولي"),
          Doctor(id: 9319, name: "د / محمد عبد العزيز"),
          Doctor(id: 10330, name: "د/رامى ابراهيم"),
          Doctor(id: 10338, name: "د/ باسل وجدي ( قلب)"),
          Doctor(id: 10355, name: "بيشوي مجدي سدره"),
        ];
      case 1:
        return [
          Doctor(id: 9284, name: "Dr. Ahmed Mohamed"),
          Doctor(id: 9285, name: "Dr. Sara Ali"),
          Doctor(id: 9286, name: "Dr. Mahmoud Hassan"),
        ];
      case 2:
        return [
          Doctor(id: 9287, name: "Dr. Laila Kamal"),
          Doctor(id: 9288, name: "Dr. Omar Khaled"),
        ];
      case 3:
        return [
          Doctor(id: 9289, name: "Dr. Nour Ibrahim"),
          Doctor(id: 9290, name: "Dr. Hany Adel"),
          Doctor(id: 9291, name: "Dr. Mona Samir"),
        ];
      default:
        return [
          Doctor(id: 9292, name: "Dr. Tamer Hosny"),
          Doctor(id: 9293, name: "Dr. Amira Fahmy"),
        ];
    }
  }
  
  /// Get services by doctor ID (deprecated - use getClinicServices instead)
  @Deprecated('Use getClinicServices instead')
  Future<List<Map<String, dynamic>>> getServicesByDoctor(int doctorId) async {
    try {
      // In a real implementation, this would be an API call
      // For now, we'll return dummy data
      
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return dummy data - each doctor has different services
      return [
        {"id": 10, "name": "Regular Consultation", "price": 200},
        {"id": 11, "name": "Follow-up Visit", "price": 150},
        {"id": 12, "name": "Comprehensive Examination", "price": 350},
      ];
    } catch (e) {
      debugPrint('Get Services API Error: $e');
      rethrow;
    }
  }
} 