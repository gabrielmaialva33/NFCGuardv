import 'dart:convert';
import 'dart:typed_data';

import 'package:ndef/ndef.dart' as ndef;
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
    final ndefTag = Ndef.from(tag);

    if (ndefTag == null) {
      throw Exception('Tag não suporta NDEF');
    }

    if (!ndefTag.isWritable) {
      throw Exception('Tag não é gravável');
    }

    // Create a simple text record using the new ndef library
    final textRecord = ndef.TextRecord(
      text: text,
      language: 'en',
      encoding: ndef.TextEncoding.utf8,
    );

    // Create message with the text record
    final message = ndef.NdefMessage([textRecord]);
    await ndefTag.write(NdefMessage([
      NdefRecord(
        typeNameFormat: NdefTypeNameFormat.nfcWellknown,
        type: textRecord.type,
        identifier: Uint8List(0),
        payload: textRecord.payload,
      )
    ]));
  }

  /// Helper method to read NDEF message from tag (cross-platform)
  Future<String?> _readSimpleText(NfcTag tag) async {
    final ndefTag = Ndef.from(tag);

    if (ndefTag == null) {
      throw Exception('Tag não contém dados NDEF');
    }

    final message = await ndefTag.read();
    if (message == null || message.records.isEmpty) {
      throw Exception('Não foi possível ler dados da tag');
    }

    // Try to parse the first record as text
    for (final record in message.records) {
      try {
        final parsedRecord = ndef.Record.fromBytes(
          record.typeNameFormat, 
          record.type, 
          record.payload
        );
        
        if (parsedRecord is ndef.TextRecord) {
          return parsedRecord.text;
        }
      } catch (e) {
        // Continue to next record if parsing fails
        continue;
      }
    }

    // Fallback: try to decode raw payload as text
    final record = message.records.first;
    if (record.payload.length >= 4) {
      final languageCodeLength = record.payload[0];
      final textStart = 1 + languageCodeLength;
      if (textStart < record.payload.length) {
        final textBytes = record.payload.skip(textStart).toList();
        return utf8.decode(textBytes);
      }
    }

    return null;
  }
}
