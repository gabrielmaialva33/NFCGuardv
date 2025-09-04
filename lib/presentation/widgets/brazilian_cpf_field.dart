import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';

/// Intelligent Brazilian CPF field with real-time validation and micro-interactions
/// Following Flutter 2025 UX best practices for exceptional user experience
class BrazilianCpfField extends ConsumerStatefulWidget {
  const BrazilianCpfField({
    super.key,
    required this.controller,
    this.onValidationChange,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final void Function(bool isValid)? onValidationChange;
  final bool enabled;
  final bool autofocus;

  @override
  ConsumerState<BrazilianCpfField> createState() => _BrazilianCpfFieldState();
}

class _BrazilianCpfFieldState extends ConsumerState<BrazilianCpfField>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _validateController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _borderColorAnimation;
  
  CpfValidationState _validationState = CpfValidationState.initial;
  String? _errorMessage;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    widget.controller.addListener(_onTextChanged);
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: AppConstants.fastAnimationDuration,
      vsync: this,
    );
    
    _validateController = AnimationController(
      duration: AppConstants.animationDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _borderColorAnimation = ColorTween(
      begin: null,
      end: null,
    ).animate(_validateController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _validateController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final cleanText = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Auto-format CPF as user types
    if (cleanText.length <= 11) {
      final formatted = _formatCpf(cleanText);
      if (formatted != text) {
        final cursorPos = _calculateCursorPosition(text, formatted);
        widget.controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: cursorPos),
        );
      }
    }

    // Debounced validation with emotional feedback
    if (!_isValidating) {
      _isValidating = true;
      Future.delayed(AppConstants.debounceDelay, () {
        if (mounted) {
          _validateCpf(cleanText);
        }
      });
    }
  }

  String _formatCpf(String cpf) {
    if (cpf.length <= 3) return cpf;
    if (cpf.length <= 6) return '${cpf.substring(0, 3)}.${cpf.substring(3)}';
    if (cpf.length <= 9) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6)}';
    }
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  int _calculateCursorPosition(String oldText, String newText) {
    final oldCursor = widget.controller.selection.baseOffset;
    final diff = newText.length - oldText.length;
    return (oldCursor + diff).clamp(0, newText.length);
  }

  void _validateCpf(String cpf) {
    setState(() {
      if (cpf.isEmpty) {
        _validationState = CpfValidationState.initial;
        _errorMessage = null;
      } else if (cpf.length < 11) {
        _validationState = CpfValidationState.typing;
        _errorMessage = null;
      } else if (!_isValidCpf(cpf)) {
        _validationState = CpfValidationState.invalid;
        _errorMessage = 'CPF inválido';
        _animateError();
      } else {
        _validationState = CpfValidationState.valid;
        _errorMessage = null;
        _animateSuccess();
      }
      _isValidating = false;
    });

    widget.onValidationChange?.call(_validationState == CpfValidationState.valid);
  }

  bool _isValidCpf(String cpf) {
    if (cpf.length != 11) return false;
    
    // Check for known invalid patterns
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;
    
    // Calculate check digits
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int digit1 = 11 - (sum % 11);
    if (digit1 >= 10) digit1 = 0;
    
    if (int.parse(cpf[9]) != digit1) return false;
    
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int digit2 = 11 - (sum % 11);
    if (digit2 >= 10) digit2 = 0;
    
    return int.parse(cpf[10]) == digit2;
  }

  void _animateSuccess() {
    _borderColorAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.outline,
      end: Colors.green,
    ).animate(_validateController);
    
    _validateController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _validateController.reverse();
      });
    });

    // Haptic feedback for success
    HapticFeedback.lightImpact();
  }

  void _animateError() {
    _borderColorAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.outline,
      end: Theme.of(context).colorScheme.error,
    ).animate(_validateController);
    
    _validateController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _validateController.reverse();
      });
    });

    // Haptic feedback for error
    HapticFeedback.mediumImpact();
    
    // Subtle pulse animation for error
    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  Color _getBorderColor() {
    if (_borderColorAnimation.value != null) {
      return _borderColorAnimation.value!;
    }
    
    switch (_validationState) {
      case CpfValidationState.valid:
        return Colors.green;
      case CpfValidationState.invalid:
        return Theme.of(context).colorScheme.error;
      case CpfValidationState.typing:
        return Theme.of(context).colorScheme.primary.withValues(alpha: 0.7);
      case CpfValidationState.initial:
        return Theme.of(context).colorScheme.outline;
    }
  }

  Widget _buildSuffixIcon() {
    switch (_validationState) {
      case CpfValidationState.valid:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case CpfValidationState.invalid:
        return Icon(Icons.error, color: Theme.of(context).colorScheme.error, size: 20);
      case CpfValidationState.typing:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      case CpfValidationState.initial:
        return const Icon(Icons.person_outline, size: 20);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: AnimatedBuilder(
            animation: _borderColorAnimation,
            builder: (context, child) {
              return TextFormField(
                controller: widget.controller,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: InputDecoration(
                  labelText: 'CPF',
                  hintText: '000.000.000-00',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  suffixIcon: _buildSuffixIcon(),
                  errorText: _errorMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    borderSide: BorderSide(color: _getBorderColor()),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    borderSide: BorderSide(color: _getBorderColor(), width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                  ),
                  contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
                  helperText: _getHelperText(),
                  helperStyle: TextStyle(
                    color: _getHelperColor(),
                    fontSize: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'CPF é obrigatório';
                  }
                  if (_validationState != CpfValidationState.valid) {
                    return 'CPF inválido';
                  }
                  return null;
                },
              );
            },
          ),
        );
      },
    );
  }

  String? _getHelperText() {
    switch (_validationState) {
      case CpfValidationState.valid:
        return 'CPF válido ✓';
      case CpfValidationState.typing:
        return 'Digitando...';
      case CpfValidationState.invalid:
        return 'Verifique os dígitos do CPF';
      case CpfValidationState.initial:
        return 'Digite seu CPF';
    }
  }

  Color _getHelperColor() {
    switch (_validationState) {
      case CpfValidationState.valid:
        return Colors.green;
      case CpfValidationState.invalid:
        return Theme.of(context).colorScheme.error;
      case CpfValidationState.typing:
        return Theme.of(context).colorScheme.primary;
      case CpfValidationState.initial:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }
}

enum CpfValidationState {
  initial,
  typing,
  valid,
  invalid,
}