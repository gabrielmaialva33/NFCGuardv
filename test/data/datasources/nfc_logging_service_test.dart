import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nfc_guard/data/datasources/nfc_logging_service.dart';
import 'package:nfc_guard/data/datasources/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'nfc_logging_service_test.mocks.dart';

@GenerateMocks([SupabaseService])
void main() {
  late NfcLoggingService service;
  late MockSupabaseService mockSupabaseService;
  late MockUser mockUser;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockSupabaseFilterBuilder mockFilterBuilder;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    mockUser = MockUser();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockSupabaseFilterBuilder();

    // Initialize service with mocked dependencies
    service = NfcLoggingService();
  });

  group('NfcLoggingService', () {
    group('logNfcOperation', () {
      test('should log successful NFC write operation', () async {
        // Arrange
        when(mockSupabaseService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user-123');
        when(
          mockSupabaseService.from('nfc_operations'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenAnswer((_) async => {});

        // Act
        await service.logNfcOperation(
          operationType: NfcOperationType.write,
          codeUsed: '12345678',
          datasetNumber: 1,
          success: true,
        );

        // Assert
        verify(mockSupabaseService.from('nfc_operations')).called(1);
        verify(
          mockQueryBuilder.insert({
            'user_id': 'user-123',
            'operation_type': 'write',
            'code_used': '12345678',
            'dataset_number': 1,
            'success': true,
            'error_message': null,
          }),
        ).called(1);
      });

      test('should log failed NFC operation with error message', () async {
        // Arrange
        when(mockSupabaseService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user-123');
        when(
          mockSupabaseService.from('nfc_operations'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenAnswer((_) async => {});

        // Act
        await service.logNfcOperation(
          operationType: NfcOperationType.protect,
          codeUsed: '87654321',
          success: false,
          errorMessage: 'Tag not writable',
        );

        // Assert
        verify(
          mockQueryBuilder.insert({
            'user_id': 'user-123',
            'operation_type': 'protect',
            'code_used': '87654321',
            'dataset_number': null,
            'success': false,
            'error_message': 'Tag not writable',
          }),
        ).called(1);
      });

      test('should not log when user is not authenticated', () async {
        // Arrange
        when(mockSupabaseService.currentUser).thenReturn(null);

        // Act
        await service.logNfcOperation(
          operationType: NfcOperationType.write,
          codeUsed: '12345678',
          success: true,
        );

        // Assert
        verifyNever(mockSupabaseService.from(any));
      });

      test('should handle logging errors gracefully', () async {
        // Arrange
        when(mockSupabaseService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user-123');
        when(
          mockSupabaseService.from('nfc_operations'),
        ).thenReturn(mockQueryBuilder);
        when(
          mockQueryBuilder.insert(any),
        ).thenThrow(Exception('Network error'));

        // Act & Assert - should not throw
        await service.logNfcOperation(
          operationType: NfcOperationType.write,
          codeUsed: '12345678',
          success: true,
        );
      });

      test('should log different operation types correctly', () async {
        // Arrange
        when(mockSupabaseService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user-123');
        when(
          mockSupabaseService.from('nfc_operations'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenAnswer((_) async => {});

        // Act & Assert
        for (final opType in NfcOperationType.values) {
          await service.logNfcOperation(
            operationType: opType,
            codeUsed: '12345678',
            success: true,
          );

          verify(
            mockQueryBuilder.insert({
              'user_id': 'user-123',
              'operation_type': opType.name,
              'code_used': '12345678',
              'dataset_number': null,
              'success': true,
              'error_message': null,
            }),
          ).called(1);
        }
      });
    });

    group('getNfcOperationHistory', () {
      test('should return operation history for authenticated user', () async {
        // Arrange
        final expectedData = [
          {
            'id': '1',
            'user_id': 'user-123',
            'operation_type': 'write',
            'code_used': '12345678',
            'success': true,
            'created_at': '2023-12-01T10:00:00Z',
          },
          {
            'id': '2',
            'user_id': 'user-123',
            'operation_type': 'protect',
            'code_used': '87654321',
            'success': false,
            'created_at': '2023-12-01T11:00:00Z',
          },
        ];

        when(mockSupabaseService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user-123');
        when(
          mockSupabaseService.from('nfc_operations'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('*')).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('user_id', 'user-123'),
        ).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.order('created_at', ascending: false),
        ).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(50)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder).thenAnswer((_) async => expectedData);

        // Act
        final result = await service.getNfcOperationHistory();

        // Assert
        expect(result, equals(expectedData));
        expect(result.length, equals(2));
      });

      test('should apply date filter when provided', () async {
        // Arrange
        final since = DateTime(2023, 12, 1);
        when(mockSupabaseService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user-123');
        when(
          mockSupabaseService.from('nfc_operations'),
        ).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select('*')).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('user_id', 'user-123'),
        ).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.order('created_at', ascending: false),
        ).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(25)).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.filter(
            'created_at',
            'gte',
            since.toIso8601String(),
          ),
        ).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder).thenAnswer((_) async => []);

        // Act
        await service.getNfcOperationHistory(limit: 25, since: since);

        // Assert
        verify(
          mockFilterBuilder.filter(
            'created_at',
            'gte',
            since.toIso8601String(),
          ),
        ).called(1);
      });

      test('should return empty list when user not authenticated', () async {
        // Arrange
        when(mockSupabaseService.currentUser).thenReturn(null);

        // Act
        final result = await service.getNfcOperationHistory();

        // Assert
        expect(result, isEmpty);
        verifyNever(mockSupabaseService.from(any));
      });

      test('should handle query errors gracefully', () async {
        // Arrange
        when(mockSupabaseService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user-123');
        when(
          mockSupabaseService.from('nfc_operations'),
        ).thenThrow(Exception('Database error'));

        // Act
        final result = await service.getNfcOperationHistory();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getOperationStatistics', () {
      test('should calculate statistics correctly', () async {
        // Arrange
        final operationsData = [
          {'operation_type': 'write', 'success': true},
          {'operation_type': 'write', 'success': false},
          {'operation_type': 'write', 'success': true},
          {'operation_type': 'protect', 'success': true},
          {'operation_type': 'protect', 'success': false},
          {'operation_type': 'unprotect', 'success': true},
        ];

        when(mockSupabaseService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user-123');
        when(
          mockSupabaseService.from('nfc_operations'),
        ).thenReturn(mockQueryBuilder);
        when(
          mockQueryBuilder.select('operation_type, success'),
        ).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('user_id', 'user-123'),
        ).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder).thenAnswer((_) async => operationsData);

        // Act
        final result = await service.getOperationStatistics();

        // Assert
        expect(result['total_operations'], equals(6));
        expect(result['successful_operations'], equals(4));
        expect(result['total_write'], equals(3));
        expect(result['success_write'], equals(2));
        expect(result['total_protect'], equals(2));
        expect(result['success_protect'], equals(1));
        expect(result['total_unprotect'], equals(1));
        expect(result['success_unprotect'], equals(1));
      });

      test('should return empty stats when user not authenticated', () async {
        // Arrange
        when(mockSupabaseService.currentUser).thenReturn(null);

        // Act
        final result = await service.getOperationStatistics();

        // Assert
        expect(result, isEmpty);
      });

      test('should handle no operations data', () async {
        // Arrange
        when(mockSupabaseService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user-123');
        when(
          mockSupabaseService.from('nfc_operations'),
        ).thenReturn(mockQueryBuilder);
        when(
          mockQueryBuilder.select('operation_type, success'),
        ).thenReturn(mockFilterBuilder);
        when(
          mockFilterBuilder.eq('user_id', 'user-123'),
        ).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder).thenAnswer((_) async => []);

        // Act
        final result = await service.getOperationStatistics();

        // Assert
        expect(result['total_operations'], equals(0));
        expect(result['successful_operations'], equals(0));
      });

      test('should handle database errors gracefully', () async {
        // Arrange
        when(mockSupabaseService.currentUser).thenReturn(mockUser);
        when(mockUser.id).thenReturn('user-123');
        when(
          mockSupabaseService.from('nfc_operations'),
        ).thenThrow(Exception('Database connection failed'));

        // Act
        final result = await service.getOperationStatistics();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('Operation Types', () {
      test('should handle all NfcOperationType enum values', () {
        expect(NfcOperationType.write.name, equals('write'));
        expect(NfcOperationType.protect.name, equals('protect'));
        expect(NfcOperationType.unprotect.name, equals('unprotect'));
      });
    });
  });
}
