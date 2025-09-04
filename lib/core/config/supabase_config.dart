class SupabaseConfig {
  // Replace with your actual Supabase URL and anon key
  static const String supabaseUrl = 'https://wfhecwwjfzxhwzfwfwbx.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // Replace with your actual anon key
  
  // Database connection strings (for reference, actual connection handled by supabase_flutter)
  static const String databaseUrl = 'postgresql://postgres:[YOUR-PASSWORD]@db.wfhecwwjfzxhwzfwfwbx.supabase.co:5432/postgres';
  static const String poolerUrl = 'postgresql://postgres.wfhecwwjfzxhwzfwfwbx:[YOUR-PASSWORD]@aws-1-sa-east-1.pooler.supabase.com:6543/postgres';
  static const String directUrl = 'postgresql://postgres.wfhecwwjfzxhwzfwfwbx:[YOUR-PASSWORD]@aws-1-sa-east-1.pooler.supabase.com:5432/postgres';
}