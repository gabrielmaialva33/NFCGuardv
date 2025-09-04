import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Helper class for creating responsive layouts following Flutter 2025 best practices
class ResponsiveHelper {
  /// Check if device is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }

  /// Check if device is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint &&
        width < AppConstants.desktopBreakpoint;
  }

  /// Check if device is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.desktopBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(AppConstants.defaultPadding);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(AppConstants.largePadding);
    } else {
      return const EdgeInsets.symmetric(
        horizontal: AppConstants.largePadding * 2,
        vertical: AppConstants.largePadding,
      );
    }
  }

  /// Get responsive width based on screen size
  static double getResponsiveWidth(BuildContext context, {
    double mobile = 1.0,
    double tablet = 0.8,
    double desktop = 0.6,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return screenWidth * mobile;
    } else if (isTablet(context)) {
      return screenWidth * tablet;
    } else {
      return screenWidth * desktop;
    }
  }

  /// Get responsive grid columns count
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < AppConstants.mobileBreakpoint) {
      return baseFontSize * 0.9;
    } else if (width < AppConstants.desktopBreakpoint) {
      return baseFontSize;
    } else {
      return baseFontSize * 1.1;
    }
  }

  /// Safe area wrapper that respects device notches and system UI
  static Widget safeAreaWrapper(Widget child) {
    return SafeArea(
      minimum: const EdgeInsets.all(AppConstants.smallPadding),
      child: child,
    );
  }

  /// Responsive layout builder for different screen sizes
  static Widget responsiveLayout({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AppConstants.mobileBreakpoint) {
          return mobile;
        } else if (constraints.maxWidth < AppConstants.desktopBreakpoint) {
          return tablet ?? mobile;
        } else {
          return desktop ?? tablet ?? mobile;
        }
      },
    );
  }

  /// Get optimal button size for touch targets
  static Size getOptimalButtonSize(BuildContext context) {
    return Size(
      getResponsiveWidth(context, mobile: 0.8, tablet: 300, desktop: 250),
      AppConstants.buttonHeight,
    );
  }

  /// Responsive card width for forms
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < AppConstants.mobileBreakpoint) {
      return screenWidth - (AppConstants.defaultPadding * 2);
    } else if (screenWidth < AppConstants.desktopBreakpoint) {
      return 400;
    } else {
      return 500;
    }
  }
}