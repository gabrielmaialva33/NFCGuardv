import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:all_validations_br/all_validations_br.dart';
import 'package:search_cep/search_cep.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/models/user_model.dart';
import '../../data/datasources/secure_storage_service.dart';
import '../../core/utils/code_generator.dart';
import '../../core/constants/app_constants.dart';

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

  Future<void> register({
    required String nomeCompleto,
    required String cpf,
    required String email,
    required String telefone,
    required DateTime dataNascimento,
    required String sexo,
    required String senha,
  }) async {
    try {
      state = const AsyncValue.loading();

      // Validações
      if (!AllValidationsBr.isCpf(cpf)) {
        throw Exception(AppConstants.invalidCpfMessage);
      }

      if (!AllValidationsBr.isEmail(email)) {
        throw Exception('Email inválido');
      }

      // Gerar código único de 8 dígitos
      String codigo8Digitos = CodeGenerator.generateUniqueCode();

      // Criar usuário com dados básicos (sem endereço ainda)
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nomeCompleto: nomeCompleto,
        cpf: cpf.replaceAll(RegExp(r'[^0-9]'), ''),
        email: email,
        telefone: telefone,
        dataNascimento: dataNascimento,
        sexo: sexo,
        cep: '',
        endereco: '',
        bairro: '',
        cidade: '',
        uf: '',
        codigo8Digitos: codigo8Digitos,
        createdAt: DateTime.now(),
      );

      await _storageService.saveUser(user);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateAddress({
    required String cep,
    required String endereco,
    required String bairro,
    required String cidade,
    required String uf,
  }) async {
    try {
      final currentUser = state.value;
      if (currentUser == null) throw Exception('Usuário não encontrado');

      final updatedUser = currentUser.copyWith(
        cep: cep,
        endereco: endereco,
        bairro: bairro,
        cidade: cidade,
        uf: uf,
      );

      await _storageService.saveUser(UserModel.fromEntity(updatedUser));
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<Map<String, String>?> searchCep(String cep) async {
    try {
      final viaCepSearchCep = ViaCepSearchCep();
      final result = await viaCepSearchCep.searchInfoByCep(cep: cep);

      return result.fold(
        (error) => null,
        (infoCep) => {
          'endereco': infoCep.logradouro ?? '',
          'bairro': infoCep.bairro ?? '',
          'cidade': infoCep.localidade ?? '',
          'uf': infoCep.uf ?? '',
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar CEP: $e');
      }
      return null;
    }
  }

  Future<bool> validateCodeForUse(String code) async {
    try {
      // Validar formato do código
      if (!CodeGenerator.validateCode(code)) {
        throw Exception(AppConstants.invalidCodeMessage);
      }

      // Verificar se o código já foi usado
      final isUsed = await _storageService.isCodeUsed(code);
      if (isUsed) {
        throw Exception(AppConstants.codeAlreadyUsedMessage);
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markCodeAsUsed(String code) async {
    try {
      await _storageService.addUsedCode(code);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao marcar código como usado: $e');
      }
    }
  }

  Future<void> logout() async {
    try {
      await _storageService.clearStorage();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}