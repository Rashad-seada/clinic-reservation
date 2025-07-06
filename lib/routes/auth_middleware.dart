import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arwa_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Get the ProviderContainer from the context
    final context = Get.context;
    if (context == null) return null;
    
    final container = ProviderScope.containerOf(context);
    final authState = container.read(authProvider);
    
    // If user is not authenticated and trying to access protected routes
    if (!isPublicRoute(route) && authState.user == null) {
      return const RouteSettings(name: Routes.ONBOARDING);
    }

    // If user is authenticated and trying to access auth routes
    if (isAuthRoute(route) && authState.user != null) {
      return const RouteSettings(name: Routes.HOME);
    }

    return null;
  }

  bool isPublicRoute(String? route) {
    return route == Routes.ONBOARDING ||
           route == Routes.LOGIN ||
           route == Routes.REGISTER ||
           route == Routes.FORGOT_PASSWORD;
  }

  bool isAuthRoute(String? route) {
    return route == Routes.LOGIN ||
           route == Routes.REGISTER ||
           route == Routes.FORGOT_PASSWORD;
  }
} 
 