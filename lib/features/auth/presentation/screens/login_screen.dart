import 'dart:ui';
import 'package:arwa_app/core/config/app_constants.dart';
import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/app_card.dart';
import 'package:arwa_app/core/widgets/divider_with_text.dart';
import 'package:arwa_app/core/widgets/input_field.dart';
import 'package:arwa_app/core/widgets/primary_button.dart';
import 'package:arwa_app/core/widgets/social_button.dart';
import 'package:arwa_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../routes/app_pages.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();

    // Add listeners to clear errors when user makes changes
    _usernameController.addListener(_clearErrors);
    _passwordController.addListener(_clearErrors);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_clearErrors);
    _passwordController.removeListener(_clearErrors);
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    final authState = ref.read(authProvider);
    if (authState.error != null) {
      ref.read(authProvider.notifier).clearError();
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.login(
        _usernameController.text,
            _passwordController.text,
          );
      
      // Only navigate if we have a user and authenticated status
      final authState = ref.read(authProvider);
      if (authState.user != null && authState.status == AuthStatus.authenticated) {
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      debugPrint('Login error caught in screen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authProvider);
    final errorMessage = authState.error;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
      body: Stack(
        children: [
          // Background design elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.1),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
          child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                height: size.height - MediaQuery.of(context).padding.top,
                child: Form(
                  key: _formKey,
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                      const SizedBox(height: 60),
                  
                      // Logo with animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 100,
                            height: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                              Icons.medical_services_outlined,
                              size: 50,
                            color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Welcome text with animation
                      AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: child,
                        ),
                          );
                        },
                        child: Column(
                          children: [
                  Text(
                              context.tr('auth.welcome_back'),
                    style: TextStyle(
                                fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                                letterSpacing: 0.5,
                    ),
                              textAlign: TextAlign.center,
                  ),
                            const SizedBox(height: 12),
                  Text(
                              context.tr('auth.please_sign_in'),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                  ),
                  
                      const SizedBox(height: 48),
                  
                      // Form fields with animation
                      AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: child,
                            ),
                          );
                        },
                    child: Column(
                      children: [
                            // Username field
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode 
                                        ? Colors.black.withOpacity(0.1) 
                                        : Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: InputField(
                                controller: _usernameController,
                                label: context.tr('auth.username'),
                                hint: context.tr('auth.username'),
                                prefixIcon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          useFloatingLabel: false,
                          borderRadius: 12,
                                fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                        ),
                        
                            const SizedBox(height: 20),
                        
                            // Password field
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode 
                                        ? Colors.black.withOpacity(0.1) 
                                        : Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: InputField(
                                controller: _passwordController,
                          label: context.tr('auth.password'),
                          hint: context.tr('auth.password'),
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline,
                          useFloatingLabel: false,
                          borderRadius: 12,
                                fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                          suffixIcon: IconButton(
                            icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.mediumGrey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                      // Error Message with animation
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              child: child,
                            ),
                          );
                        },
                        child: errorMessage != null
                            ? Container(
                                key: ValueKey<String>(errorMessage),
                                margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Forgot password with animation

                        const SizedBox(height: 28),
                        
                      // Sign in button with animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: PrimaryButton(
                            onPressed: authState.isLoading ? () {} : _handleLogin,
                          text: context.tr('auth.sign_in'),
                          isLoading: authState.isLoading,
                          height: 56,
                          borderRadius: 12,
                          useGradient: true,
                        ),
                        ),
                      ),
                        
                      const Spacer(),
                        
                      // Sign up link with animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.tr('auth.dont_have_account'),
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.toNamed(Routes.REGISTER),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: Text(
                                context.tr('auth.sign_up'),
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ],
                    ),
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 