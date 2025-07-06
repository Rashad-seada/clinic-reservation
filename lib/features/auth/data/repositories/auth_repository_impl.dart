import 'package:arwa_app/core/services/auth_service.dart';
import 'package:arwa_app/features/auth/domain/entities/user.dart';
import 'package:arwa_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  
  AuthRepositoryImpl(this._authService);
  
  @override
  Future<User> login(String email, String password) {
    return _authService.login(email, password);
  }
  
  @override
  Future<User> register({
    required String username,
    required String fullName,
    required String mobile,
    required String birthDate,
    required String password,
    required String confirmPassword,
  }) {
    return _authService.register(
      username: username,
      fullName: fullName,
      mobile: mobile,
      birthDate: birthDate,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
  
  @override
  Future<void> logout() {
    return _authService.logout();
  }
  
  @override
  Future<void> forgotPassword(String email) {
    return _authService.forgotPassword(email);
  }
  
  @override
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _authService.resetPassword(
      token: token,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
  
  @override
  Future<User> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) {
    return _authService.updateProfile(
      name: name,
      email: email,
      phone: phone,
    );
  }
  
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) {
    return _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }
  
  @override
  User? getCurrentUser() {
    return _authService.currentUser;
  }
  
  @override
  bool isAuthenticated() {
    return _authService.isAuthenticated;
  }
} 