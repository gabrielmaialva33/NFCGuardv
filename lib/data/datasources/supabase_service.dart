import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;

  SupabaseService._internal() {
    _client = Supabase.instance.client;
  }

  static SupabaseService get instance {
    _instance ??= SupabaseService._internal();
    return _instance!;
  }

  SupabaseClient get client => _client;

  // Auth methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Database methods
  SupabaseQueryBuilder from(String table) => _client.from(table);

  // Real-time subscriptions
  SupabaseStreamBuilder stream(String table) => _client.from(table).stream(primaryKey: ['id']);
}