import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base state class for all ViewModels
/// Contains common state properties like loading, error, and success states
class BaseViewModelState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const BaseViewModelState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  BaseViewModelState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return BaseViewModelState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
}

/// Base ViewModel class using Riverpod's StateNotifier
/// Provides common functionality for all ViewModels
abstract class BaseViewModel<T extends BaseViewModelState> extends StateNotifier<T> {
  BaseViewModel(super.initialState);

  /// Set loading state
  void setLoading(bool loading);

  /// Set error message
  void setError(String? message);

  /// Clear error message
  void clearError();

  /// Reset to initial state
  void reset();

  /// Execute an async operation with automatic loading/error handling
  Future<R?> executeAsync<R>({
    required Future<R> Function() action,
    void Function(R result)? onSuccess,
    void Function(dynamic error)? onError,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        setLoading(true);
      }
      clearError();
      
      final result = await action();
      
      if (showLoading) {
        setLoading(false);
      }
      
      onSuccess?.call(result);
      return result;
    } catch (e) {
      if (showLoading) {
        setLoading(false);
      }
      
      final errorMessage = _extractErrorMessage(e);
      setError(errorMessage);
      onError?.call(e);
      
      debugPrint('ViewModel Error: $e');
      return null;
    }
  }

  /// Extract readable error message from exception
  String _extractErrorMessage(dynamic error) {
    String message = error.toString();
    
    // Remove common prefixes
    if (message.startsWith('Exception: ')) {
      message = message.substring('Exception: '.length);
    }
    
    return message;
  }
}
