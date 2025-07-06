import 'dart:async';

import 'package:arwa_app/features/auth/domain/entities/user.dart';
import 'package:arwa_app/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:arwa_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:arwa_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:arwa_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:arwa_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

class AuthState {
  final User? user;
  final AuthStatus status;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.status = AuthStatus.initial,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    AuthStatus? status,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  // Add stream controller for state changes
  final _stateController = StreamController<AuthState>.broadcast();
  Stream<AuthState> get stream => _stateController.stream;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _forgotPasswordUseCase = forgotPasswordUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        super(AuthState()) {
    // Initial state notification
    _stateController.add(state);
  }

  @override
  void dispose() {
    _stateController.close();
    super.dispose();
  }

  // Override state setter to emit state changes
  @override
  set state(AuthState value) {
    super.state = value;
    if (!_stateController.isClosed) {
      _stateController.add(value);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final user = await _loginUseCase.execute(email, password);
      state = state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register({
    required String username,
    required String fullName,
    required String mobile,
    required String birthDate,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // First, clear any previous errors and set loading state
      state = state.copyWith(isLoading: true, error: null);
      
      debugPrint('Starting registration process...');
      
      final user = await _registerUseCase.execute(
        username: username,
        fullName: fullName,
        mobile: mobile,
        birthDate: birthDate,
        password: password,
        confirmPassword: confirmPassword,
      );
      
      debugPrint('Registration successful, user: ${user.username}');
      
      // Update state with the authenticated user
      state = state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
        isLoading: false,
        error: null, // Explicitly clear any errors
      );
    } catch (e) {
      debugPrint('Error in auth provider register: $e');
      
      // Extract the error message from the exception
      String errorMessage = e.toString();
      
      // Clean up the error message by removing "Exception: " prefix
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
      } else if (errorMessage.contains('BirthDate') && errorMessage.contains('DateTime')) {
        errorMessage = 'Please enter a valid birth date in YYYY-MM-DD format.';
      } else if (errorMessage.contains('model field is required')) {
        errorMessage = 'Registration failed: Missing required fields.';
      }
      
      // CRITICAL: Keep the status as initial during registration errors
      // This prevents unwanted navigation
      state = state.copyWith(
        status: AuthStatus.initial, // Changed from unauthenticated to initial
        isLoading: false,
        error: errorMessage,
        user: null,
      );
      
      // Re-throw the error to be handled by the UI
      throw errorMessage;
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _logoutUseCase.execute();
      state = state.copyWith(
        user: null,
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _forgotPasswordUseCase.execute(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _resetPasswordUseCase.execute(
        token: token,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setInitialState(User? user) {
    if (user != null) {
      state = state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
      );
    }
  }
  
  // Clear any error messages
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: GetIt.instance<LoginUseCase>(),
    registerUseCase: GetIt.instance<RegisterUseCase>(),
    logoutUseCase: GetIt.instance<LogoutUseCase>(),
    forgotPasswordUseCase: GetIt.instance<ForgotPasswordUseCase>(),
    resetPasswordUseCase: GetIt.instance<ResetPasswordUseCase>(),
  );
}); 