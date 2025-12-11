import 'package:arwa_app/core/base/base_view_model.dart';
import 'package:arwa_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// State class for Forgot Password ViewModel
class ForgotPasswordViewState extends BaseViewModelState {
  final String email;
  final bool isSubmitted;
  final bool isEmailSent;

  const ForgotPasswordViewState({
    super.isLoading = false,
    super.errorMessage,
    super.isSuccess = false,
    this.email = '',
    this.isSubmitted = false,
    this.isEmailSent = false,
  });

  @override
  ForgotPasswordViewState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
    String? email,
    bool? isSubmitted,
    bool? isEmailSent,
  }) {
    return ForgotPasswordViewState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      email: email ?? this.email,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isEmailSent: isEmailSent ?? this.isEmailSent,
    );
  }
}

/// ViewModel for Forgot Password Screen
class ForgotPasswordViewModel extends BaseViewModel<ForgotPasswordViewState> {
  final AuthRepository _authRepository;
  final emailController = TextEditingController();

  ForgotPasswordViewModel({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const ForgotPasswordViewState());

  /// Validate email format
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Update email value
  void updateEmail(String email) {
    state = state.copyWith(email: email, clearError: true);
  }

  /// Submit password reset request
  Future<bool> resetPassword() async {
    final email = emailController.text.trim();
    
    // Validate email
    final validationError = validateEmail(email);
    if (validationError != null) {
      setError(validationError);
      return false;
    }

    setLoading(true);
    clearError();

    try {
      await _authRepository.forgotPassword(email);
      
      state = state.copyWith(
        isLoading: false,
        isSubmitted: true,
        isEmailSent: true,
        isSuccess: true,
      );
      return true;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send reset email. Please try again.',
      );
      return false;
    }
  }

  @override
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  @override
  void setError(String? message) {
    state = state.copyWith(errorMessage: message);
  }

  @override
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void reset() {
    emailController.clear();
    state = const ForgotPasswordViewState();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}

/// Provider for ForgotPasswordViewModel
final forgotPasswordViewModelProvider = StateNotifierProvider.autoDispose<
    ForgotPasswordViewModel, ForgotPasswordViewState>((ref) {
  return ForgotPasswordViewModel(
    authRepository: GetIt.instance<AuthRepository>(),
  );
});
