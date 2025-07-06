import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart' hide Trans;  // Hide Get's translation features
import 'package:arwa_app/core/theme/app_theme.dart';
import 'package:arwa_app/di.dart';
import 'package:arwa_app/routes/app_pages.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:arwa_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arwa_app/core/providers/theme_provider.dart';
import 'package:arwa_app/core/providers/language_provider.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await DI.init();
  
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Request location permissions early
  try {
    await _checkAndRequestLocationPermission();
  } catch (e) {
    debugPrint('Error initializing location: $e');
  }
  
  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true, // Use only language code (en, ar) without country code
      saveLocale: true, // Save the selected locale to shared preferences
      startLocale: const Locale('en'), // Set a default starting locale
      useFallbackTranslations: true, // Use fallback translations if key not found
      assetLoader: RootBundleAssetLoader(), // Explicitly set the asset loader
      child: ProviderScope(
        overrides: [
          // Override the theme provider
          themeProvider.overrideWith((ref) => ThemeNotifier(sharedPreferences)),
          // Override the language provider
          languageProvider.overrideWith((ref) => LanguageNotifier(sharedPreferences)),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

// Function to check and request location permissions
Future<void> _checkAndRequestLocationPermission() async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    debugPrint('Location permission status: $permission');
  } catch (e) {
    debugPrint('Error checking location permission: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch both theme mode and system brightness changes
    final themeMode = ref.watch(themeModeProvider);
    final isDark = ref.watch(isDarkModeProvider);
    
    return GetMaterialApp(
      title: 'Clenic Reservation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: Routes.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
      
      // Localization settings
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      fallbackLocale: const Locale('en'),
    );
  }
}
