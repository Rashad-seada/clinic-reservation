import 'dart:convert';
import 'package:arwa_app/core/config/app_constants.dart';
import 'package:arwa_app/core/services/storage_service.dart';
import 'package:arwa_app/features/home/domain/entities/booking_data.dart';
import 'package:arwa_app/features/home/domain/entities/patient.dart';
import 'package:arwa_app/features/home/domain/entities/patient_info_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PatientService {
  final Dio _dio;
  final StorageService _storageService;
  
  // Constants for storage keys
  static const String patientIdKey = 'patient_id';
  static const String patientDataKey = 'patient_data';
  static const String bookingDataKey = 'booking_data';
  
  PatientService(this._dio, this._storageService);
  
  /// Fetches patient information from the API and prints the response
  /// This is a temporary function to understand the API response structure
  Future<PatientInfoResponse> fetchAndPrintPatientInfo() async {
    try {
      final response = await _dio.get(
        'https://appapi.smartsoftde.com/api/PatientApi/patient-info',
        queryParameters: {'language': 'en'},
      );
      
      // Print the raw response
      debugPrint('Patient Info API Response:');
      debugPrint(jsonEncode(response.data));
      
      // Parse the response
      final patientInfoResponse = PatientInfoResponse.fromJson(response.data);
      
      // Store the patient ID and data
      await _storePatientInfo(patientInfoResponse);
      
      return patientInfoResponse;
    } on DioException catch (e) {
      debugPrint('Patient Info API Error: ${e.response?.statusCode}');
      debugPrint('Error Response: ${e.response?.data}');
      
      // Check if it's a connection error (offline mode)
      if (e.type == DioExceptionType.connectionError) {
        debugPrint('Connection error - returning mock response');
        return _createMockPatientInfoResponse();
      }
      
      rethrow;
    } catch (e) {
      debugPrint('Patient Info API Error: $e');
      rethrow;
    }
  }
  
  /// Fetches patient information and returns a PatientInfoResponse object
  Future<PatientInfoResponse> getPatientInfo() async {
    try {
      final response = await _dio.get(
        'https://appapi.smartsoftde.com/api/PatientApi/patient-info',
        queryParameters: {'language': 'en'},
      );


      
      final patientInfoResponse = PatientInfoResponse.fromJson(response.data);
      
      // Store the patient ID and data
      await _storePatientInfo(patientInfoResponse);
      
      return patientInfoResponse;
    } on DioException catch (e) {
      debugPrint('Patient Info API Error: ${e.response?.statusCode}');
      debugPrint('Error Response: ${e.response?.data}');
      
      // Check if it's a connection error (offline mode)
      if (e.type == DioExceptionType.connectionError) {
        debugPrint('Connection error - returning mock response');
        return _createMockPatientInfoResponse();
      }
      
      rethrow;
    } catch (e) {
      debugPrint('Patient Info API Error: $e');
      rethrow;
    }
  }
  
  /// Creates a mock patient info response for offline mode
  PatientInfoResponse _createMockPatientInfoResponse() {
    final patient = Patient(
      id: 9284,
      username: "Test User",
      birthDate: "2000-01-01T00:00:00",
      idNumber: "123456789",
      idType: "National ID",
      email: "test@example.com",
      phone: "01012345678",
      nationality: "Egyptian",
      religon: "",
      educationLevel: "",
    );
    
    final clinics = [
      Clinic(id: 1, name: "Main Clinic"),
      Clinic(id: 2, name: "Branch Clinic"),
      Clinic(id: 3, name: "Specialty Clinic"),
      Clinic(id: 4, name: "Emergency Clinic"),
    ];
    
    final cities = [
      City(id: 1, name: "Cairo"),
      City(id: 2, name: "Alexandria"),
      City(id: 5, name: "Giza"),
    ];
    
    final insuranceCompanies = [
      InsuranceCompany(id: 1, name: "Health Insurance"),
    ];
    
    final discountCards = [
      DiscountCard(id: 1, name: "Gold Card"),
    ];
    
    final workplaceCards = [
      WorkplaceCard(id: 1, name: "Corporate Card"),
    ];
    
    final bookingData = BookingAppointmentData(
      clinics: clinics,
      cities: cities,
      insuranceCompanies: insuranceCompanies,
      discountCards: discountCards,
      workplaceCards: workplaceCards,
    );
    
    final mockResponse = PatientInfoResponse(
      patient: patient,
      bookingAppointmentData: bookingData,
    );
    
    // Store the mock data
    _storePatientInfo(mockResponse);
    
    return mockResponse;
  }
  
  /// Stores patient information in local storage
  Future<void> _storePatientInfo(PatientInfoResponse patientInfoResponse) async {
    // Store the patient ID
    if (patientInfoResponse.patient.id != null) {
      await _storageService.setInt(patientIdKey, patientInfoResponse.patient.id!);
      debugPrint('Patient ID stored: ${patientInfoResponse.patient.id}');
    }
    
    // Store the patient data
    await _storageService.setObject(patientDataKey, patientInfoResponse.patient.toJson());
    
    // Store the booking data
    await _storageService.setObject(bookingDataKey, patientInfoResponse.bookingAppointmentData.toJson());
  }
  
  /// Retrieves the stored patient ID
  int? getPatientId() {
    return _storageService.getInt(patientIdKey);
  }
  
  /// Retrieves the stored patient data
  Patient? getStoredPatientData() {
    final data = _storageService.getObject(patientDataKey);
    if (data != null) {
      return Patient.fromJson(data);
    }
    return null;
  }
  
  /// Retrieves the stored booking data
  BookingAppointmentData? getStoredBookingData() {
    final data = _storageService.getObject(bookingDataKey);
    if (data != null) {
      return BookingAppointmentData.fromJson(data);
    }
    return null;
  }
} 