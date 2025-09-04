
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

      // Verificar se o código já foi usado
      final isUsed = await _supabaseNfcRepository.isCodeUsed(userCode);
      if (isUsed) {
        throw Exception('CÓDIGO JÁ UTILIZADO');
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

            // Simular gravação
            await Future.delayed(const Duration(seconds: 1));

            // Marcar código como usado
            await _supabaseNfcRepository.addUsedCode(
              userCode,
              datasetNumber: dataSet,
            );

            // Log successful operation
            await _supabaseNfcRepository.logNfcOperation(
              operationType: NfcOperationType.write,
              codeUsed: userCode,
              datasetNumber: dataSet,
              success: true,
            );

            state = const AsyncValue.data(NfcStatus.success);
            await NfcManager.instance.stopSession();
          } catch (e) {
            await _supabaseNfcRepository.logNfcOperation(
              operationType: NfcOperationType.write,
              codeUsed: userCode,
              datasetNumber: dataSet,
              success: false,
              errorMessage: e.toString(),
            );

            await NfcManager.instance.stopSession(errorMessageIos: e.toString());
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
            await Future.delayed(const Duration(seconds: 1));
            state = const AsyncValue.data(NfcStatus.success);
            await NfcManager.instance.stopSession();
          } catch (e) {
            await NfcManager.instance.stopSession(errorMessageIos: e.toString());
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
            await Future.delayed(const Duration(seconds: 1));
            state = const AsyncValue.data(NfcStatus.success);
            await NfcManager.instance.stopSession();
          } catch (e) {
            await NfcManager.instance.stopSession(errorMessageIos: e.toString());
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
            // Try to read basic tag information using available NFC methods
            final buffer = StringBuffer();
            buffer.writeln('=== DADOS DO CARTÃO NFC ===');
            
            // Try to get NFC-A information
            final nfcA = NfcAAndroid.from(tag);
            if (nfcA != null) {
              buffer.writeln('ID da Tag: ${_formatBytes(nfcA.identifier)}');
              buffer.writeln('ATQA: ${_formatBytes(nfcA.atqa)}');
              buffer.writeln('SAK: ${nfcA.sak}');
              buffer.writeln('Tecnologia: NFC-A');
            }
            
            // Try to get ISO-DEP information (common in credit cards)
            final isoDep = IsoDepAndroid.from(tag);
            if (isoDep != null) {
              buffer.writeln('ISO-DEP suportado: Sim');
              buffer.writeln('Histórico: ${_formatBytes(isoDep.historicalBytes)}');
            }
            
            // Try to get MiFare Classic information  
            final mifareClassic = MifareClassicAndroid.from(tag);
            if (mifareClassic != null) {
              buffer.writeln('Tipo: MiFare Classic');
              buffer.writeln('Tamanho: ${mifareClassic.size} bytes');
              buffer.writeln('Blocos: ${mifareClassic.blockCount}');
            }
            
            buffer.writeln('Data/Hora: ${DateTime.now()}');
            buffer.writeln('=== FIM DOS DADOS ===');

            tagData = {
              'payload': buffer.toString(),
              'type': 'credit_card',
              'readAt': DateTime.now().millisecondsSinceEpoch,
              'hasNfcA': nfcA != null,
              'hasIsoDep': isoDep != null,
              'hasMifareClassic': mifareClassic != null,
            };

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

  /// Helper method to format byte arrays for display
  String _formatBytes(dynamic bytes) {
    if (bytes is List) {
      return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
    }
    return bytes?.toString() ?? 'N/A';
  }
}