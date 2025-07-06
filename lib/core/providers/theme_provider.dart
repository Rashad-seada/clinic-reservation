import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  final SharedPreferences prefs;
  
  ThemeNotifier(this.prefs) : super(_loadThemeMode(prefs));
  
  static AppThemeMode _loadThemeMode(SharedPreferences prefs) {
    final themeString = prefs.getString('theme_mode');
    if (themeString == 'light') {
      return AppThemeMode.light;
    } else if (themeString == 'dark') {
      return AppThemeMode.dark;
    } else {
      return AppThemeMode.system;
    }
  }
  
  Future<void> setThemeMode(AppThemeMode mode) async {
    await prefs.setString('theme_mode', mode.name);
    state = mode; // This will trigger a rebuild of all listening widgets
  }
  
  bool get isDarkMode {
    if (state == AppThemeMode.system) {
      final window = WidgetsBinding.instance.platformDispatcher;
      final isDark = window.platformBrightness == Brightness.dark;
      return isDark;
    }
    return state == AppThemeMode.dark;
  }
  
  Brightness get currentBrightness => isDarkMode ? Brightness.dark : Brightness.light;
  
  ThemeMode get flutterThemeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      default:
        return ThemeMode.system;
    }
  }
}

// Create a provider for the theme notifier
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  throw UnimplementedError('themeProvider has not been initialized');
});

// Create a provider for the theme mode that rebuilds when system theme changes
final themeModeProvider = Provider<ThemeMode>((ref) {
  final themeMode = ref.watch(themeProvider);
  final themeNotifier = ref.watch(themeProvider.notifier);
  
  // Listen to platform brightness changes
  final window = WidgetsBinding.instance.platformDispatcher;
  final platformBrightness = window.platformBrightness;
  
  // This will rebuild when either the theme mode changes or the system theme changes
  return themeNotifier.flutterThemeMode;
});

// Create a provider for dark mode state that rebuilds when system theme changes
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  final themeNotifier = ref.watch(themeProvider.notifier);
  
  // Listen to platform brightness changes
  final window = WidgetsBinding.instance.platformDispatcher;
  final platformBrightness = window.platformBrightness;
  
  // This will rebuild when either the theme mode changes or the system theme changes
  return themeNotifier.isDarkMode;
}); 