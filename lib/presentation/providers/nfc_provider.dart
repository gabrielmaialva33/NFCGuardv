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
            // Try to read basic tag information
            final data = tag.data as Map<String, dynamic>;
            
            // Extract tag information for display
            final buffer = StringBuffer();
            buffer.writeln('=== DADOS DO CARTÃO NFC ===');
            if (data.containsKey('nfca')) {
              final nfcaData = data['nfca'] as Map<String, dynamic>;
              buffer.writeln('ID da Tag: ${_formatBytes(nfcaData['identifier'] ?? [])}');
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
            buffer.writeln('Tipo: ${data.keys.join(', ')}');
            buffer.writeln('Tecnologia: NFC');
            buffer.writeln('Data/Hora: ${DateTime.now()}');
            buffer.writeln('=== FIM DOS DADOS ===');

            tagData = {
              'payload': buffer.toString(),
              'type': 'credit_card',
              'readAt': DateTime.now().millisecondsSinceEpoch,
              'rawData': data,
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