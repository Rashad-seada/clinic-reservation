import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:arwa_app/core/theme/colors.dart';

class LanguageNotifier extends StateNotifier<Locale> {
  final SharedPreferences prefs;
  
  LanguageNotifier(this.prefs) : super(_loadLocale(prefs));
  
  static Locale _loadLocale(SharedPreferences prefs) {
    final languageCode = prefs.getString('language_code');
    if (languageCode == 'ar') {
      return const Locale('ar');
    } else {
      return const Locale('en');
    }
  }
  
  Future<void> setLanguage(BuildContext context, String languageCode) async {
    final locale = Locale(languageCode);
    await context.setLocale(locale);
    await prefs.setString('language_code', languageCode);
    state = locale;
    
    // Force rebuild the entire app with the new locale
    Get.updateLocale(locale);
    
    // Show a brief success message
    Get.snackbar(
      context.tr('settings.language_changed'),
      context.tr('settings.language_changed_success'),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: AppColors.primary.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
  
  bool get isRtl => state.languageCode == 'ar';
  
  String get languageCode => state.languageCode;
  
  String getLanguageName() {
    switch (state.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return 'English';
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  throw UnimplementedError('languageProvider has not been initialized');
});

final isRtlProvider = Provider<bool>((ref) {
  final languageNotifier = ref.watch(languageProvider.notifier);
  return languageNotifier.isRtl;
}); 