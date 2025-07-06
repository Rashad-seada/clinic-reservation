import 'package:arwa_app/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _authRepository;
  
  ForgotPasswordUseCase(this._authRepository);
  
  Future<void> execute(String email) {
    return _authRepository.forgotPassword(email);
  }
}