import 'package:arwa_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  
  Future<User> register({
    required String username,
    required String fullName,
    required String mobile,
    required String birthDate,
    required String password,
    required String confirmPassword,
  });
  
  Future<void> logout();
  
  Future<void> forgotPassword(String email);
  
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  });
  
  Future<User> updateProfile({
    String? name,
    String? email,
    String? phone,
  });
  
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
  
  bool isAuthenticated();
  
  User? getCurrentUser();
} 