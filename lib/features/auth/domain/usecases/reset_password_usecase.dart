import 'package:arwa_app/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _authRepository;
  
  ResetPasswordUseCase(this._authRepository);
  
  Future<void> execute({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _authRepository.resetPassword(
      token: token,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
} 