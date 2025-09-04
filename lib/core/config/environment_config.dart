import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure environment configuration management
/// Handles API keys and sensitive configuration data
class EnvironmentConfig {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys for secure configuration
  static const String _nvidiaApiKeyKey = 'nvidia_api_key_encrypted';
  static const String _supabaseUrlKey = 'supabase_url_encrypted';
  static const String _supabaseAnonKeyKey = 'supabase_anon_key_encrypted';

  // Default/fallback values for development
  static const String _defaultNvidiaApiUrl = 
      'https://integrate.api.nvidia.com/v1/chat/completions';
  static const String _defaultBestModel = 'qwen/qwen3-coder-480b-a35b-instruct';

  /// Initialize configuration from environment variables or secure storage
  static Future<void> initialize() async {
    try {
      // Try to load from environment variables first (for development)
      const nvidiaKey = String.fromEnvironment('NVIDIA_API_KEY');
      const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
      const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

      // Store in secure storage if environment variables are provided
      if (nvidiaKey.isNotEmpty) {
        await _secureStorage.write(key: _nvidiaApiKeyKey, value: nvidiaKey);
      }
      if (supabaseUrl.isNotEmpty) {
        await _secureStorage.write(key: _supabaseUrlKey, value: supabaseUrl);
      }
      if (supabaseAnonKey.isNotEmpty) {
        await _secureStorage.write(key: _supabaseAnonKeyKey, value: supabaseAnonKey);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Environment config initialization error: $e');
      }
    }
  }

  /// Get NVIDIA API key securely
  static Future<String?> getNvidiaApiKey() async {
    try {
      return await _secureStorage.read(key: _nvidiaApiKeyKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error reading NVIDIA API key: $e');
      }
      return null;
    }
  }

  /// Get NVIDIA API URL
  static String getNvidiaApiUrl() {
    return _defaultNvidiaApiUrl;
  }

  /// Get NVIDIA best model
  static String getBestModel() {
    return _defaultBestModel;
  }

  /// Get Supabase URL securely
  static Future<String?> getSupabaseUrl() async {
    try {
      return await _secureStorage.read(key: _supabaseUrlKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error reading Supabase URL: $e');
      }
      return null;
    }
  }

  /// Get Supabase anonymous key securely
  static Future<String?> getSupabaseAnonKey() async {
    try {
      return await _secureStorage.read(key: _supabaseAnonKeyKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error reading Supabase anon key: $e');
      }
      return null;
    }
  }

  /// Set API keys programmatically (for testing or manual configuration)
  static Future<void> setNvidiaApiKey(String apiKey) async {
    if (apiKey.isEmpty) {
      throw ArgumentError('API key cannot be empty');
    }
    await _secureStorage.write(key: _nvidiaApiKeyKey, value: apiKey);
  }

  /// Set Supabase configuration programmatically
  static Future<void> setSupabaseConfig({
    required String url,
    required String anonKey,
  }) async {
    if (url.isEmpty || anonKey.isEmpty) {
      throw ArgumentError('Supabase URL and anon key cannot be empty');
    }
    await _secureStorage.write(key: _supabaseUrlKey, value: url);
    await _secureStorage.write(key: _supabaseAnonKeyKey, value: anonKey);
  }

  /// Check if configuration is complete
  static Future<bool> isConfigurationComplete() async {
    final nvidiaKey = await getNvidiaApiKey();
    final supabaseUrl = await getSupabaseUrl();
    final supabaseKey = await getSupabaseAnonKey();
    
    return nvidiaKey != null && 
           nvidiaKey.isNotEmpty && 
           supabaseUrl != null && 
           supabaseUrl.isNotEmpty &&
           supabaseKey != null && 
           supabaseKey.isNotEmpty;
  }

  /// Clear all configuration (for testing or reset)
  static Future<void> clearConfiguration() async {
    if (kDebugMode) {
      await _secureStorage.delete(key: _nvidiaApiKeyKey);
      await _secureStorage.delete(key: _supabaseUrlKey);
      await _secureStorage.delete(key: _supabaseAnonKeyKey);
    }
  }

  /// Validate API key format
  static bool isValidNvidiaApiKey(String? apiKey) {
    if (apiKey == null || apiKey.isEmpty) return false;
    
    // NVIDIA API keys typically start with 'nvapi-' and are 64+ characters
    return apiKey.startsWith('nvapi-') && apiKey.length >= 64;
  }

  /// Validate Supabase URL format
  static bool isValidSupabaseUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && 
             uri.scheme == 'https' && 
             uri.host.contains('supabase.co');
    } catch (e) {
      return false;
    }
  }

  /// Validate Supabase anon key format
  static bool isValidSupabaseAnonKey(String? key) {
    if (key == null || key.isEmpty) return false;
    
    // Supabase anon keys typically start with 'sbp_' or 'eyJ' (JWT format)
    return (key.startsWith('sbp_') && key.length >= 32) ||
           (key.startsWith('eyJ') && key.length >= 100);
  }
}