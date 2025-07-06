import 'dart:ui';
import 'package:arwa_app/core/config/app_constants.dart';
import 'package:arwa_app/core/theme/colors.dart';
import 'package:arwa_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../routes/app_pages.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'auth.onboarding.welcome_title',
      description: 'auth.onboarding.welcome_desc',
      image: 'assets/images/placeholders/placeholder.txt',
      iconData: Icons.health_and_safety_rounded,
      primaryColor: Color(0xFF4ECDC4),
      secondaryColor: Color(0xFF1A535C),
    ),
    OnboardingPage(
      title: 'auth.onboarding.booking_title',
      description: 'auth.onboarding.booking_desc',
      image: 'assets/images/placeholders/placeholder.txt',
      iconData: Icons.calendar_month_rounded,
      primaryColor: Color(0xFF6C63FF),
      secondaryColor: Color(0xFF3F3D56),
    ),
    OnboardingPage(
      title: 'auth.onboarding.records_title',
      description: 'auth.onboarding.records_desc',
      image: 'assets/images/placeholders/placeholder.txt',
      iconData: Icons.folder_rounded,
      primaryColor: Color(0xFFFF6B6B),
      secondaryColor: Color(0xFF5E2CA5),
    ),
    OnboardingPage(
      title: 'auth.onboarding.reminders_title',
      description: 'auth.onboarding.reminders_desc',
      image: 'assets/images/placeholders/placeholder.txt',
      iconData: Icons.notifications_active_rounded,
      primaryColor: Color(0xFFFFD166),
      secondaryColor: Color(0xFF457B9D),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _animationController.forward();
    _buttonAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _animationController.reset();
      _pageController.nextPage(
        duration: AppConstants.mediumAnimationDuration,
        curve: Curves.easeInOut,
      );
      _animationController.forward();
    } else {
      Get.toNamed(Routes.LOGIN);
    }
  }

  void _skipOnboarding() {
    Get.toNamed(Routes.LOGIN);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final currentPage = _pages[_currentPage];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _skipOnboarding,
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.white70 : Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(
              'Skip',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDarkMode
                    ? [
                        AppColors.darkBackground,
                        currentPage.secondaryColor.withOpacity(0.5),
                        AppColors.darkBackground,
                      ]
                    : [
                        Colors.white,
                        currentPage.primaryColor.withOpacity(0.1),
                        Colors.white,
                      ],
              ),
            ),
          ),
          
          // Decorative elements
          Positioned(
            top: -size.height * 0.15,
            right: -size.width * 0.3,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    currentPage.primaryColor.withOpacity(0.2),
                    currentPage.secondaryColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    currentPage.secondaryColor.withOpacity(0.2),
                    currentPage.primaryColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                        _animationController.reset();
                        _animationController.forward();
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: Column(
                    children: [
                      // Page indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => _buildDotIndicator(index),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingL),
                      
                      // Animated button
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: PrimaryButton(
                          text: _currentPage == _pages.length - 1 
                            ? context.tr('auth.onboarding.get_started') 
                            : context.tr('auth.onboarding.next'),
                          onPressed: _nextPage,
                          icon: _currentPage == _pages.length - 1 ? Icons.login_rounded : Icons.arrow_forward_rounded,
                          height: 56,
                          borderRadius: 16,
                          useGradient: true,
                          backgroundColor: currentPage.primaryColor,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: _buildIllustration(page),
            ),
            const SizedBox(height: AppConstants.spacingXl),
            
            // Title with animated underline
            Text(
              context.tr(page.title),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDarkMode ? Colors.white : page.secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 100.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Center(
                  child: Container(
                    width: value,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          page.primaryColor,
                          page.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppConstants.spacingM),
            
            // Description with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 30.0, end: 0.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },
              child: Text(
                context.tr(page.description),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(OnboardingPage page) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              page.primaryColor.withOpacity(isDarkMode ? 0.3 : 0.2),
              page.secondaryColor.withOpacity(isDarkMode ? 0.1 : 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: page.primaryColor.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Icon(
          page.iconData,
          size: 120,
          color: page.primaryColor,
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    final isActive = _currentPage == index;
    final currentPage = _pages[_currentPage];
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive
            ? currentPage.primaryColor
            : AppColors.mediumGrey.withOpacity(0.3),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final IconData iconData;
  final Color primaryColor;
  final Color secondaryColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.iconData,
    required this.primaryColor,
    required this.secondaryColor,
  });
} 