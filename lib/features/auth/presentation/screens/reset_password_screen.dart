import 'dart:ui';
import 'package:arwa_app/core/config/app_constants.dart';
import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/input_field.dart';
import 'package:arwa_app/core/widgets/primary_button.dart';
import 'package:arwa_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../routes/app_pages.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;
  final String email;

  const ResetPasswordScreen({
    Key? key,
    required this.token,
    required this.email,
  }) : super(key: key);

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSuccess = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(authProvider.notifier).resetPassword(
            token: widget.token,
            email: widget.email,
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
          );
      
      if (ref.read(authProvider).error == null) {
        setState(() {
          _isSuccess = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final errorMessage = authState.error;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.8),
              border: Border.all(
                color: isDarkMode 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDarkMode ? Colors.white : Colors.black,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.tr('auth.reset_password'),
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background with blur effect
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        AppColors.darkBackground,
                        Color(0xFF1E3A5F),
                        AppColors.darkBackground,
                      ]
                    : [
                        Colors.white,
                        AppColors.primary.withOpacity(0.1),
                        Colors.white,
                      ],
              ),
            ),
          ),
          
          // Abstract shapes
          Positioned(
            top: -size.height * 0.15,
            right: -size.width * 0.3,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.2),
                    AppColors.primary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: _isSuccess
                      ? _buildSuccessMessage()
                      : _buildForm(errorMessage, authState.isLoading),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(String? errorMessage, bool isLoading) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 30.0, end: 0.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkMode 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode ? Colors.white10 : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock_open_rounded,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                  
                  Text(
                    context.tr('auth.reset_password_title'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    context.tr('auth.reset_password_message'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDarkMode ? AppColors.mediumGrey : AppColors.darkGrey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacing2xl),
                  
                  // Email display
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? Colors.white.withOpacity(0.05)
                          : AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.email,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : AppColors.darkText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                  
                  // Password field with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 50.0, end: 0.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(value, 0),
                        child: child,
                      );
                    },
                    child: InputField(
                      label: context.tr('auth.new_password'),
                      hint: context.tr('auth.enter_new_password'),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: _validatePassword,
                      prefixIcon: Icons.lock_outline,
                      borderRadius: 16,
                      fillColor: isDarkMode 
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white.withOpacity(0.5),
                      useFloatingLabel: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.mediumGrey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                  
                  // Confirm Password field with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 50.0, end: 0.0),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(value, 0),
                        child: child,
                      );
                    },
                    child: InputField(
                      label: context.tr('auth.confirm_password'),
                      hint: context.tr('auth.confirm_new_password'),
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      validator: _validateConfirmPassword,
                      prefixIcon: Icons.lock_outline,
                      borderRadius: 16,
                      fillColor: isDarkMode 
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white.withOpacity(0.5),
                      useFloatingLabel: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.mediumGrey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  if (errorMessage != null) ...[
                    const SizedBox(height: AppConstants.spacingM),
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
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
                    ),
                  ],
                  
                  const SizedBox(height: AppConstants.spacingL),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: PrimaryButton(
                      text: context.tr('auth.reset_password'),
                      onPressed: _resetPassword,
                      isLoading: isLoading,
                      height: 56,
                      borderRadius: 16,
                      useGradient: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 30.0, end: 0.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDarkMode 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Success icon with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingL),
                
                Text(
                  context.tr('auth.reset_success'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.darkText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingM),
                
                Text(
                  context.tr('auth.reset_success_message'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? AppColors.mediumGrey : AppColors.darkGrey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingL),
                
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: PrimaryButton(
                    text: context.tr('auth.go_to_login'),
                    onPressed: () {
                      Get.offAllNamed(Routes.LOGIN);
                    },
                    height: 56,
                    borderRadius: 16,
                    useGradient: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}