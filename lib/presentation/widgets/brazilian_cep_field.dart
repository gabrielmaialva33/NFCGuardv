import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';

/// Intelligent Brazilian CEP field with auto-lookup and micro-interactions
/// Provides exceptional UX with automatic address completion
class BrazilianCepField extends ConsumerStatefulWidget {
  const BrazilianCepField({
    super.key,
    required this.controller,
    this.onAddressFound,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final void Function(Map<String, String> address)? onAddressFound;
  final bool enabled;
  final bool autofocus;

  @override
  ConsumerState<BrazilianCepField> createState() => _BrazilianCepFieldState();
}

class _BrazilianCepFieldState extends ConsumerState<BrazilianCepField>
    with TickerProviderStateMixin {
  late AnimationController _searchController;
  late AnimationController _successController;
  late Animation<double> _searchAnimation;
  late Animation<Color?> _borderColorAnimation;
  
  CepSearchState _searchState = CepSearchState.initial;
  String? _errorMessage;
  final Map<String, Map<String, String>> _cache = {};

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    widget.controller.addListener(_onTextChanged);
  }

  void _setupAnimations() {
    _searchController = AnimationController(
      duration: AppConstants.animationDuration,
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: AppConstants.fastAnimationDuration,
      vsync: this,
    );

    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.easeInOut,
    ));

    _borderColorAnimation = ColorTween(
      begin: null,
      end: null,
    ).animate(_successController);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _successController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final cleanText = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Auto-format CEP as user types
    if (cleanText.length <= 8) {
      final formatted = _formatCep(cleanText);
      if (formatted != text) {
        final cursorPos = _calculateCursorPosition(text, formatted);
        widget.controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: cursorPos),
        );
      }
    }

    // Auto-search when CEP is complete
    if (cleanText.length == 8) {
      _searchAddress(cleanText);
    } else if (_searchState != CepSearchState.initial) {
      setState(() {
        _searchState = CepSearchState.initial;
        _errorMessage = null;
      });
    }
  }

  String _formatCep(String cep) {
    if (cep.length <= 5) return cep;
    return '${cep.substring(0, 5)}-${cep.substring(5)}';
  }

  int _calculateCursorPosition(String oldText, String newText) {
    final oldCursor = widget.controller.selection.baseOffset;
    final diff = newText.length - oldText.length;
    return (oldCursor + diff).clamp(0, newText.length);
  }

  Future<void> _searchAddress(String cep) async {
    // Check cache first
    if (_cache.containsKey(cep)) {
      _handleAddressFound(_cache[cep]!);
      return;
    }

    setState(() {
      _searchState = CepSearchState.searching;
      _errorMessage = null;
    });

    _searchController.forward();

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final addressInfo = await authNotifier.searchZipCode(cep);

      if (mounted) {
        if (addressInfo != null && addressInfo.isNotEmpty) {
          // Cache the result
          _cache[cep] = addressInfo;
          _handleAddressFound(addressInfo);
        } else {
          _handleAddressNotFound();
        }
      }
    } catch (e) {
      if (mounted) {
        _handleSearchError();
      }
    } finally {
      if (mounted) {
        _searchController.reverse();
      }
    }
  }

  void _handleAddressFound(Map<String, String> address) {
    setState(() {
      _searchState = CepSearchState.found;
      _errorMessage = null;
    });

    _animateSuccess();
    widget.onAddressFound?.call(address);
    HapticFeedback.lightImpact();
  }

  void _handleAddressNotFound() {
    setState(() {
      _searchState = CepSearchState.notFound;
      _errorMessage = 'CEP não encontrado';
    });
    _animateError();
  }

  void _handleSearchError() {
    setState(() {
      _searchState = CepSearchState.error;
      _errorMessage = 'Erro ao buscar CEP';
    });
    _animateError();
  }

  void _animateSuccess() {
    _borderColorAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.outline,
      end: Colors.green,
    ).animate(_successController);
    
    _successController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _successController.reverse();
      });
    });
  }

  void _animateError() {
    _borderColorAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.outline,
      end: Theme.of(context).colorScheme.error,
    ).animate(_successController);
    
    _successController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) _successController.reverse();
      });
    });

    HapticFeedback.mediumImpact();
  }

  Color _getBorderColor() {
    if (_borderColorAnimation.value != null) {
      return _borderColorAnimation.value!;
    }
    
    switch (_searchState) {
      case CepSearchState.found:
        return Colors.green;
      case CepSearchState.notFound:
      case CepSearchState.error:
        return Theme.of(context).colorScheme.error;
      case CepSearchState.searching:
        return Theme.of(context).colorScheme.primary;
      case CepSearchState.initial:
        return Theme.of(context).colorScheme.outline;
    }
  }

  Widget _buildSuffixIcon() {
    switch (_searchState) {
      case CepSearchState.searching:
        return SizedBox(
          width: 20,
          height: 20,
          child: AnimatedBuilder(
            animation: _searchAnimation,
            builder: (context, child) {
              return CircularProgressIndicator(
                value: null,
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              );
            },
          ),
        );
      case CepSearchState.found:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case CepSearchState.notFound:
      case CepSearchState.error:
        return Icon(Icons.error, color: Theme.of(context).colorScheme.error, size: 20);
      case CepSearchState.initial:
        return const Icon(Icons.location_on_outlined, size: 20);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
            LengthLimitingTextInputFormatter(8),
          ],
          decoration: InputDecoration(
            labelText: 'CEP',
            hintText: '00000-000',
            prefixIcon: const Icon(Icons.location_city_outlined),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              child: _buildSuffixIcon(),
            ),
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
              return 'CEP é obrigatório';
            }
            final clean = value.replaceAll(RegExp(r'[^\d]'), '');
            if (clean.length != 8) {
              return 'CEP deve ter 8 dígitos';
            }
            if (_searchState == CepSearchState.notFound) {
              return 'CEP não encontrado';
            }
            if (_searchState == CepSearchState.error) {
              return 'Erro ao validar CEP';
            }
            return null;
          },
        );
      },
    );
  }

  String? _getHelperText() {
    switch (_searchState) {
      case CepSearchState.initial:
        return 'Digite seu CEP para buscar o endereço';
      case CepSearchState.searching:
        return 'Buscando endereço...';
      case CepSearchState.found:
        return 'Endereço encontrado ✓';
      case CepSearchState.notFound:
        return 'Verifique se o CEP está correto';
      case CepSearchState.error:
        return 'Tente novamente em alguns instantes';
    }
  }

  Color _getHelperColor() {
    switch (_searchState) {
      case CepSearchState.found:
        return Colors.green;
      case CepSearchState.notFound:
      case CepSearchState.error:
        return Theme.of(context).colorScheme.error;
      case CepSearchState.searching:
        return Theme.of(context).colorScheme.primary;
      case CepSearchState.initial:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }
}

enum CepSearchState {
  initial,
  searching,
  found,
  notFound,
  error,
}