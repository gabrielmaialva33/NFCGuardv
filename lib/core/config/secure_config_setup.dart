import 'package:flutter/foundation.dart';

import 'environment_config.dart';

/// Helper class for securely setting up configuration
/// Use this for initial app setup or configuration management
class SecureConfigSetup {
  
  /// Setup configuration from environment variables or manual input
  static Future<void> setupFromEnvironment() async {
    try {
      // This will load from environment variables if available
      await EnvironmentConfig.initialize();
      
      // Check if configuration is complete
      final isComplete = await EnvironmentConfig.isConfigurationComplete();
      
      if (!isComplete) {
        if (kDebugMode) {
          debugPrint('Environment configuration incomplete. Some features may not work.');
          debugPrint('Use SecureConfigSetup.setupManually() to configure manually.');
        }
      } else {
        if (kDebugMode) {
          debugPrint('Environment configuration loaded successfully');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting up environment configuration: $e');
      }
      rethrow;
    }
  }
  
  /// Manually setup configuration (for development or first-time setup)
  static Future<void> setupManually({
    required String nvidiaApiKey,
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    try {
      // Validate inputs
      if (!EnvironmentConfig.isValidNvidiaApiKey(nvidiaApiKey)) {
        throw ArgumentError('Invalid NVIDIA API key format');
      }
      
      if (!EnvironmentConfig.isValidSupabaseUrl(supabaseUrl)) {
        throw ArgumentError('Invalid Supabase URL format');
      }
      
      if (!EnvironmentConfig.isValidSupabaseAnonKey(supabaseAnonKey)) {
        throw ArgumentError('Invalid Supabase anon key format');
      }
      
      // Set configuration
      await EnvironmentConfig.setNvidiaApiKey(nvidiaApiKey);
      await EnvironmentConfig.setSupabaseConfig(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      
      if (kDebugMode) {
        debugPrint('Manual configuration setup completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in manual configuration setup: $e');
      }
      rethrow;
    }
  }
  
  /// Check configuration status
  static Future<ConfigurationStatus> getConfigurationStatus() async {
    try {
      final isComplete = await EnvironmentConfig.isConfigurationComplete();
      final nvidiaKey = await EnvironmentConfig.getNvidiaApiKey();
      final supabaseUrl = await EnvironmentConfig.getSupabaseUrl();
      final supabaseKey = await EnvironmentConfig.getSupabaseAnonKey();
      
      return ConfigurationStatus(
        isComplete: isComplete,
        hasNvidiaKey: nvidiaKey != null && nvidiaKey.isNotEmpty,
        hasSupabaseUrl: supabaseUrl != null && supabaseUrl.isNotEmpty,
        hasSupabaseKey: supabaseKey != null && supabaseKey.isNotEmpty,
        isNvidiaKeyValid: EnvironmentConfig.isValidNvidiaApiKey(nvidiaKey),
        isSupabaseUrlValid: EnvironmentConfig.isValidSupabaseUrl(supabaseUrl),
        isSupabaseKeyValid: EnvironmentConfig.isValidSupabaseAnonKey(supabaseKey),
      );
    } catch (e) {
      return ConfigurationStatus(isComplete: false);
    }
  }
  
  /// Generate configuration checklist for debugging
  static Future<Map<String, dynamic>> generateConfigChecklist() async {
    if (!kDebugMode) {
      return {'error': 'Only available in debug mode'};
    }
    
    try {
      final status = await getConfigurationStatus();
      
      return {
        'configuration_complete': status.isComplete,
        'nvidia_api_key': {
          'present': status.hasNvidiaKey,
          'valid_format': status.isNvidiaKeyValid,
          'status': status.hasNvidiaKey && status.isNvidiaKeyValid ? 'OK' : 'MISSING/INVALID',
        },
        'supabase_url': {
          'present': status.hasSupabaseUrl,
          'valid_format': status.isSupabaseUrlValid,
          'status': status.hasSupabaseUrl && status.isSupabaseUrlValid ? 'OK' : 'MISSING/INVALID',
        },
        'supabase_anon_key': {
          'present': status.hasSupabaseKey,
          'valid_format': status.isSupabaseKeyValid,
          'status': status.hasSupabaseKey && status.isSupabaseKeyValid ? 'OK' : 'MISSING/INVALID',
        },
        'recommendations': _generateRecommendations(status),
      };
    } catch (e) {
      return {
        'error': 'Failed to generate checklist',
        'details': e.toString(),
      };
    }
  }
  
  static List<String> _generateRecommendations(ConfigurationStatus status) {
    final recommendations = <String>[];
    
    if (!status.hasNvidiaKey || !status.isNvidiaKeyValid) {
      recommendations.add('Set valid NVIDIA API key using EnvironmentConfig.setNvidiaApiKey()');
    }
    
    if (!status.hasSupabaseUrl || !status.isSupabaseUrlValid) {
      recommendations.add('Set valid Supabase URL using EnvironmentConfig.setSupabaseConfig()');
    }
    
    if (!status.hasSupabaseKey || !status.isSupabaseKeyValid) {
      recommendations.add('Set valid Supabase anon key using EnvironmentConfig.setSupabaseConfig()');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Configuration looks good!');
    }
    
    return recommendations;
  }
  
  /// Clear all configuration (development only)
  static Future<void> clearConfiguration() async {
    if (!kDebugMode) {
      throw Exception('Configuration clearing only allowed in debug mode');
    }
    
    await EnvironmentConfig.clearConfiguration();
  }
}

/// Configuration status data class
class ConfigurationStatus {
  final bool isComplete;
  final bool hasNvidiaKey;
  final bool hasSupabaseUrl;
  final bool hasSupabaseKey;
  final bool isNvidiaKeyValid;
  final bool isSupabaseUrlValid;
  final bool isSupabaseKeyValid;
  
  ConfigurationStatus({
    required this.isComplete,
    this.hasNvidiaKey = false,
    this.hasSupabaseUrl = false,
    this.hasSupabaseKey = false,
    this.isNvidiaKeyValid = false,
    this.isSupabaseUrlValid = false,
    this.isSupabaseKeyValid = false,
  });
}