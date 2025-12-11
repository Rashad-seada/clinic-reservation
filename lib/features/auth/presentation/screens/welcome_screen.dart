import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/primary_button.dart';
import 'package:arwa_app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Logo (Optional, but good for branding)
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),

              // Title
              Text(
                context.tr('auth.welcome_screen_title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.darkText,
                  fontFamily: 'Almarai',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                context.tr('auth.welcome_screen_subtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  fontFamily: 'Almarai',
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              // Register Button
              PrimaryButton(
                text: context.tr('auth.register'),
                onPressed: () => Get.toNamed(Routes.REGISTER),
                height: 50,
                borderRadius: 12,
                useGradient: true,
              ),

              const SizedBox(height: 16),

              // Login Button (Outlined style for secondary action)
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Get.toNamed(Routes.LOGIN),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.tr('auth.login'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Almarai',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDarkMode ? Colors.white24 : Colors.grey[300],
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      context.tr('auth.welcome_or'),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.grey[500],
                        fontSize: 14,
                        fontFamily: 'Almarai',
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDarkMode ? Colors.white24 : Colors.grey[300],
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Reserve Now Button (Different style, maybe dark/filled or text)
              PrimaryButton(
                text: context.tr('auth.reserve_now'),
                onPressed: () {
                    // Navigate to Guest Reservation
                     Get.toNamed(Routes.GUEST_CLINIC_VISIT); 
                },
                height: 50,
                borderRadius: 12,
                // backgroundColor: isDarkMode ? Colors.white12 : Colors.grey[900], // Dark button for contrast
                // textColor: Colors.white,
                useGradient: false,
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
