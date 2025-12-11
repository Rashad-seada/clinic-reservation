import 'package:arwa_app/core/base/base_view_model.dart';
import 'package:arwa_app/features/auth/domain/entities/user.dart';
import 'package:arwa_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// State class for Register ViewModel
class RegisterViewState extends BaseViewModelState {
  final String username;
  final String fullName;
  final String mobile;
  final DateTime? birthDate;
  final String password;
  final String confirmPassword;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final User? user;
  final bool isRegistered;

  const RegisterViewState({
    super.isLoading = false,
    super.errorMessage,
    super.isSuccess = false,
    this.username = '',
    this.fullName = '',
    this.mobile = '',
    this.birthDate,
    this.password = '',
    this.confirmPassword = '',
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.user,
    this.isRegistered = false,
  });

  @override
  RegisterViewState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
    String? username,
    String? fullName,
    String? mobile,
    DateTime? birthDate,
    String? password,
    String? confirmPassword,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    User? user,
    bool? isRegistered,
  }) {
    return RegisterViewState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      mobile: mobile ?? this.mobile,
      birthDate: birthDate ?? this.birthDate,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      user: user ?? this.user,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}

/// ViewModel for Register Screen
class RegisterViewModel extends BaseViewModel<RegisterViewState> {
  final RegisterUseCase _registerUseCase;

  // Text controllers
  final usernameController = TextEditingController();
  final fullNameController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  RegisterViewModel({
    required RegisterUseCase registerUseCase,
  })  : _registerUseCase = registerUseCase,
        super(const RegisterViewState());

  /// Initialize controllers with listeners
  void init() {
    usernameController.addListener(_onFieldChanged);
    fullNameController.addListener(_onFieldChanged);
    mobileController.addListener(_onFieldChanged);
    passwordController.addListener(_onFieldChanged);
    confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    clearError();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword);
  }

  /// Set birth date
  void setBirthDate(DateTime date) {
    state = state.copyWith(birthDate: date);
    clearError();
  }

  // Validation methods
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    return null;
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  String? validateBirthDate() {
    if (state.birthDate == null) {
      return 'Please select your birth date';
    }

    final today = DateTime.now();
    final age = today.year -
        state.birthDate!.year -
        (today.month < state.birthDate!.month ||
                (today.month == state.birthDate!.month &&
                    today.day < state.birthDate!.day)
            ? 1
            : 0);

    if (age < 16) {
      return 'You must be at least 16 years old';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Register user
  Future<bool> register() async {
    // Validate birth date
    final birthDateError = validateBirthDate();
    if (birthDateError != null) {
      setError(birthDateError);
      return false;
    }

    final birthDateFormatted =
        DateFormat('yyyy-MM-dd').format(state.birthDate!);

    final result = await executeAsync<User>(
      action: () => _registerUseCase.execute(
        username: usernameController.text.trim(),
        fullName: fullNameController.text.trim(),
        mobile: mobileController.text.trim(),
        birthDate: birthDateFormatted,
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      ),
      onSuccess: (user) {
        state = state.copyWith(
          user: user,
          isRegistered: true,
          isSuccess: true,
        );
      },
      onError: (error) {
        // Extract and clean error message
        String errorMessage = error.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring('Exception: '.length);
        }

        // Handle specific error cases
        if (errorMessage.contains('Username is already registered')) {
          errorMessage = 'This username is already taken. Please choose another one.';
        } else if (errorMessage.contains('Passwords must have at least one digit')) {
          errorMessage = 'Password must contain at least one number (0-9).';
        } else if (errorMessage.contains('Passwords must have at least one uppercase')) {
          errorMessage = 'Password must contain at least one uppercase letter (A-Z).';
        } else if (errorMessage.contains('password and confirmation password do not match')) {
          errorMessage = 'Password and confirmation password must match.';
        }

        setError(errorMessage);
      },
    );

    return result != null;
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
    usernameController.clear();
    fullNameController.clear();
    mobileController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    state = const RegisterViewState();
  }

  @override
  void dispose() {
    usernameController.removeListener(_onFieldChanged);
    fullNameController.removeListener(_onFieldChanged);
    mobileController.removeListener(_onFieldChanged);
    passwordController.removeListener(_onFieldChanged);
    confirmPasswordController.removeListener(_onFieldChanged);
    usernameController.dispose();
    fullNameController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

/// Provider for RegisterViewModel
final registerViewModelProvider =
    StateNotifierProvider.autoDispose<RegisterViewModel, RegisterViewState>(
        (ref) {
  final viewModel = RegisterViewModel(
    registerUseCase: GetIt.instance<RegisterUseCase>(),
  );
  viewModel.init();
  return viewModel;
});
