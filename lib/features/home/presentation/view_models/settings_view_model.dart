import 'package:arwa_app/core/base/base_view_model.dart';
import 'package:arwa_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// State class for Settings ViewModel
class SettingsViewState extends BaseViewModelState {
  final bool isLoggingOut;

  const SettingsViewState({
    super.isLoading = false,
    super.errorMessage,
    super.isSuccess = false,
    this.isLoggingOut = false,
  });

  @override
  SettingsViewState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
    bool? isLoggingOut,
  }) {
    return SettingsViewState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }
}

/// ViewModel for Settings Screen
/// Handles logout functionality
class SettingsViewModel extends BaseViewModel<SettingsViewState> {
  final AuthRepository _authRepository;

  SettingsViewModel({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const SettingsViewState());

  /// Perform logout
  Future<bool> logout() async {
    state = state.copyWith(isLoggingOut: true);
    
    try {
      await _authRepository.logout();
      state = state.copyWith(
        isLoggingOut: false,
        isSuccess: true,
      );
      return true;
    } catch (e) {
      debugPrint('Error during logout: $e');
      state = state.copyWith(
        isLoggingOut: false,
        errorMessage: 'Logout failed. Please try again.',
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
    state = const SettingsViewState();
  }
}

/// Provider for SettingsViewModel
final settingsViewModelProvider =
    StateNotifierProvider.autoDispose<SettingsViewModel, SettingsViewState>(
        (ref) {
  return SettingsViewModel(
    authRepository: GetIt.instance<AuthRepository>(),
  );
});
