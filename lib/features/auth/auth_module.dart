import 'package:arwa_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:arwa_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:arwa_app/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:arwa_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:arwa_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:arwa_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:arwa_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:arwa_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

class AuthModule {
  static void init(GetIt locator) {
    // Repositories
    if (!locator.isRegistered<AuthRepository>()) {
      locator.registerSingleton<AuthRepository>(
        AuthRepositoryImpl(locator()),
      );
    }
    
    // UseCases
    if (!locator.isRegistered<LoginUseCase>()) {
      locator.registerSingleton<LoginUseCase>(
        LoginUseCase(locator()),
      );
    }
    
    if (!locator.isRegistered<RegisterUseCase>()) {
      locator.registerSingleton<RegisterUseCase>(
        RegisterUseCase(locator()),
      );
    }
    
    if (!locator.isRegistered<LogoutUseCase>()) {
      locator.registerSingleton<LogoutUseCase>(
        LogoutUseCase(locator()),
      );
    }
    
    if (!locator.isRegistered<ForgotPasswordUseCase>()) {
      locator.registerSingleton<ForgotPasswordUseCase>(
        ForgotPasswordUseCase(locator()),
      );
    }
    
    if (!locator.isRegistered<ResetPasswordUseCase>()) {
      locator.registerSingleton<ResetPasswordUseCase>(
        ResetPasswordUseCase(locator()),
      );
    }
  }
  
  static List<Override> get providers => [];
}