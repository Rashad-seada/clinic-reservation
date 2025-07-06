import 'package:arwa_app/core/providers/language_provider.dart';
import 'package:arwa_app/core/providers/theme_provider.dart';
import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:arwa_app/features/home/domain/repositories/patient_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_it/get_it.dart';

import '../../../../routes/app_pages.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeModeProvider);
    final languageNotifier = ref.watch(languageProvider.notifier);
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('settings.settings'),
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : AppColors.darkText,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Language Section
            _buildSectionTitle(context.tr('settings.language'), isDarkMode),
            const SizedBox(height: 16),
            _buildLanguageSelector(context, ref, languageNotifier, isDarkMode),
            
            const SizedBox(height: 32),
            
            // Theme Section
            _buildSectionTitle(context.tr('settings.theme'), isDarkMode),
            const SizedBox(height: 16),
            _buildThemeSelector(context, ref, currentThemeMode, isDarkMode),
            
            const SizedBox(height: 32),
            
            // App Info
            _buildSectionTitle(context.tr('settings.about'), isDarkMode),
            const SizedBox(height: 16),
            _buildInfoItem(
              context.tr('settings.version'), 
              '1.0.0', 
              Icons.info_outline,
              isDarkMode,
            ),
            
            const SizedBox(height: 48),
            
            // Logout Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: InkWell(
                onTap: () async {
                  // Show confirmation dialog
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(context.tr('auth.logout_confirmation')),
                      content: Text(context.tr('auth.logout_message')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            context.tr('common.cancel'),
                            style: TextStyle(color: AppColors.mediumGrey),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            context.tr('auth.logout'),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  
                  if (shouldLogout == true) {
                    try {
                      // Clear auth token
                      final authRepository = GetIt.instance<AuthRepository>();
                      await authRepository.logout();
                      

                      
                      // Navigate to login screen
                      Get.offAllNamed(Routes.LOGIN);
                    } catch (e) {
                      debugPrint('Error during logout: $e');
                      Get.snackbar(
                        context.tr('error'),
                        context.tr('auth.logout_failed'),
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.9),
                        colorText: Colors.white,
                      );
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('auth.logout'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : AppColors.darkText,
      ),
    );
  }
  
  Widget _buildLanguageSelector(BuildContext context, WidgetRef ref, 
      LanguageNotifier languageNotifier, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mediumGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildLanguageOption(
            context,
            ref,
            'en',
            context.tr('settings.english'),
            languageNotifier.languageCode == 'en',
            isDarkMode,
          ),
          Divider(
            height: 1,
            color: AppColors.mediumGrey.withOpacity(0.3),
          ),
          _buildLanguageOption(
            context,
            ref,
            'ar',
            context.tr('settings.arabic'),
            languageNotifier.languageCode == 'ar',
            isDarkMode,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLanguageOption(BuildContext context, WidgetRef ref, 
      String languageCode, String languageName, bool isSelected, bool isDarkMode) {
    return InkWell(
      onTap: () async {
        if (!isSelected) {
          await ref.read(languageProvider.notifier).setLanguage(context, languageCode);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              languageName,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : AppColors.darkText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildThemeSelector(BuildContext context, WidgetRef ref, 
      ThemeMode currentThemeMode, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mediumGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildThemeOption(
            context,
            ref,
            AppThemeMode.light,
            context.tr('settings.light'),
            Icons.light_mode,
            currentThemeMode == ThemeMode.light,
            isDarkMode,
          ),
          Divider(
            height: 1,
            color: AppColors.mediumGrey.withOpacity(0.3),
          ),
          _buildThemeOption(
            context,
            ref,
            AppThemeMode.dark,
            context.tr('settings.dark'),
            Icons.dark_mode,
            currentThemeMode == ThemeMode.dark,
            isDarkMode,
          ),
          Divider(
            height: 1,
            color: AppColors.mediumGrey.withOpacity(0.3),
          ),
          _buildThemeOption(
            context,
            ref,
            AppThemeMode.system,
            context.tr('settings.system'),
            Icons.settings_suggest,
            currentThemeMode == ThemeMode.system,
            isDarkMode,
          ),
        ],
      ),
    );
  }
  
  Widget _buildThemeOption(BuildContext context, WidgetRef ref, 
      AppThemeMode mode, String themeName, IconData icon, bool isSelected, bool isDarkMode) {
    return InkWell(
      onTap: () async {
        if (!isSelected) {
          await ref.read(themeProvider.notifier).setThemeMode(mode);
          Get.snackbar(
            context.tr('settings.theme_changed'),
            context.tr('settings.theme_changed_success'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primary.withOpacity(0.9),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : (isDarkMode ? Colors.white : AppColors.darkText),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              themeName,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : AppColors.darkText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(String title, String value, IconData icon, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mediumGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white : AppColors.darkText,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : AppColors.darkText.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
} 