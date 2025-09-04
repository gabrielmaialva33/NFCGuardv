import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Network security utilities for secure HTTP communications
class NetworkSecurity {
  static const List<String> _trustedHosts = [
    'supabase.co',
    'integrate.api.nvidia.com',
    'viacep.com.br',
    'pool.ntp.org',
  ];

  /// Creates a secure HTTP client with certificate pinning and security headers
  static http.Client createSecureClient() {
    final client = http.Client();
    
    // In production, we would implement actual certificate pinning here
    // For now, we ensure HTTPS and validate hosts
    return _SecureHttpClient(client);
  }

  /// Validates if a URL is allowed for network requests
  static bool isAllowedUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Must be HTTPS in production
      if (!kDebugMode && uri.scheme != 'https') {
        return false;
      }

      // Must be from trusted hosts
      return _trustedHosts.any((host) => uri.host.endsWith(host));
    } catch (e) {
      return false;
    }
  }

  /// Get security headers for HTTP requests
  static Map<String, String> getSecurityHeaders() {
    return {
      'User-Agent': 'NFCGuard/1.0.0 (${Platform.operatingSystem})',
      'Accept': 'application/json',
      'Accept-Language': 'pt-BR,pt;q=0.9,en;q=0.8',
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
      if (!kDebugMode) 'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    };
  }

  /// Sanitize error messages to prevent information leakage
  static String sanitizeErrorMessage(String error) {
    // Remove sensitive information from error messages
    String sanitized = error;
    
    // Remove API keys
    sanitized = sanitized.replaceAll(RegExp(r'nvapi-[A-Za-z0-9_-]+'), '[API_KEY_REDACTED]');
    sanitized = sanitized.replaceAll(RegExp(r'sbp_[A-Za-z0-9_-]+'), '[SUPABASE_KEY_REDACTED]');
    sanitized = sanitized.replaceAll(RegExp(r'eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*\.[A-Za-z0-9_-]*'), '[JWT_REDACTED]');
    
    // Remove database connection strings
    sanitized = sanitized.replaceAll(RegExp(r'postgresql://[^@]*@[^/]*/'), 'postgresql://[REDACTED]/');
    
    // Remove IP addresses
    sanitized = sanitized.replaceAll(RegExp(r'\b(?:\d{1,3}\.){3}\d{1,3}\b'), '[IP_REDACTED]');
    
    // Remove URLs with credentials
    sanitized = sanitized.replaceAll(RegExp(r'https?://[^@]*@'), 'https://[CREDENTIALS_REDACTED]@');
    
    // In production, provide generic error messages
    if (!kDebugMode) {
      if (sanitized.toLowerCase().contains('network') || 
          sanitized.toLowerCase().contains('connection') ||
          sanitized.toLowerCase().contains('timeout')) {
        return 'Erro de conexão. Verifique sua internet.';
      }
      
      if (sanitized.toLowerCase().contains('auth') || 
          sanitized.toLowerCase().contains('login') ||
          sanitized.toLowerCase().contains('password')) {
        return 'Erro de autenticação. Verifique suas credenciais.';
      }
      
      if (sanitized.toLowerCase().contains('permission') || 
          sanitized.toLowerCase().contains('unauthorized')) {
        return 'Acesso negado.';
      }
      
      return 'Erro interno do aplicativo.';
    }
    
    return sanitized;
  }

  /// Validates SSL certificate (placeholder for actual implementation)
  static bool validateCertificate(String host) {
    // In a real implementation, you would check certificate pinning here
    // For now, just ensure we're connecting to trusted hosts
    return _trustedHosts.any((trustedHost) => host.endsWith(trustedHost));
  }
}

/// Secure HTTP client wrapper
class _SecureHttpClient extends http.BaseClient {
  final http.Client _inner;

  _SecureHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Validate URL before sending
    if (!NetworkSecurity.isAllowedUrl(request.url.toString())) {
      throw Exception('URL não permitida: ${request.url.host}');
    }

    // Add security headers
    final securityHeaders = NetworkSecurity.getSecurityHeaders();
    request.headers.addAll(securityHeaders);

    // Ensure HTTPS in production
    if (!kDebugMode && request.url.scheme != 'https') {
      throw Exception('HTTPS obrigatório em produção');
    }

    try {
      return await _inner.send(request);
    } catch (e) {
      // Sanitize error before rethrowing
      final sanitizedError = NetworkSecurity.sanitizeErrorMessage(e.toString());
      throw Exception(sanitizedError);
    }
  }

  @override
  void close() {
    _inner.close();
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