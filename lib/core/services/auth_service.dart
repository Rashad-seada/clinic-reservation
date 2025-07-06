import 'dart:convert';
import 'package:arwa_app/core/config/app_constants.dart';
import 'package:arwa_app/core/services/storage_service.dart';
import 'package:arwa_app/features/auth/domain/entities/user.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;
  final StorageService _storageService;
  
  User? _currentUser;
  String? _token;
  
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  
  AuthService(this._dio, this._storageService) {
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    _token = _storageService.getString(AppConstants.tokenKey);
    final userData = _storageService.getObject(AppConstants.userKey);
    
    if (userData != null) {
      _currentUser = User.fromJson(userData);
    }
  }
  
  /// Get the authentication token
  Future<String?> getToken() async {
    // If token is already loaded, return it
    if (_token != null) {
      return _token;
    }
    
    // Otherwise try to load from storage
    _token = _storageService.getString(AppConstants.tokenKey);
    return _token;
  }
  
  Future<User> login(String username, String password) async {
    try {
      final response = await _dio.post(
        'https://appapi.smartsoftde.com/api/Auth/token',
        data: {
          'UserName': username,
          'Password': password,
        },
      );
      
      final data = response.data;
      
      // Check if the response is a string (error message)
      if (data is String) {
        throw Exception(data);
      }
      
      // Validate required fields
      if (data['token'] == null || data['username'] == null) {
        throw Exception('Invalid response format from server');
      }
      
      // Extract token and user data
      _token = data['token'];
      
      // Create user object from response
      _currentUser = User(
        id: data['username'], // Using username as ID since we don't have a specific ID
        username: data['username'],
        fullName: data['fullName'],
        roles: List<String>.from(data['roles']),
        token: data['token'],
      );
      
      // Save to storage
      await _storageService.setString(AppConstants.tokenKey, _token!);
      await _storageService.setObject(AppConstants.userKey, {
        'id': _currentUser!.id,
        'username': _currentUser!.username,
        'fullName': _currentUser!.fullName,
        'roles': _currentUser!.roles,
        'token': _currentUser!.token,
      });
      
      return _currentUser!;
    } on DioException catch (e) {
      debugPrint('Login error: ${e.response?.data}');
      
      // Handle specific status codes
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid username or password');
      }
      
      if (e.response?.statusCode == 400) {
        // Handle validation errors
        final responseData = e.response?.data;
        if (responseData is Map && responseData.containsKey('errors')) {
          final errors = responseData['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              throw Exception(firstError.first);
            }
          }
        }
        throw Exception('Invalid login data. Please check your credentials.');
      }
      
      // Handle string error response
      if (e.response?.data is String) {
        throw Exception(e.response?.data ?? 'Login failed');
      }
      
      // Handle network errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      
      throw Exception('Login failed: ${e.message ?? "Unknown error"}');
    } catch (e) {
      debugPrint('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }
  
  Future<User> register({
    required String username,
    required String fullName,
    required String mobile,
    required String birthDate,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConstants.baseUrl}${AppConstants.authRegisterEndpoint}',
        data: {
          'UserName': username,
          'FullName': fullName,
          'Mobile': mobile,
          'BirthDate': birthDate,
          'Password': password,
          'ConfirmPassword': confirmPassword,
        },
      );
      
      final data = response.data;
      
      if (data == null) {
        throw Exception('Registration failed: No data received');
      }
      
      _token = data['token'];
      _currentUser = User.fromJson(data);
      
      // Save to storage
      await _storageService.setString(AppConstants.tokenKey, _token!);
      await _storageService.setObject(AppConstants.userKey, data);
      
      return _currentUser!;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('Registration error: ${e.response?.data}');

        final responseData = e.response?.data;

        // Handle specific error responses
        if (responseData is Map) {
          // Check for success flag with message
          if (responseData.containsKey('success') && responseData['success'] == false) {
            if (responseData.containsKey('message')) {
              throw Exception(responseData['message']);
            }
          }

          // Check for errors object
          if (responseData.containsKey('errors')) {
            final errors = responseData['errors'];

            if (errors is Map) {
              // Password validation errors
              if (errors.containsKey('ConfirmPassword') && errors['ConfirmPassword'] is List) {
                final passwordErrors = errors['ConfirmPassword'] as List;
                if (passwordErrors.isNotEmpty) {
                  throw Exception(passwordErrors.first);
                }
              }

              // Model validation errors
              if (errors.containsKey('model') && errors['model'] is List) {
                final modelErrors = errors['model'] as List;
                if (modelErrors.isNotEmpty) {
                  throw Exception(modelErrors.first);
                }
              }

              // BirthDate format errors
              if (errors.containsKey('\$BirthDate') && errors['\$BirthDate'] is List) {
                final birthDateErrors = errors['\$BirthDate'] as List;
                if (birthDateErrors.isNotEmpty) {
                  throw Exception('Invalid birth date format. Please use YYYY-MM-DD format.');
                }
              }

              // If we have any error key, use the first one
              if (errors.isNotEmpty) {
                final firstErrorKey = errors.keys.first;
                if (errors[firstErrorKey] is List && (errors[firstErrorKey] as List).isNotEmpty) {
                  throw Exception(errors[firstErrorKey][0]);
                }
              }
            }
          }

          // Status code specific handling
          if (e.response?.statusCode == 400) {
            throw Exception('Invalid registration data. Please check your information and try again.');
          }
        }
      }

      // Default error message
      throw Exception('Registration failed: ${e.message ?? "Unknown error"}');
    } catch (e) {
      debugPrint('Registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      await _dio.post('${AppConstants.baseUrl}/auth/logout');
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _token = null;
      _currentUser = null;
      await _storageService.remove(AppConstants.tokenKey);
      await _storageService.remove(AppConstants.userKey);
    }
  }
  
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(
        '${AppConstants.baseUrl}/auth/forgot-password',
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _dio.post(
        '${AppConstants.baseUrl}/auth/reset-password',
        data: {
          'token': token,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
  
  Future<User> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final response = await _dio.put(
        '${AppConstants.baseUrl}/auth/profile',
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
        },
      );
      
      final data = response.data;
      _currentUser = User.fromJson(data['user']);
      
      // Update storage
      await _storageService.setObject(AppConstants.userKey, data['user']);
      
      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await _dio.put(
        '${AppConstants.baseUrl}/auth/password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPasswordConfirmation,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
} 