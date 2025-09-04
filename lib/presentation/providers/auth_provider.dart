import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:search_cep/search_cep.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/code_generator.dart';
import '../../data/datasources/secure_storage_service.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  final _storageService = SecureStorageService();

  @override
  AsyncValue<UserEntity?> build() {
    _loadUser();
    return const AsyncValue.loading();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _storageService.getUser();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
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

      // Basic validations for now
      if (cpf.length < 11) {
        throw Exception(AppConstants.invalidCpfMessage);
      }

      if (!email.contains('@')) {
        throw Exception('Email inválido');
      }

      // Generate unique 8-digit code
      String eightDigitCode = CodeGenerator.generateUniqueCode();

      // Create user with basic data (without address yet)
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: fullName,
        cpf: cpf.replaceAll(RegExp(r'[^0-9]'), ''),
        email: email,
        phone: phone,
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

      await _storageService.saveUser(user);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
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
      await _storageService.clearStorage();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
