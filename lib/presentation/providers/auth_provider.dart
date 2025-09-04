import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:search_cep/search_cep.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/code_generator.dart';
import '../../data/datasources/secure_storage_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  final _storageService = SecureStorageService();
  final _authRepository = SupabaseAuthRepository();
  final _supabaseClient = Supabase.instance.client;

  @override
  AsyncValue<UserEntity?> build() {
    _initializeAuth();
    return const AsyncValue.loading();
  }

  /// Initialize authentication and check for existing session
  Future<void> _initializeAuth() async {
    try {
      // Listen to auth state changes
      _supabaseClient.auth.onAuthStateChange.listen((data) {
        _handleAuthStateChange(data);
      });

      // Check if user is already logged in
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser != null) {
        await _loadUserProfile(currentUser.id);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Handle Supabase auth state changes
  void _handleAuthStateChange(AuthState authState) async {
    final event = authState.event;
    final user = authState.session?.user;

    switch (event) {
      case AuthChangeEvent.signedIn:
        if (user != null) {
          await _loadUserProfile(user.id);
        }
        break;
      case AuthChangeEvent.signedOut:
        await _storageService.clearStorage();
        state = const AsyncValue.data(null);
        break;
      case AuthChangeEvent.tokenRefreshed:
        // Token refreshed - user stays logged in
        break;
      default:
        break;
    }
  }

  /// Load user profile from Supabase
  Future<void> _loadUserProfile(String userId) async {
    try {
      final userProfile = await _authRepository.getUserProfile(userId);
      if (userProfile != null) {
        await _storageService.saveUser(userProfile);
        state = AsyncValue.data(userProfile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final response = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // User profile will be loaded through auth state change listener
        return;
      } else {
        throw Exception('Falha no login');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Registers a new user with the provided information
  Future<void> register({
    required String fullName,
    required String cpf,
    required String email,
    required String phone,
    required DateTime birthDate,
    required String gender,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();

      // Basic validations
      if (cpf.length < 11) {
        throw Exception(AppConstants.invalidCpfMessage);
      }

      if (!email.contains('@')) {
        throw Exception('Email inválido');
      }

      // Generate unique 8-digit code
      String eightDigitCode = CodeGenerator.generateUniqueCode();

      // Prepare user data
      final userData = {
        'full_name': fullName,
        'cpf': cpf.replaceAll(RegExp(r'[^0-9]'), ''),
        'phone': phone,
        'birth_date': birthDate.toIso8601String().split('T')[0],
        'gender': gender,
        'user_code': eightDigitCode,
      };

      // Sign up with Supabase
      await _authRepository.signUp(
        email: email,
        password: password,
        userData: userData,
      );

      // User profile will be loaded through auth state change listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Updates user address information
  Future<void> updateAddress({
    required String zipCode,
    required String address,
    required String neighborhood,
    required String city,
    required String stateCode,
  }) async {
    try {
      final currentUser = state.value;
      if (currentUser == null) throw Exception('Usuário não encontrado');

      final updatedUser = currentUser.copyWith(
        zipCode: zipCode,
        address: address,
        neighborhood: neighborhood,
        city: city,
        state: stateCode,
      );

      await _storageService.saveUser(UserModel.fromEntity(updatedUser));
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Searches for address information by Brazilian ZIP code (CEP)
  Future<Map<String, String>?> searchZipCode(String zipCode) async {
    try {
      final viaCepService = ViaCepSearchCep();
      final result = await viaCepService.searchInfoByCep(cep: zipCode);

      return result.fold(
        (error) => null,
        (addressInfo) => {
          'address': addressInfo.logradouro ?? '',
          'neighborhood': addressInfo.bairro ?? '',
          'city': addressInfo.localidade ?? '',
          'stateCode': addressInfo.uf ?? '',
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error searching ZIP code: $e');
      }
      return null;
    }
  }

  /// Validates if a code can be used (format and uniqueness check)
  Future<bool> validateCodeForUse(String code) async {
    try {
      // Validate code format
      if (!CodeGenerator.validateCode(code)) {
        throw Exception(AppConstants.invalidCodeMessage);
      }

      // Check if code has already been used
      final isUsed = await _storageService.isCodeUsed(code);
      if (isUsed) {
        throw Exception(AppConstants.codeAlreadyUsedMessage);
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Marks a code as used to prevent reuse
  Future<void> markCodeAsUsed(String code) async {
    try {
      await _storageService.addUsedCode(code);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking code as used: $e');
      }
    }
  }

  /// Logs out the current user and clears stored data
  Future<void> logout() async {
    try {
      await _authRepository.signOut();
      // Auth state change listener will handle clearing storage and updating state
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Get current user session
  User? get currentUser => _supabaseClient.auth.currentUser;
  
  /// Check if user is authenticated
  bool get isAuthenticated => _supabaseClient.auth.currentUser != null;
}
