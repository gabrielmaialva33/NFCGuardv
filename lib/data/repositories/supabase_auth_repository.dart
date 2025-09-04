import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/environment_config.dart';
import '../../core/services/supabase_service.dart';
import '../models/user_model.dart';

class SupabaseAuthRepository {
  final SupabaseClient _client = SupabaseService.client;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );

      // Create user profile if signup successful
      if (response.user != null) {
        await _createUserProfile(response.user!, userData);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Get user profile from database
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _client.from('users').update(data).eq('id', userId);
  }

  /// Create user profile in database
  Future<void> _createUserProfile(
    User user,
    Map<String, dynamic> userData,
  ) async {
    final userProfile = {
      'id': user.id,
      'email': user.email,
      'full_name': userData['full_name'],
      'cpf': userData['cpf'],
      'phone': userData['phone'],
      'birth_date': userData['birth_date'],
      'gender': userData['gender'],
      'cep': userData['cep'],
      'street': userData['street'],
      'number_address': userData['number_address'],
      'complement': userData['complement'],
      'neighborhood': userData['neighborhood'],
      'city': userData['city'],
      'state': userData['state'],
      'user_code': userData['user_code'],
      'trial_mode': userData['trial_mode'] ?? false,
    };

    await _client.from('users').insert(userProfile);
  }

  /// Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await _client
          .from(SupabaseConfig.usersTable)
          .select('id')
          .eq('email', email)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if CPF exists
  Future<bool> checkCpfExists(String cpf) async {
    try {
      final response = await _client
          .from(SupabaseConfig.usersTable)
          .select('id')
          .eq('cpf', cpf)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Generate unique user code
  Future<String> generateUserCode() async {
    // Try to use database function first
    try {
      final response = await _client.rpc('generate_user_code');
      if (response != null) {
        return response.toString();
      }
    } catch (e) {
      // Fall back to manual generation if function doesn't exist
    }

    // Manual generation fallback
    String code;
    bool exists;
    do {
      // Generate 8-digit code
      final random = DateTime.now().millisecondsSinceEpoch % 100000000;
      code = random.toString().padLeft(8, '0');

      // Check if exists
      final response = await _client
          .from(SupabaseConfig.usersTable)
          .select('id')
          .eq('user_code', code)
          .limit(1);

      exists = response.isNotEmpty;
    } while (exists);

    return code;
  }
}
