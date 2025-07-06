import 'package:arwa_app/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _authRepository;
  
  LogoutUseCase(this._authRepository);
  
  Future<void> execute() {
    return _authRepository.logout();
  }
} 