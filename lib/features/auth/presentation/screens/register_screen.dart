import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/input_field.dart';
import 'package:arwa_app/core/widgets/primary_button.dart';
import 'package:arwa_app/core/widgets/status_banners.dart';
import 'package:arwa_app/features/auth/presentation/view_models/register_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../routes/app_pages.dart';

/// Register Screen - Redesigned to match provided clean UI
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = ref.read(registerViewModelProvider.notifier);
    final success = await viewModel.register();

    if (success && mounted) {
      Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> _selectBirthDate() async {
    final viewModel = ref.read(registerViewModelProvider.notifier);
    final state = ref.read(registerViewModelProvider);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      viewModel.setBirthDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(registerViewModelProvider);
    final viewModel = ref.read(registerViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : AppColors.darkText,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildHeader(isDarkMode),
              const SizedBox(height: 40),
              _buildForm(isDarkMode, state, viewModel),
              const SizedBox(height: 20),
              _buildSignInLink(isDarkMode),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF00BFA5), // Teal
                AppColors.primary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.medical_services_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        
        // Title
        Text(
          context.tr('auth.create_account'),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontFamily: 'Almarai',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('auth.join_message'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
            fontFamily: 'Almarai',
          ),
        ),
      ],
    );
  }

  Widget _buildForm(
    bool isDarkMode,
    RegisterViewState state,
    RegisterViewModel viewModel,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 1. Full Name
          _buildField(
            isDarkMode: isDarkMode,
            child: InputField(
              label: context.tr('auth.full_name'),
              hint: context.tr('auth.full_name'),
              controller: viewModel.fullNameController,
              validator: viewModel.validateFullName,
              textInputAction: TextInputAction.next,
              useFloatingLabel: false,
              borderRadius: 8,
              fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
            ),
          ),

          // 2. Birth Date
          _buildField(
            isDarkMode: isDarkMode,
            child: GestureDetector(
              onTap: _selectBirthDate,
              child: InputField(
                label: context.tr('auth.birth_date'),
                hint: state.birthDate == null
                    ? context.tr('auth.select_birth_date')
                    : DateFormat('yyyy-MM-dd').format(state.birthDate!),
                readOnly: true,
                onTap: _selectBirthDate,
                useFloatingLabel: false,
                borderRadius: 8,
                fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                validator: (_) => state.birthDate == null
                    ? context.tr('auth.select_birth_date')
                    : null,
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: isDarkMode ? Colors.white54 : Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
          ),

          // 3. Mobile
          _buildField(
            isDarkMode: isDarkMode,
            child: InputField(
              label: context.tr('auth.mobile_number'),
              hint: context.tr('auth.enter_mobile'),
              controller: viewModel.mobileController,
              keyboardType: TextInputType.phone,
              validator: viewModel.validateMobile,
              textInputAction: TextInputAction.next,
              useFloatingLabel: false,
              borderRadius: 8,
              fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
            ),
          ),

          // 4. Username
          _buildField(
            isDarkMode: isDarkMode,
            child: InputField(
              label: context.tr('auth.username'),
              hint: context.tr('auth.username'),
              controller: viewModel.usernameController,
              validator: viewModel.validateUsername,
              textInputAction: TextInputAction.next,
              useFloatingLabel: false,
              borderRadius: 8,
              fillColor: isDarkMode ? Colors.white.withOpacity(0.1) : const Color(0xFFF5F5F5),
            ),
          ),

          // 5. Password
          _buildField(
            isDarkMode: isDarkMode,
            child: InputField(
              label: context.tr('auth.password'),
              hint: context.tr('auth.create_password'),
              controller: viewModel.passwordController,
              obscureText: state.obscurePassword,
              validator: viewModel.validatePassword,
              useFloatingLabel: false,
              borderRadius: 8,
              fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
            ),
          ),

          // 6. Confirm Password
          _buildField(
            isDarkMode: isDarkMode,
            child: InputField(
              label: context.tr('auth.confirm_password'),
              hint: context.tr('auth.confirm_new_password'),
              controller: viewModel.confirmPasswordController,
              obscureText: state.obscureConfirmPassword,
              validator: viewModel.validateConfirmPassword,
              useFloatingLabel: false,
              borderRadius: 8,
              fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
            ),
          ),

          // Error Banner
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ErrorBanner(
                message: state.errorMessage!,
                onDismiss: viewModel.clearError,
              ),
            ),

          const SizedBox(height: 20),

          // Save Button
          PrimaryButton(
            text: context.tr('common.save'), // Using 'Save' to match design 'حفظ'
            onPressed: state.isLoading ? () {} : _handleRegister,
            isLoading: state.isLoading,
            height: 50, // Slightly smaller height like typical web buttons
            borderRadius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required bool isDarkMode,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }

  Widget _buildSignInLink(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.tr('auth.already_have_account'),
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
            fontSize: 14,
            fontFamily: 'Almarai',
          ),
        ),
        TextButton(
          onPressed: () => Get.toNamed(Routes.LOGIN),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            context.tr('auth.sign_in'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Almarai',
            ),
          ),
        ),
      ],
    );
  }
}