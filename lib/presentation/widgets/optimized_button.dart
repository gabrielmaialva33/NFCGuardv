import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_helper.dart';

/// Optimized button widget following Flutter 2025 performance best practices
class OptimizedButton extends StatelessWidget {
  const OptimizedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final ButtonVariant variant;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final size = ResponsiveHelper.getOptimalButtonSize(context);
    final theme = Theme.of(context);

    return SizedBox(
      width: fullWidth ? double.infinity : size.width,
      height: size.height,
      child: _buildButton(theme),
    );
  }

  Widget _buildButton(ThemeData theme) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildButtonContent(),
        );
      case ButtonVariant.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildButtonContent(),
        );
      case ButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildButtonContent(),
        );
    }
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppConstants.smallPadding),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}

enum ButtonVariant {
  primary,
  secondary,
  text,
}