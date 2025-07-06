import 'dart:ui';
import 'package:arwa_app/core/config/app_constants.dart';
import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/input_field.dart';
import 'package:arwa_app/core/widgets/primary_button.dart';
import 'package:arwa_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../routes/app_pages.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _selectedBirthDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _fieldsAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  final List<Animation<Offset>> _fieldSlideAnimations = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fieldsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fieldsAnimationController,
      curve: Curves.easeOut,
    ));
    
    // Create staggered animations for form fields
    for (int i = 0; i < 6; i++) {
      _fieldSlideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0.5, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _fieldsAnimationController,
          curve: Interval(
            0.1 + (i * 0.1),
            0.6 + (i * 0.05),
            curve: Curves.easeOut,
          ),
        )),
      );
    }
    
    _animationController.forward();
    _buttonAnimationController.forward();
    _fieldsAnimationController.forward();
    
    // Add listeners to clear errors when user makes changes
    _usernameController.addListener(_clearErrors);
    _fullNameController.addListener(_clearErrors);
    _mobileController.addListener(_clearErrors);
    _passwordController.addListener(_clearErrors);
    _confirmPasswordController.addListener(_clearErrors);
    
    // Listen for successful registration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAuthListener();
    });

    // Listen to auth state changes
    ref.listenManual(authProvider, (previous, current) {
      // Only handle error states
      if (current.error != null && !current.isLoading) {
        // Ensure form keeps its values
        _formKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _usernameController.removeListener(_clearErrors);
    _fullNameController.removeListener(_clearErrors);
    _mobileController.removeListener(_clearErrors);
    _passwordController.removeListener(_clearErrors);
    _confirmPasswordController.removeListener(_clearErrors);
    
    _usernameController.dispose();
    _fullNameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    _buttonAnimationController.dispose();
    _fieldsAnimationController.dispose();
    super.dispose();
  }
  
  void _clearErrors() {
    final authState = ref.read(authProvider);
    if (authState.error != null) {
      ref.read(authProvider.notifier).clearError();
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  String? _validateBirthDate(DateTime? value) {
    if (value == null) {
      return 'Please select your birth date';
    }
    
    // Check if user is at least 16 years old
    final today = DateTime.now();
    final age = today.year - value.year - 
        (today.month < value.month || 
        (today.month == value.month && today.day < value.day) ? 1 : 0);
        
    if (age < 16) {
      return 'You must be at least 16 years old';
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    // Special character check is optional based on API requirements
    
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

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
      _clearErrors();
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your birth date')),
      );
      return;
    }

    final birthDateError = _validateBirthDate(_selectedBirthDate);
    if (birthDateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(birthDateError)),
      );
      return;
    }

    try {
      final birthDateFormatted = DateFormat('yyyy-MM-dd').format(_selectedBirthDate!);

      // Stay on this screen during registration process
      await ref.read(authProvider.notifier).register(
        username: _usernameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        mobile: _mobileController.text.trim(),
        birthDate: birthDateFormatted,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      // Check if we're still mounted and registration was successful
      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState.user != null) {
          // Use push replacement to prevent going back to register screen
          if (mounted) {  // Double-check mounted state before navigation
            Get.offAllNamed(Routes.HOME);
          }
        }
      }
    } catch (e) {
      // Error will be handled by the auth provider and displayed in the UI
      debugPrint('Registration error caught in screen: $e');
    }
  }

  void _setupAuthListener() {
    // We'll use a manual listener to avoid navigation during build
    ref.listenManual(authProvider, (previous, current) {
      // Only navigate when registration completes successfully
      if (previous?.isLoading == true && 
          !current.isLoading && 
          current.user != null) {
        // Use Future.microtask to avoid navigation during build
        Future.microtask(() {
          if (mounted) {
            Get.offAllNamed(Routes.HOME);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final errorMessage = authState.error;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: !authState.isLoading,
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: authState.isLoading 
              ? null
              : IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDarkMode 
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey[200],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDarkMode ? Colors.white : AppColors.darkText,
                      size: 20,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
        ),
        body: Stack(
          children: [
            // Background design elements
            Positioned(
              top: -150,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -120,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                ),
              ),
            ),
            
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Header with animation
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  context.tr('auth.create_account'),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : AppColors.darkText,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  context.tr('auth.join_message'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Registration Form
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Username Field with animation
                              SlideTransition(
                                position: _fieldSlideAnimations[0],
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
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
                                      label: context.tr('auth.username'),
                                      hint: context.tr('auth.username'),
                                      controller: _usernameController,
                                      validator: _validateUsername,
                                      prefixIcon: Icons.person_outline,
                                      textInputAction: TextInputAction.next,
                                      useFloatingLabel: false,
                                      borderRadius: 12,
                                      autofillHints: const [AutofillHints.username],
                                      fillColor: isDarkMode 
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Full Name Field
                              SlideTransition(
                                position: _fieldSlideAnimations[1],
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
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
                                      label: context.tr('auth.full_name'),
                                      hint: context.tr('auth.full_name'),
                                      controller: _fullNameController,
                                      validator: _validateFullName,
                                      prefixIcon: Icons.badge_outlined,
                                      textInputAction: TextInputAction.next,
                                      useFloatingLabel: false,
                                      borderRadius: 12,
                                      autofillHints: const [AutofillHints.name],
                                      fillColor: isDarkMode 
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Mobile Field
                              SlideTransition(
                                position: _fieldSlideAnimations[2],
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
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
                                      label: context.tr('auth.mobile_number'),
                                      hint: context.tr('auth.enter_mobile'),
                                      controller: _mobileController,
                                      keyboardType: TextInputType.phone,
                                      validator: _validateMobile,
                                      prefixIcon: Icons.phone_outlined,
                                      textInputAction: TextInputAction.next,
                                      useFloatingLabel: false,
                                      borderRadius: 12,
                                      autofillHints: const [AutofillHints.telephoneNumber],
                                      fillColor: isDarkMode 
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Birth Date Field
                              SlideTransition(
                                position: _fieldSlideAnimations[3],
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
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
                                    child: GestureDetector(
                                      onTap: _selectBirthDate,
                                      child: InputField(
                                        label: context.tr('auth.birth_date'),
                                        hint: _selectedBirthDate == null
                                            ? context.tr('auth.select_birth_date')
                                            : DateFormat('yyyy-MM-dd').format(_selectedBirthDate!),
                                        prefixIcon: Icons.calendar_today_outlined,
                                        readOnly: true,
                                        onTap: _selectBirthDate,
                                        useFloatingLabel: false,
                                        borderRadius: 12,
                                        autofillHints: const [AutofillHints.birthday],
                                        fillColor: isDarkMode 
                                            ? Colors.white.withOpacity(0.05)
                                            : Colors.white,
                                        validator: (_) => _selectedBirthDate == null ? 'Please select your birth date' : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Password Field
                              SlideTransition(
                                position: _fieldSlideAnimations[4],
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
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
                                      label: context.tr('auth.password'),
                                      hint: context.tr('auth.create_password'),
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      validator: _validatePassword,
                                      prefixIcon: Icons.lock_outline,
                                      useFloatingLabel: false,
                                      borderRadius: 12,
                                      autofillHints: const [AutofillHints.password],
                                      fillColor: isDarkMode 
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.white,
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
                                      helperText: context.tr('auth.password_requirements'),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Confirm Password Field
                              SlideTransition(
                                position: _fieldSlideAnimations[5],
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
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
                                      label: context.tr('auth.confirm_password'),
                                      hint: context.tr('auth.confirm_new_password'),
                                      controller: _confirmPasswordController,
                                      obscureText: _obscureConfirmPassword,
                                      validator: _validateConfirmPassword,
                                      prefixIcon: Icons.lock_outline,
                                      useFloatingLabel: false,
                                      borderRadius: 12,
                                      autofillHints: const [AutofillHints.password],
                                      fillColor: isDarkMode 
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.white,
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
                                ),
                              ),
                              
                              // Error Message
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
                                        margin: const EdgeInsets.only(bottom: 20),
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
                              
                              const SizedBox(height: 12),
                              
                              // Register Button with animation
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
                                    text: context.tr('auth.create_account'),
                                    onPressed: authState.isLoading 
                                        ? () {} 
                                        : () {
                                            if (!authState.isLoading) {
                                              _register();
                                            }
                                          },
                                    isLoading: authState.isLoading,
                                    height: 56,
                                    borderRadius: 12,
                                    useGradient: true,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Sign In Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.tr('auth.already_have_account'),
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.toNamed(Routes.LOGIN);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    child: Text(
                                      context.tr('auth.sign_in'),
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}