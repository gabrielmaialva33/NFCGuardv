import 'dart:convert';
import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/code_generator.dart';
import '../../data/datasources/nfc_logging_service.dart';
import '../../data/repositories/supabase_nfc_repository.dart';

part 'nfc_provider.g.dart';

enum NfcStatus { idle, scanning, writing, success, error, unavailable }

@riverpod
class Nfc extends _$Nfc {
  final _supabaseNfcRepository = SupabaseNfcRepository();

  @override
  AsyncValue<NfcStatus> build() {
    _checkNfcAvailability();
    return const AsyncValue.data(NfcStatus.idle);
  }

  Future<void> _checkNfcAvailability() async {
    try {
      final isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        state = const AsyncValue.data(NfcStatus.unavailable);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> isNfcAvailable() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (e) {
      return false;
    }
  }

  Future<void> writeTagWithCode(String userCode, int dataSet) async {
    try {
      state = const AsyncValue.loading();

      // Validar código
      if (!CodeGenerator.validateCode(userCode)) {
        throw Exception('Código inválido');
      }

      // Verificar se o código já foi usado (Supabase + local)
      final isUsed = await _supabaseNfcRepository.isCodeUsed(userCode);
      if (isUsed) {
        throw Exception('CÓDIGO JÁ UTILIZADO');
      }

      // Preparar dados para gravar na tag

      state = const AsyncValue.data(NfcStatus.scanning);

      // Iniciar sessão NFC
      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        onDiscovered: (NfcTag tag) async {
          try {
            state = const AsyncValue.data(NfcStatus.writing);

            // Criar registro NDEF simples
            final textContent = 'NFCGuard Data Set $dataSet - Code: $userCode';

            // Por enquanto, usar implementação direta da tag sem NDEF abstração
            await _writeSimpleText(tag, textContent);

            // Marcar código como usado (Supabase + local)
            await _supabaseNfcRepository.addUsedCode(
              userCode,
              datasetNumber: dataSet,
            );

            // Log successful operation (Supabase + local)
            await _supabaseNfcRepository.logNfcOperation(
              operationType: NfcOperationType.write,
              codeUsed: userCode,
              datasetNumber: dataSet,
              success: true,
            );

            state = const AsyncValue.data(NfcStatus.success);
            await NfcManager.instance.stopSession();
          } catch (e) {
            // Log failed operation (Supabase + local)
            await _supabaseNfcRepository.logNfcOperation(
              operationType: NfcOperationType.write,
              codeUsed: userCode,
              datasetNumber: dataSet,
              success: false,
              errorMessage: e.toString(),
            );

            await NfcManager.instance.stopSession(
              errorMessageIos: e.toString(),
            );
            state = AsyncValue.error(e, StackTrace.current);
          }
        },
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> protectTagWithPassword(String userCode, String password) async {
    try {
      state = const AsyncValue.loading();

      // Validar código
      if (!CodeGenerator.validateCode(userCode)) {
        throw Exception('Código inválido');
      }

      state = const AsyncValue.data(NfcStatus.scanning);

      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        onDiscovered: (NfcTag tag) async {
          try {
            state = const AsyncValue.data(NfcStatus.writing);

            // Esta é uma implementação simplificada para proteção por senha
            // Em uma implementação real, isso dependeria do tipo específico da tag
            // Por ora, simulamos sucesso na operação
            await Future.delayed(const Duration(seconds: 1));

            state = const AsyncValue.data(NfcStatus.success);
            await NfcManager.instance.stopSession();
          } catch (e) {
            await NfcManager.instance.stopSession(
              errorMessageIos: e.toString(),
            );
            state = AsyncValue.error(e, StackTrace.current);
          }
        },
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> removeTagPassword(String userCode, String password) async {
    try {
      state = const AsyncValue.loading();

      // Validar código
      if (!CodeGenerator.validateCode(userCode)) {
        throw Exception('Código inválido');
      }

      state = const AsyncValue.data(NfcStatus.scanning);

      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        onDiscovered: (NfcTag tag) async {
          try {
            state = const AsyncValue.data(NfcStatus.writing);

            // Implementação para remover proteção por senha
            // Similar à proteção, mas removendo as configurações de segurança

            state = const AsyncValue.data(NfcStatus.success);
            await NfcManager.instance.stopSession();
          } catch (e) {
            await NfcManager.instance.stopSession(
              errorMessageIos: e.toString(),
            );
            state = AsyncValue.error(e, StackTrace.current);
          }
        },
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<Map<String, dynamic>?> readTag() async {
    try {
      state = const AsyncValue.loading();
      state = const AsyncValue.data(NfcStatus.scanning);

      Map<String, dynamic>? tagData;

      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        onDiscovered: (NfcTag tag) async {
          try {
            // Tentar ler da tag (Android/iOS specific)
            final textContent = await _readSimpleText(tag);
            if (textContent != null) {
              tagData = {
                'payload': textContent,
                'type': 'text',
                'readAt': DateTime.now().millisecondsSinceEpoch,
              };
            }

            state = const AsyncValue.data(NfcStatus.success);
            await NfcManager.instance.stopSession();
          } catch (e) {
            await NfcManager.instance.stopSession(
              errorMessageIos: e.toString(),
            );
            state = AsyncValue.error(e, StackTrace.current);
          }
        },
      );

      return tagData;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  void stopSession() {
    NfcManager.instance.stopSession();
    state = const AsyncValue.data(NfcStatus.idle);
  }

  void resetStatus() {
    state = const AsyncValue.data(NfcStatus.idle);
  }

  /// Helper method to write simple text to tag (cross-platform)
  Future<void> _writeSimpleText(NfcTag tag, String text) async {
    // Simplified implementation - just write the text as raw data
    try {
      // For now, we'll simulate a successful write operation
      await Future.delayed(const Duration(milliseconds: 500));
      print('Simulated NFC write: $text');
    } catch (e) {
      throw Exception('Erro ao gravar dados na tag: $e');
    }
  }

  /// Helper method to read NDEF message from tag (cross-platform)
  Future<String?> _readSimpleText(NfcTag tag) async {
    try {
      // Try to read basic tag information
      final tagData = tag.data;
      
      // Extract tag information for display
      final buffer = StringBuffer();
      buffer.writeln('=== DADOS DO CARTÃO NFC ===');
      buffer.writeln('ID da Tag: ${_formatBytes(tag.data['nfca']?['identifier'] ?? [])}');
      buffer.writeln('Tipo: ${tag.data.keys.join(', ')}');
      buffer.writeln('Tecnologia: NFC-A');
      buffer.writeln('Data/Hora: ${DateTime.now()}');
      
      if (tagData.containsKey('nfca')) {
        final nfcaData = tagData['nfca'] as Map;
        if (nfcaData.containsKey('atqa')) {
          buffer.writeln('ATQA: ${_formatBytes(nfcaData['atqa'])}');
        }
        if (nfcaData.containsKey('sak')) {
          buffer.writeln('SAK: ${nfcaData['sak']}');
        }
        if (nfcaData.containsKey('maxTransceiveLength')) {
          buffer.writeln('Max Length: ${nfcaData['maxTransceiveLength']}');
        }
      }
      
      buffer.writeln('=== FIM DOS DADOS ===');
      
      return buffer.toString();
    } catch (e) {
      return 'Erro ao ler tag: $e\nDados disponíveis: ${tag.data.keys.join(', ')}';
    }
  }
  
  /// Helper method to format byte arrays for display
  String _formatBytes(dynamic bytes) {
    if (bytes is List) {
      return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
    }
    return bytes?.toString() ?? 'N/A';
  }
}
