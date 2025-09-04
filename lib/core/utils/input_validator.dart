import 'dart:io';

/// Comprehensive input validation utilities for security
class InputValidator {
  // Email validation regex - RFC 5322 compliant but practical
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );

  // Brazilian domains for additional validation
  static final List<String> _brazilianDomains = [
    'gmail.com', 'hotmail.com', 'outlook.com', 'yahoo.com.br', 
    'uol.com.br', 'bol.com.br', 'terra.com.br', 'globo.com',
    'ig.com.br', 'r7.com', 'globomail.com', 'oi.com.br'
  ];

  /// Validates email format with enhanced security checks
  static ValidationResult validateEmail(String email) {
    if (email.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Email não pode estar vazio',
      );
    }

    // Trim and convert to lowercase
    email = email.trim().toLowerCase();

    // Length check
    if (email.length > 254) {
      return ValidationResult(
        isValid: false,
        message: 'Email muito longo',
      );
    }

    // Basic format validation
    if (!_emailRegex.hasMatch(email)) {
      return ValidationResult(
        isValid: false,
        message: 'Formato de email inválido',
      );
    }

    // Check for suspicious patterns
    if (_hasSuspiciousEmailPatterns(email)) {
      return ValidationResult(
        isValid: false,
        message: 'Email com formato suspeito',
      );
    }

    // Additional Brazilian context validation
    final parts = email.split('@');
    if (parts.length != 2) {
      return ValidationResult(
        isValid: false,
        message: 'Email inválido',
      );
    }

    final localPart = parts[0];
    final domain = parts[1];

    // Local part validation
    if (localPart.isEmpty || localPart.length > 64) {
      return ValidationResult(
        isValid: false,
        message: 'Nome de usuário do email inválido',
      );
    }

    // Domain validation
    if (domain.isEmpty || !domain.contains('.')) {
      return ValidationResult(
        isValid: false,
        message: 'Domínio do email inválido',
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Email válido',
    );
  }

  /// Sanitizes user input to prevent injection attacks
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;

    return input
        .trim()
        // Remove null bytes
        .replaceAll('\x00', '')
        // Remove control characters except newlines and tabs
        .replaceAll(RegExp(r'[\x01-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
        // Limit length to prevent memory attacks
        .substring(0, input.length > 1000 ? 1000 : input.length);
  }

  /// Validates and sanitizes name input
  static ValidationResult validateName(String name) {
    if (name.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Nome não pode estar vazio',
      );
    }

    final sanitized = sanitizeInput(name);
    
    if (sanitized.length < 2) {
      return ValidationResult(
        isValid: false,
        message: 'Nome deve ter pelo menos 2 caracteres',
      );
    }

    if (sanitized.length > 100) {
      return ValidationResult(
        isValid: false,
        message: 'Nome muito longo',
      );
    }

    // Only allow letters, spaces, hyphens, and Brazilian diacritics
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s\-\'\.]+$');
    if (!nameRegex.hasMatch(sanitized)) {
      return ValidationResult(
        isValid: false,
        message: 'Nome contém caracteres inválidos',
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Nome válido',
      sanitizedValue: sanitized,
    );
  }

  /// Validates phone number for Brazilian context
  static ValidationResult validatePhone(String phone) {
    if (phone.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Telefone não pode estar vazio',
      );
    }

    // Remove formatting
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Brazilian phone validation (10 or 11 digits)
    if (cleanPhone.length < 10 || cleanPhone.length > 11) {
      return ValidationResult(
        isValid: false,
        message: 'Telefone deve ter 10 ou 11 dígitos',
      );
    }

    // Check for obviously fake numbers
    if (RegExp(r'^(\d)\1{9,10}$').hasMatch(cleanPhone)) {
      return ValidationResult(
        isValid: false,
        message: 'Telefone inválido',
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Telefone válido',
      sanitizedValue: cleanPhone,
    );
  }

  /// Validates password strength
  static ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'Senha não pode estar vazia',
      );
    }

    if (password.length < 8) {
      return ValidationResult(
        isValid: false,
        message: 'Senha deve ter pelo menos 8 caracteres',
      );
    }

    if (password.length > 128) {
      return ValidationResult(
        isValid: false,
        message: 'Senha muito longa',
      );
    }

    // Check for at least one lowercase, one uppercase, one digit
    if (!password.contains(RegExp(r'[a-z]'))) {
      return ValidationResult(
        isValid: false,
        message: 'Senha deve conter pelo menos uma letra minúscula',
      );
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return ValidationResult(
        isValid: false,
        message: 'Senha deve conter pelo menos uma letra maiúscula',
      );
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return ValidationResult(
        isValid: false,
        message: 'Senha deve conter pelo menos um número',
      );
    }

    // Check for common weak passwords
    final weakPasswords = [
      '12345678', 'password', 'senha123', 'admin123',
      'qwerty123', '123456789', 'password123'
    ];
    
    if (weakPasswords.any((weak) => 
        password.toLowerCase().contains(weak.toLowerCase()))) {
      return ValidationResult(
        isValid: false,
        message: 'Senha muito comum, escolha uma senha mais forte',
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'Senha forte',
    );
  }

  /// Checks for suspicious email patterns
  static bool _hasSuspiciousEmailPatterns(String email) {
    // Check for obvious test/temp patterns
    final suspiciousPatterns = [
      RegExp(r'test.*@'),
      RegExp(r'temp.*@'),
      RegExp(r'fake.*@'),
      RegExp(r'@test\.'),
      RegExp(r'@temp\.'),
      RegExp(r'@fake\.'),
      RegExp(r'@localhost'),
      RegExp(r'@127\.0\.0\.1'),
      RegExp(r'\.\.'), // Double dots
      RegExp(r'^\.'), // Starting with dot
      RegExp(r'\.$'), // Ending with dot
    ];

    return suspiciousPatterns.any((pattern) => pattern.hasMatch(email));
  }

  /// Validates Brazilian ZIP code (CEP)
  static ValidationResult validateZipCode(String zipCode) {
    final clean = zipCode.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (clean.length != 8) {
      return ValidationResult(
        isValid: false,
        message: 'CEP deve ter 8 dígitos',
      );
    }

    // Check for obviously fake CEPs
    if (RegExp(r'^(\d)\1{7}$').hasMatch(clean)) {
      return ValidationResult(
        isValid: false,
        message: 'CEP inválido',
      );
    }

    return ValidationResult(
      isValid: true,
      message: 'CEP válido',
      sanitizedValue: clean,
    );
  }

  /// Rate limiting check for sensitive operations
  static final Map<String, DateTime> _lastAttempts = {};
  
  static bool isRateLimited(String operation, {Duration cooldown = const Duration(seconds: 5)}) {
    final lastAttempt = _lastAttempts[operation];
    final now = DateTime.now();
    
    if (lastAttempt != null) {
      final timeDiff = now.difference(lastAttempt);
      if (timeDiff < cooldown) {
        return true; // Rate limited
      }
    }
    
    _lastAttempts[operation] = now;
    return false;
  }

  /// Detect potential brute force attempts
  static final Map<String, List<DateTime>> _failedAttempts = {};
  
  static bool isBruteForceAttempt(String identifier, {int maxAttempts = 5, Duration window = const Duration(minutes: 15)}) {
    final now = DateTime.now();
    final attempts = _failedAttempts[identifier] ?? [];
    
    // Clean old attempts outside the window
    attempts.removeWhere((attempt) => now.difference(attempt) > window);
    
    // Check if we've exceeded the limit
    if (attempts.length >= maxAttempts) {
      return true;
    }
    
    // Record this attempt
    attempts.add(now);
    _failedAttempts[identifier] = attempts;
    
    return false;
  }

  /// Clear failed attempts for an identifier (on successful auth)
  static void clearFailedAttempts(String identifier) {
    _failedAttempts.remove(identifier);
  }
}

/// Validation result class
class ValidationResult {
  final bool isValid;
  final String message;
  final String? sanitizedValue;

  ValidationResult({
    required this.isValid,
    required this.message,
    this.sanitizedValue,
  });
}