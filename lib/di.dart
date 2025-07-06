import 'package:arwa_app/core/config/app_constants.dart';
import 'package:arwa_app/core/services/auth_service.dart';
import 'package:arwa_app/core/services/navigation_service.dart';
import 'package:arwa_app/core/services/patient_service.dart';
import 'package:arwa_app/core/services/storage_service.dart';
import 'package:arwa_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:arwa_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:arwa_app/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:arwa_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:arwa_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:arwa_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:arwa_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:arwa_app/features/auth/presentation/screens/login_screen.dart';
import 'package:arwa_app/features/home/data/repositories/appointment_repository_impl.dart';
import 'package:arwa_app/features/home/data/repositories/home_visit_repository_impl.dart';
import 'package:arwa_app/features/home/data/repositories/patient_repository_impl.dart';
import 'package:arwa_app/features/home/data/services/appointment_service.dart';
import 'package:arwa_app/features/home/data/services/home_visit_service.dart';
import 'package:arwa_app/features/home/domain/repositories/appointment_repository.dart';
import 'package:arwa_app/features/home/domain/repositories/home_visit_repository.dart';
import 'package:arwa_app/features/home/domain/repositories/patient_repository.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DI {
  static Future<void> init() async {
    final GetIt di = GetIt.instance;
    
    // External dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    
    // Register core services
    di.registerLazySingleton(() => StorageService(sharedPreferences));
    di.registerLazySingleton(() => NavigationService());
    
    // Register Dio with auth interceptor
    di.registerLazySingleton<Dio>(() {
      final storageService = di<StorageService>();

      final dio = Dio(BaseOptions(
        baseUrl: 'https://appapi.smartsoftde.com/api/',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Authorization' : storageService.getString('token'),
          // 'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      ));
      
      // Add auth interceptor
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          // Get the token from storage
          final storageService = di<StorageService>();
          final token = storageService.getString(AppConstants.tokenKey);
  
          // Add token to headers if available
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }


          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Handle 401 Unauthorized errors
          if (error.response?.statusCode == 401) {

            Get.to(() => const LoginScreen());
            storageService.remove(AppConstants.tokenKey);
          }
          return handler.next(error);
        },
      ));
      
      return dio;
    });
  
    // Register services
    di.registerLazySingleton(() => AuthService(di<Dio>(), di<StorageService>()));
    di.registerLazySingleton(() => PatientService(di<Dio>(), di<StorageService>()));
    di.registerLazySingleton(() => HomeVisitService(di<Dio>()));
    di.registerLazySingleton(() => AppointmentService(di<Dio>()));
    
    // Register repositories
    di.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(di<AuthService>()));
    di.registerLazySingleton<PatientRepository>(() => PatientRepositoryImpl(di<PatientService>()));
    di.registerLazySingleton<HomeVisitRepository>(() => HomeVisitRepositoryImpl(di<HomeVisitService>()));
    di.registerLazySingleton<AppointmentRepository>(() => AppointmentRepositoryImpl(
      di<AppointmentService>(),
      di<AuthService>()
    ));
    
    // Register auth use cases
    di.registerLazySingleton(() => LoginUseCase(di<AuthRepository>()));
    di.registerLazySingleton(() => RegisterUseCase(di<AuthRepository>()));
    di.registerLazySingleton(() => LogoutUseCase(di<AuthRepository>()));
    di.registerLazySingleton(() => ForgotPasswordUseCase(di<AuthRepository>()));
    di.registerLazySingleton(() => ResetPasswordUseCase(di<AuthRepository>()));
  }
} 