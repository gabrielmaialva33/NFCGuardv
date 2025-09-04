import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_guard/data/datasources/nfc_logging_service.dart';

void main() {
  late NfcLoggingService service;

  setUp(() {
    service = NfcLoggingService();
  });

  group('NfcLoggingService', () {
    group('NfcOperationType enum', () {
      test('should have correct string values', () {
        expect(NfcOperationType.write.name, equals('write'));
        expect(NfcOperationType.protect.name, equals('protect'));
        expect(NfcOperationType.unprotect.name, equals('unprotect'));
      });

      test('should contain all expected operation types', () {
        final operationTypes = NfcOperationType.values;
        expect(operationTypes.length, equals(3));
        expect(operationTypes, contains(NfcOperationType.write));
        expect(operationTypes, contains(NfcOperationType.protect));
        expect(operationTypes, contains(NfcOperationType.unprotect));
      });
    });

    group('Service instantiation', () {
      test('should create service instance without throwing', () {
        expect(() => NfcLoggingService(), returnsNormally);
      });

      test('should create multiple instances independently', () {
        final service1 = NfcLoggingService();
        final service2 = NfcLoggingService();

        expect(service1, isA<NfcLoggingService>());
        expect(service2, isA<NfcLoggingService>());
        expect(service1, isNot(same(service2)));
      });
    });

    group('Method signatures', () {
      test('logNfcOperation should accept all required parameters', () {
        expect(() async {
          await service.logNfcOperation(
            operationType: NfcOperationType.write,
            codeUsed: '12345678',
            datasetNumber: 1,
            success: true,
          );
        }, returnsNormally);
      });

      test('logNfcOperation should accept optional parameters', () {
        expect(() async {
          await service.logNfcOperation(
            operationType: NfcOperationType.write,
            codeUsed: '12345678',
            success: false,
            errorMessage: 'Test error',
          );
        }, returnsNormally);
      });

      test('getNfcOperationHistory should accept optional parameters', () {
        expect(() async {
          await service.getNfcOperationHistory(
            limit: 10,
            since: DateTime.now(),
          );
        }, returnsNormally);
      });

      test('getOperationStatistics should be callable', () {
        expect(() async {
          await service.getOperationStatistics();
        }, returnsNormally);
      });
    });
  });
}
