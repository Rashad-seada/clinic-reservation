import 'dart:ui';
import 'package:arwa_app/core/config/app_constants.dart';
import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/input_field.dart';
import 'package:arwa_app/core/widgets/primary_button.dart';
import 'package:arwa_app/core/widgets/status_banners.dart';
import 'package:arwa_app/features/auth/presentation/view_models/forgot_password_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

/// Forgot Password Screen - Refactored to use MVVM pattern
/// Uses ForgotPasswordViewModel for state management
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref.read(forgotPasswordViewModelProvider.notifier).resetPassword();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(forgotPasswordViewModelProvider);
    final viewModel = ref.read(forgotPasswordViewModelProvider.notifier);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isDarkMode),
      body: Stack(
        children: [
          // Background gradient
          _buildBackground(isDarkMode, size),

          // Abstract decorative shapes
          _buildDecorativeShapes(size),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: viewState.isEmailSent && !viewState.isLoading
                      ? _buildSuccessMessage(isDarkMode)
                      : _buildForm(viewState, viewModel, isDarkMode),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
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
        context.tr('auth.forgot_password'),
        style: TextStyle(
          color: isDarkMode ? Colors.white : AppColors.darkText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBackground(bool isDarkMode, Size size) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  AppColors.darkBackground,
                  const Color(0xFF1E3A5F),
                  AppColors.darkBackground,
                ]
              : [
                  Colors.white,
                  AppColors.primary.withOpacity(0.1),
                  Colors.white,
                ],
        ),
      ),
    );
  }

  Widget _buildDecorativeShapes(Size size) {
    return Stack(
      children: [
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
      ],
    );
  }

  Widget _buildForm(
    ForgotPasswordViewState viewState,
    ForgotPasswordViewModel viewModel,
    bool isDarkMode,
  ) {
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
                  _buildAnimatedIcon(isDarkMode),
                  const SizedBox(height: AppConstants.spacingL),

                  // Title
                  Text(
                    context.tr('auth.forgot_password_title'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppColors.darkText,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingS),

                  // Description
                  Text(
                    context.tr('auth.forgot_password_message'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isDarkMode
                              ? AppColors.mediumGrey
                              : AppColors.darkGrey,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacing2xl),

                  // Email field
                  _buildEmailField(viewModel, isDarkMode),

                  // Error banner
                  if (viewState.errorMessage != null) ...[
                    const SizedBox(height: AppConstants.spacingM),
                    ErrorBanner(
                      message: viewState.errorMessage!,
                      onDismiss: () => viewModel.clearError(),
                    ),
                  ],

                  const SizedBox(height: AppConstants.spacingL),

                  // Submit button
                  _buildSubmitButton(viewState.isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(bool isDarkMode) {
    return TweenAnimationBuilder<double>(
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
          Icons.lock_reset_rounded,
          size: 40,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildEmailField(ForgotPasswordViewModel viewModel, bool isDarkMode) {
    return TweenAnimationBuilder<double>(
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
        label: context.tr('auth.email'),
        hint: context.tr('auth.email'),
        controller: viewModel.emailController,
        keyboardType: TextInputType.emailAddress,
        validator: viewModel.validateEmail,
        prefixIcon: Icons.email_outlined,
        borderRadius: 16,
        fillColor: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.5),
        useFloatingLabel: true,
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return TweenAnimationBuilder<double>(
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
        onPressed: _handleResetPassword,
        isLoading: isLoading,
        height: 56,
        borderRadius: 16,
        useGradient: true,
      ),
    );
  }

  Widget _buildSuccessMessage(bool isDarkMode) {
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
                  context.tr('auth.email_sent'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : AppColors.darkText,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingM),

                Text(
                  context.tr('auth.email_sent_message'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDarkMode
                            ? AppColors.mediumGrey
                            : AppColors.darkGrey,
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
                    text: context.tr('auth.back_to_login'),
                    onPressed: () => Navigator.pop(context),
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