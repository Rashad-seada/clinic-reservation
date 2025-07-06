import 'package:arwa_app/features/auth/domain/entities/user.dart';
import 'package:arwa_app/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _authRepository;
  
  RegisterUseCase(this._authRepository);
  
  Future<User> execute({
    required String username,
    required String fullName,
    required String mobile,
    required String birthDate,
    required String password,
    required String confirmPassword,
  }) {
    return _authRepository.register(
      username: username,
      fullName: fullName,
      mobile: mobile,
      birthDate: birthDate,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
} 