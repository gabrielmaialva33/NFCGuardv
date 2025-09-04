import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:search_cep/search_cep.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/security/network_security.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/code_generator.dart';
import '../../core/utils/input_validator.dart';
import '../../data/datasources/secure_storage_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../domain/entities/user_entity.dart';

part 'supabase_auth_provider.g.dart';

@riverpod
class SupabaseAuth extends _$SupabaseAuth {
  final _storageService = SecureStorageService();
  final _authRepository = SupabaseAuthRepository();

  @override
  AsyncValue<UserEntity?> build() {
    _loadUser();
    _listenToAuthChanges();
    return const AsyncValue.loading();
  }

  void _listenToAuthChanges() {
    _authRepository.authStateChanges.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _syncUserFromSupabase(session.user);
      } else if (event == AuthChangeEvent.signedOut) {
        state = const AsyncValue.data(null);
        _storageService.clearStorage();
      }
    });
  }

  Future<void> _loadUser() async {
    try {
      // First check if there's a Supabase session
      final supabaseUser = SupabaseService.instance.currentUser;
      if (supabaseUser != null) {
        await _syncUserFromSupabase(supabaseUser);
        return;
      }

      // Fallback to local storage
      final user = await _storageService.getUser();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _syncUserFromSupabase(User supabaseUser) async {
    try {
      // Try to get user profile from Supabase
      final profileResponse = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', supabaseUser.id)
          .single();

      final profile = profileResponse;

      final user = UserModel(
        id: supabaseUser.id,
        fullName: profile['full_name'] ?? '',
        cpf: profile['cpf'] ?? '',
        email: supabaseUser.email ?? '',
        phone: profile['phone'] ?? '',
        birthDate: profile['birth_date'] != null
            ? DateTime.parse(profile['birth_date'])
            : DateTime.now(),
        gender: profile['gender'] ?? '',
        zipCode: profile['zip_code'] ?? '',
        address: profile['address'] ?? '',
        neighborhood: profile['neighborhood'] ?? '',
        city: profile['city'] ?? '',
        state: profile['state'] ?? '',
        eightDigitCode: profile['eight_digit_code'] ?? '',
        createdAt: profile['created_at'] != null
            ? DateTime.parse(profile['created_at'])
            : DateTime.now(),
      );

      // Also save to local storage for offline access
      await _storageService.saveUser(user);
      state = AsyncValue.data(user);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error syncing user from Supabase: $e');
      }
      // Fallback to local storage if Supabase sync fails
      final user = await _storageService.getUser();
      state = AsyncValue.data(user);
    }
  }

  /// Registers a new user with Supabase and local storage
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

      // Enhanced input validation and sanitization
      final nameValidation = InputValidator.validateName(fullName);
      if (!nameValidation.isValid) {
        throw Exception(nameValidation.message);
      }
      
      final emailValidation = InputValidator.validateEmail(email);
      if (!emailValidation.isValid) {
        throw Exception(emailValidation.message);
      }
      
      final phoneValidation = InputValidator.validatePhone(phone);
      if (!phoneValidation.isValid) {
        throw Exception(phoneValidation.message);
      }

      // Sanitize inputs
      final sanitizedName = nameValidation.sanitizedValue ?? fullName;
      final sanitizedEmail = emailValidation.sanitizedValue ?? email.trim().toLowerCase();
      final sanitizedPhone = phoneValidation.sanitizedValue ?? phone;
      
      // CPF validation (keeping existing logic for Brazilian context)
      if (cpf.length < 11) {
        throw Exception(AppConstants.invalidCpfMessage);
      }
      
      // Rate limiting check for registration attempts
      if (InputValidator.isRateLimited('registration_$sanitizedEmail')) {
        throw Exception('Muitas tentativas. Aguarde alguns segundos.');
      }

      // Generate unique 8-digit code
      String eightDigitCode = CodeGenerator.generateUniqueCode();

      // Sign up with Supabase using sanitized data
      final authResponse = await SupabaseService.instance.signUp(
        email: sanitizedEmail,
        password: password,
        data: {
          'full_name': sanitizedName,
          'cpf': cpf.replaceAll(RegExp(r'[^0-9]'), ''),
          'phone': sanitizedPhone,
          'birth_date': birthDate.toIso8601String(),
          'gender': gender,
          'eight_digit_code': eightDigitCode,
        },
      );

      if (authResponse.user != null) {
        // Create profile in Supabase using sanitized data
        await SupabaseService.client.from('profiles').insert({
          'id': authResponse.user!.id,
          'full_name': sanitizedName,
          'cpf': cpf.replaceAll(RegExp(r'[^0-9]'), ''),
          'email': sanitizedEmail,
          'phone': sanitizedPhone,
          'birth_date': birthDate.toIso8601String(),
          'gender': gender,
          'eight_digit_code': eightDigitCode,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Create local user model using sanitized data
        final user = UserModel(
          id: authResponse.user!.id,
          fullName: sanitizedName,
          cpf: cpf.replaceAll(RegExp(r'[^0-9]'), ''),
          email: sanitizedEmail,
          phone: sanitizedPhone,
          birthDate: birthDate,
          gender: gender,
          zipCode: '',
          address: '',
          neighborhood: '',
          city: '',
          state: '',
          eightDigitCode: eightDigitCode,
          createdAt: DateTime.now(),
        );

        // Save to local storage
        await _storageService.saveUser(user);
        state = AsyncValue.data(user);
      } else {
        throw Exception('Falha ao criar conta');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Signs in with email and password
  Future<void> signIn({required String email, required String password}) async {
    try {
      state = const AsyncValue.loading();

      final authResponse = await SupabaseService.instance.signIn(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        await _syncUserFromSupabase(authResponse.user!);
      } else {
        throw Exception('Falha no login');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Updates user address information in both Supabase and local storage
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

      // Update in Supabase
      final supabaseUser = SupabaseService.instance.currentUser;
      if (supabaseUser != null) {
        await SupabaseService.client
            .from('profiles')
            .update({
              'zip_code': zipCode,
              'address': address,
              'neighborhood': neighborhood,
              'city': city,
              'state': stateCode,
            })
            .eq('id', supabaseUser.id);
      }

      // Update locally
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

      // Check in Supabase first, then fallback to local
      try {
        await SupabaseService.client
            .from('used_codes')
            .select('code')
            .eq('code', code)
            .single();

        // If we reach here, the code exists (single() would throw if not found)
        throw Exception(AppConstants.codeAlreadyUsedMessage);
      } catch (e) {
        // If Supabase check fails, check locally
        final isUsed = await _storageService.isCodeUsed(code);
        if (isUsed) {
          throw Exception(AppConstants.codeAlreadyUsedMessage);
        }
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Marks a code as used to prevent reuse
  Future<void> markCodeAsUsed(String code) async {
    try {
      // Mark in Supabase
      final supabaseUser = SupabaseService.instance.currentUser;
      if (supabaseUser != null) {
        await SupabaseService.client.from('used_codes').insert({
          'code': code,
          'user_id': supabaseUser.id,
          'used_at': DateTime.now().toIso8601String(),
        });
      }

      // Also mark locally
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
      await SupabaseService.instance.signOut();
      await _storageService.clearStorage();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
