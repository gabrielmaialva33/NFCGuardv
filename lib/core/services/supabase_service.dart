import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/environment_config.dart';

class SupabaseService {
  static SupabaseService? _instance;

  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    final url = await EnvironmentConfig.getSupabaseUrl();
    final key = await EnvironmentConfig.getSupabaseAnonKey();
    
    if (url != null && key != null) {
      await Supabase.initialize(
        url: url,
        anonKey: key,
        debug: false, // Set to true for development
      );
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => client.auth.currentUser != null;

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Get current user ID
  String? get currentUserId => client.auth.currentUser?.id;

  /// Check if Supabase is connected
  Future<bool> checkConnection() async {
    try {
      await client.from('health_check').select().limit(1);
      return true;
    } catch (e) {
      // If health_check table doesn't exist, try a simple query
      try {
        await client.auth.getUser();
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  /// Get table reference
  SupabaseQueryBuilder table(String tableName) {
    return client.from(tableName);
  }

  /// Get storage bucket
  SupabaseStorageClient get storage => client.storage;

  /// Subscribe to auth changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
