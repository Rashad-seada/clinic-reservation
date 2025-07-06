import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:arwa_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../routes/app_pages.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();

    // Check auth state after animation starts
    _checkAuthState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    // Get the auth repository
    final authRepository = GetIt.instance<AuthRepository>();
    
    // Small delay to show splash screen
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (!mounted) return;

    // Check if user is authenticated
    if (authRepository.isAuthenticated()) {
      // Get current user
      final user = authRepository.getCurrentUser();
      
      // Set initial state in provider
      ref.read(authProvider.notifier).setInitialState(user);
      
      // Navigate to home
      Get.offAllNamed(Routes.HOME);
    } else {
      // Navigate to login
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey[100],
                ),
                child: Icon(
                  Icons.medical_services_outlined,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              Text(
                context.tr('auth.app_name'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('auth.app_slogan'),
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 