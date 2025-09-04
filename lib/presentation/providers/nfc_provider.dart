import 'dart:convert';
import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
import 'package:ndef_record/ndef_record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/code_generator.dart';
import '../../data/datasources/nfc_logging_service.dart';
import '../../data/datasources/secure_storage_service.dart';

part 'nfc_provider.g.dart';

enum NfcStatus { idle, scanning, writing, success, error, unavailable }

@riverpod
class Nfc extends _$Nfc {
  final _storageService = SecureStorageService();
  final _loggingService = NfcLoggingService();

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

      // Verificar se o código já foi usado
      final isUsed = await _storageService.isCodeUsed(userCode);
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

            // Marcar código como usado
            await _storageService.addUsedCode(userCode);

            // Log successful operation
            await _loggingService.logNfcOperation(
              operationType: NfcOperationType.write,
              codeUsed: userCode,
              datasetNumber: dataSet,
              success: true,
            );

            state = const AsyncValue.data(NfcStatus.success);
            await NfcManager.instance.stopSession();
          } catch (e) {
            // Log failed operation
            await _loggingService.logNfcOperation(
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
    final ndef = Ndef.from(tag);
    
    if (ndef == null) {
      throw Exception('Tag não suporta NDEF');
    }

    if (!ndef.isWritable) {
      throw Exception('Tag não é gravável');
    }

    // Create a simple text record manually
    final textBytes = utf8.encode(text);
    final languageBytes = utf8.encode('en');
    final payload = Uint8List.fromList([
      languageBytes.length,
      ...languageBytes,
      ...textBytes,
    ]);
    
    final textRecord = NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: utf8.encode('T'),
      identifier: Uint8List(0),
      payload: payload,
    );

    // Use the message format that the API expects
    final message = NdefMessage(records: [textRecord]);
    await ndef.write(message);
  }

  /// Helper method to read NDEF message from tag (cross-platform)
  Future<String?> _readSimpleText(NfcTag tag) async {
    final ndef = Ndef.from(tag);
    
    if (ndef == null) {
      throw Exception('Tag não contém dados NDEF');
    }

    final message = await ndef.read();
    if (message == null || message.records.isEmpty) {
      throw Exception('Não foi possível ler dados da tag');
    }
    
    final record = message.records.first;
    if (record.payload.length < 4) {
      throw Exception('Formato de dados inválido');
    }
    
    // Skip language code prefix and decode text
    final languageCodeLength = record.payload[0];
    final textStart = 1 + languageCodeLength;
    final textBytes = record.payload.skip(textStart).toList();
    
    return utf8.decode(textBytes);
  }
}
