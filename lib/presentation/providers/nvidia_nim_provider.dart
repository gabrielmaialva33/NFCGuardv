import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/services/nvidia_nim_service.dart';

part 'nvidia_nim_provider.g.dart';

@riverpod
NvidiaNimService nvidiaNimService(Ref ref) {
  return NvidiaNimService();
}

@riverpod
class NvidiaNimState extends _$NvidiaNimState {
  @override
  AsyncValue<String> build() {
    return const AsyncValue.data('');
  }

  Future<void> generateResponse(String prompt) async {
    state = const AsyncValue.loading();
    
    try {
      final service = ref.read(nvidiaNimServiceProvider);
      final response = await service.generateResponse(prompt: prompt);
      state = AsyncValue.data(response);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> analyzeSecurityCode(String code) async {
    state = const AsyncValue.loading();
    
    try {
      final service = ref.read(nvidiaNimServiceProvider);
      final analysis = await service.analyzeSecurityCode(code);
      state = AsyncValue.data(analysis);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> generateSecureCode({
    required int length,
    bool includeNumbers = true,
    bool includeLetters = true,
    bool includeSymbols = false,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final service = ref.read(nvidiaNimServiceProvider);
      final code = await service.generateSecureCode(
        length: length,
        includeNumbers: includeNumbers,
        includeLetters: includeLetters,
        includeSymbols: includeSymbols,
      );
      state = AsyncValue.data(code);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void reset() {
    state = const AsyncValue.data('');
  }
}

@riverpod
class CpfValidationState extends _$CpfValidationState {
  @override
  AsyncValue<Map<String, dynamic>?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> validateCpfWithFraud(String cpf) async {
    state = const AsyncValue.loading();
    
    try {
      final service = ref.read(nvidiaNimServiceProvider);
      final result = await service.validateCpfWithFraudDetection(cpf);
      state = AsyncValue.data(result);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}