class SupabaseConfig {
  // NFCGuard Supabase Project Configuration
  static const String supabaseUrl = 'https://wfhecwwjfzxhwzfwfwbx.supabase.co';
  static const String supabaseAnonKey =
      'sbp_db7013246b0de8c2be1eaeba080cc90ac4520a4e';

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

  // Database connection strings (for reference only)
  static const String databaseUrl =
      'postgresql://postgres:nfc_guard@01743@db.wfhecwwjfzxhwzfwfwbx.supabase.co:5432/postgres';
  static const String poolerUrl =
      'postgresql://postgres.wfhecwwjfzxhwzfwfwbx:nfc_guard@01743@aws-1-sa-east-1.pooler.supabase.com:6543/postgres';
  static const String directUrl =
      'postgresql://postgres.wfhecwwjfzxhwzfwfwbx:nfc_guard@01743@aws-1-sa-east-1.pooler.supabase.com:5432/postgres';
}
