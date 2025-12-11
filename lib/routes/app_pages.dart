import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arwa_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:arwa_app/features/auth/presentation/screens/login_screen.dart';
import 'package:arwa_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:arwa_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:arwa_app/features/auth/presentation/screens/register_screen.dart';
import 'package:arwa_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:arwa_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:arwa_app/features/home/presentation/screens/clinic_visit_screen.dart';
import 'package:arwa_app/features/home/presentation/screens/home_screen.dart';
import 'package:arwa_app/features/home/presentation/screens/home_visit_screen.dart';
import 'package:arwa_app/features/home/presentation/screens/settings_screen.dart';
import 'package:arwa_app/features/home/presentation/screens/guest_clinic_visit_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_middleware.dart';

abstract class Routes {
  static const INITIAL = '/';
  static const SPLASH = '/splash';
  static const HOME = '/home';
  static const ONBOARDING = '/onboarding';
  static const LOGIN = '/login';
  static const WELCOME = '/welcome';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const HOME_VISIT = '/home-visit';
  static const CLINIC_VISIT = '/clinic-visit';
  static const GUEST_CLINIC_VISIT = '/guest-clinic-visit';
  static const SETTINGS = '/settings';
}

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.INITIAL,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: Routes.WELCOME,
      page: () => const WelcomeScreen(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: Routes.HOME_VISIT,
      page: () => const HomeVisitScreen(),
    ),
    GetPage(
      name: Routes.CLINIC_VISIT,
      page: () => const ClinicVisitScreen(),
    ),
    GetPage(
      name: Routes.GUEST_CLINIC_VISIT,
      page: () => const GuestClinicVisitScreen(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsScreen(),
    ),
  ];
} 