import 'dart:ui';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final bool useGlassMorphism;
  final double elevation;
  final VoidCallback? onTap;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.width,
    this.height,
    this.borderRadius = 24,
    this.backgroundColor,
    this.useGlassMorphism = false,
    this.elevation = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? 
               (useGlassMorphism 
                  ? Colors.transparent
                  : isDarkMode 
                      ? Theme.of(context).cardTheme.color 
                      : Colors.white),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: elevation > 0 ? [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.08),
            blurRadius: elevation * 4,
            offset: Offset(0, elevation),
          ),
        ] : null,
      ),
      child: child,
    );

    if (useGlassMorphism) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.05) 
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isDarkMode 
                    ? Colors.white.withOpacity(0.1) 
                    : Colors.white.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: onTap != null 
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: cardContent,
                    ),
                  )
                : cardContent,
          ),
        ),
      );
    }

    return onTap != null 
        ? Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: cardContent,
            ),
          )
        : cardContent;
  }
} 