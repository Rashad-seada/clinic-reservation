import 'package:arwa_app/core/base/base_view_model.dart';
import 'package:arwa_app/features/auth/domain/entities/user.dart';
import 'package:arwa_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// State class for Login ViewModel
class LoginViewState extends BaseViewModelState {
  final String username;
  final String password;
  final bool obscurePassword;
  final User? user;
  final bool isAuthenticated;

  const LoginViewState({
    super.isLoading = false,
    super.errorMessage,
    super.isSuccess = false,
    this.username = '',
    this.password = '',
    this.obscurePassword = true,
    this.user,
    this.isAuthenticated = false,
  });

  @override
  LoginViewState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
    String? username,
    String? password,
    bool? obscurePassword,
    User? user,
    bool? isAuthenticated,
  }) {
    return LoginViewState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      username: username ?? this.username,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// ViewModel for Login Screen
/// Handles all login-related business logic
class LoginViewModel extends BaseViewModel<LoginViewState> {
  final LoginUseCase _loginUseCase;

  LoginViewModel({
    required LoginUseCase loginUseCase,
  })  : _loginUseCase = loginUseCase,
        super(const LoginViewState());

  // Text editing controllers - managed by ViewModel
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  /// Initialize controllers with listeners
  void init() {
    usernameController.addListener(_onUsernameChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  void _onUsernameChanged() {
    state = state.copyWith(username: usernameController.text, clearError: true);
  }

  void _onPasswordChanged() {
    state = state.copyWith(password: passwordController.text, clearError: true);
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  /// Validate form fields
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  /// Execute login
  Future<bool> login() async {
    final result = await executeAsync<User>(
      action: () => _loginUseCase.execute(
        usernameController.text,
        passwordController.text,
      ),
      onSuccess: (user) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isSuccess: true,
        );
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
    passwordController.clear();
    state = const LoginViewState();
  }

  @override
  void dispose() {
    usernameController.removeListener(_onUsernameChanged);
    passwordController.removeListener(_onPasswordChanged);
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

/// Provider for LoginViewModel
final loginViewModelProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, LoginViewState>((ref) {
  final viewModel = LoginViewModel(
    loginUseCase: GetIt.instance<LoginUseCase>(),
  );
  viewModel.init();
  return viewModel;
});
