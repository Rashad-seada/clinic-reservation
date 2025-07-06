part of 'app_pages.dart';

abstract class Routes {
  static const ONBOARDING = '/onboarding';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const RESET_PASSWORD = '/reset-password';
  static const HOME = '/home';

  static List<String> get authRoutes => [
    ONBOARDING,
    LOGIN,
    REGISTER,
    FORGOT_PASSWORD,
    RESET_PASSWORD,
  ];
} 