import 'package:flutter/foundation.dart';

import '../config/environment_config.dart';
import '../security/network_security.dart';
import '../utils/input_validator.dart' as validator;

/// Central security service for application-wide security initialization and checks
class SecurityService {
  static bool _isInitialized = false;
  
  /// Initialize all security components
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize environment configuration
      await EnvironmentConfig.initialize();
      
      // Validate configuration in production
      if (!kDebugMode) {
        await _validateProductionConfiguration();
      }
      
      // Setup security monitoring
      _setupSecurityMonitoring();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        debugPrint('SecurityService initialized successfully');
      }
    } catch (e) {
      final sanitizedError = NetworkSecurity.sanitizeErrorMessage(e.toString());
      if (kDebugMode) {
        debugPrint('SecurityService initialization failed: $sanitizedError');
      }
      rethrow;
    }
  }
  
  /// Validate that all required configuration is present in production
  static Future<void> _validateProductionConfiguration() async {
    final isConfigComplete = await EnvironmentConfig.isConfigurationComplete();
    
    if (!isConfigComplete) {
      throw Exception('Configuração de segurança incompleta para produção');
    }
    
    // Validate API key formats
    final nvidiaKey = await EnvironmentConfig.getNvidiaApiKey();
    if (!EnvironmentConfig.isValidNvidiaApiKey(nvidiaKey)) {
      throw Exception('Chave NVIDIA API inválida');
    }
    
    final supabaseUrl = await EnvironmentConfig.getSupabaseUrl();
    final supabaseKey = await EnvironmentConfig.getSupabaseAnonKey();
    
    if (!EnvironmentConfig.isValidSupabaseUrl(supabaseUrl)) {
      throw Exception('URL Supabase inválida');
    }
    
    if (!EnvironmentConfig.isValidSupabaseAnonKey(supabaseKey)) {
      throw Exception('Chave Supabase inválida');
    }
  }
  
  /// Setup security monitoring and logging
  static void _setupSecurityMonitoring() {
    // In a real implementation, you might setup:
    // - Security event logging
    // - Anomaly detection
    // - Threat monitoring
    
    if (kDebugMode) {
      debugPrint('Security monitoring enabled');
    }
  }
  
  /// Check if security service is properly initialized
  static bool get isInitialized => _isInitialized;
  
  /// Validate input for security-sensitive operations
  static validator.ValidationResult validateSecurityInput(String input, String type) {
    switch (type.toLowerCase()) {
      case 'email':
        return validator.InputValidator.validateEmail(input);
      case 'name':
        return validator.InputValidator.validateName(input);
      case 'phone':
        return validator.InputValidator.validatePhone(input);
      case 'password':
        return validator.InputValidator.validatePassword(input);
      case 'zipcode':
      case 'cep':
        return validator.InputValidator.validateZipCode(input);
      default:
        return validator.ValidationResult(
          isValid: false,
          message: 'Tipo de validação desconhecido',
        );
    }
  }
  
  /// Sanitize all user inputs
  static Map<String, String> sanitizeUserData(Map<String, String> userData) {
    final sanitized = <String, String>{};
    
    for (final entry in userData.entries) {
      sanitized[entry.key] = validator.InputValidator.sanitizeInput(entry.value);
    }
    
    return sanitized;
  }
  
  /// Log security events (placeholder for actual implementation)
  static void logSecurityEvent(String event, Map<String, dynamic> context) {
    if (kDebugMode) {
      final sanitizedContext = <String, dynamic>{};
      context.forEach((key, value) {
        sanitizedContext[key] = NetworkSecurity.sanitizeErrorMessage(value.toString());
      });
      
      debugPrint('Security Event: $event - Context: $sanitizedContext');
    }
    
    // In production, send to security monitoring service
    // This would be implemented based on your monitoring solution
  }
  
  /// Reset security state (for testing only)
  static Future<void> reset() async {
    if (kDebugMode) {
      await EnvironmentConfig.clearConfiguration();
      _isInitialized = false;
    }
  }
}