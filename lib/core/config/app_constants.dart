class AppConstants {
  // API endpoints
  static const String baseUrl = 'https://appapi.smartsoftde.com/api';
  static const String authRegisterEndpoint = '/Auth/register';
  
  // Shared Preferences keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String darkModeKey = 'dark_mode';
  static const String languageKey = 'language';
  
  // Supported languages
  static const String englishCode = 'en';
  static const String arabicCode = 'ar';
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2xl = 48.0;
  static const double spacing3xl = 64.0;
} 