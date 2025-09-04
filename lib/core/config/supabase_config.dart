import 'environment_config.dart';

class SupabaseConfig {
  // NFCGuard Supabase Project Configuration
  // SECURITY: Credentials moved to EnvironmentConfig for secure storage
  
  /// Get Supabase URL securely
  static Future<String> getSupabaseUrl() async {
    final url = await EnvironmentConfig.getSupabaseUrl();
    if (url == null) {
      throw Exception('Supabase URL not configured. Use EnvironmentConfig.setSupabaseConfig()');
    }
    return url;
  }
  
  /// Get Supabase anonymous key securely
  static Future<String> getSupabaseAnonKey() async {
    final key = await EnvironmentConfig.getSupabaseAnonKey();
    if (key == null) {
      throw Exception('Supabase anon key not configured. Use EnvironmentConfig.setSupabaseConfig()');
    }
    return key;
  }

  // Table names
  static const String usersTable = 'users';
  static const String nfcLogsTable = 'nfc_logs';
  static const String usedCodesTable = 'used_codes';
  static const String trialDataTable = 'trial_data';

  // Authentication settings
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration sessionTimeout = Duration(hours: 24);

  // Storage bucket names
  static const String userDataBucket = 'user-data';
  static const String backupsBucket = 'backups';

  // SECURITY: Database connection strings removed for security
  // Use Supabase client SDK instead of direct database connections
}
