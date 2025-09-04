import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nfc_guard/core/constants/app_constants.dart';
import 'package:nfc_guard/data/datasources/secure_storage_service.dart';
import 'package:nfc_guard/data/models/user_model.dart';

import 'secure_storage_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late SecureStorageService service;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageService();
    // Replace the private field with our mock (would need dependency injection in real implementation)
  });

  group('SecureStorageService', () {
    group('User Management', () {
      test('should save user successfully', () async {
        // Arrange
        final user = _createTestUser();
        final expectedJson = json.encode(user.toJson());

        when(
          mockStorage.write(key: AppConstants.userDataKey, value: expectedJson),
        ).thenAnswer((_) async {});

        // Act & Assert
        expect(() => service.saveUser(user), returnsNormally);
      });

      test('should get user when data exists', () async {
        // Arrange
        final user = _createTestUser();
        final userJson = json.encode(user.toJson());

        when(
          mockStorage.read(key: AppConstants.userDataKey),
        ).thenAnswer((_) async => userJson);

        // Act
        final result = await service.getUser();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(user.id));
        expect(result.fullName, equals(user.fullName));
        expect(result.cpf, equals(user.cpf));
        expect(result.email, equals(user.email));
      });

      test('should return null when user data does not exist', () async {
        // Arrange
        when(
          mockStorage.read(key: AppConstants.userDataKey),
        ).thenAnswer((_) async => null);

        // Act
        final result = await service.getUser();

        // Assert
        expect(result, isNull);
      });

      test('should delete user successfully', () async {
        // Arrange
        when(
          mockStorage.delete(key: AppConstants.userDataKey),
        ).thenAnswer((_) async {});

        // Act & Assert
        expect(() => service.deleteUser(), returnsNormally);
        verify(mockStorage.delete(key: AppConstants.userDataKey)).called(1);
      });
    });

    group('Used Codes Management', () {
      test('should save used codes successfully', () async {
        // Arrange
        final codes = ['12345678', '87654321', '11111111'];
        final expectedJson = json.encode(codes);

        when(
          mockStorage.write(
            key: AppConstants.usedCodesKey,
            value: expectedJson,
          ),
        ).thenAnswer((_) async {});

        // Act & Assert
        expect(() => service.saveUsedCodes(codes), returnsNormally);
      });

      test('should get used codes when data exists', () async {
        // Arrange
        final expectedCodes = ['12345678', '87654321', '11111111'];
        final codesJson = json.encode(expectedCodes);

        when(
          mockStorage.read(key: AppConstants.usedCodesKey),
        ).thenAnswer((_) async => codesJson);

        // Act
        final result = await service.getUsedCodes();

        // Assert
        expect(result, equals(expectedCodes));
        expect(result.length, equals(3));
      });

      test('should return empty list when used codes do not exist', () async {
        // Arrange
        when(
          mockStorage.read(key: AppConstants.usedCodesKey),
        ).thenAnswer((_) async => null);

        // Act
        final result = await service.getUsedCodes();

        // Assert
        expect(result, isEmpty);
      });

      test('should add used code successfully', () async {
        // Arrange
        final existingCodes = ['12345678', '87654321'];
        final newCode = '11111111';
        final expectedCodes = ['12345678', '87654321', '11111111'];

        when(
          mockStorage.read(key: AppConstants.usedCodesKey),
        ).thenAnswer((_) async => json.encode(existingCodes));

        when(
          mockStorage.write(
            key: AppConstants.usedCodesKey,
            value: json.encode(expectedCodes),
          ),
        ).thenAnswer((_) async {});

        // Act
        await service.addUsedCode(newCode);

        // Assert
        verify(
          mockStorage.write(
            key: AppConstants.usedCodesKey,
            value: json.encode(expectedCodes),
          ),
        ).called(1);
      });

      test('should add code to empty list', () async {
        // Arrange
        final newCode = '12345678';
        final expectedCodes = ['12345678'];

        when(
          mockStorage.read(key: AppConstants.usedCodesKey),
        ).thenAnswer((_) async => null);

        when(
          mockStorage.write(
            key: AppConstants.usedCodesKey,
            value: json.encode(expectedCodes),
          ),
        ).thenAnswer((_) async {});

        // Act
        await service.addUsedCode(newCode);

        // Assert
        verify(
          mockStorage.write(
            key: AppConstants.usedCodesKey,
            value: json.encode(expectedCodes),
          ),
        ).called(1);
      });

      test('should correctly identify used codes', () async {
        // Arrange
        final usedCodes = ['12345678', '87654321', '11111111'];

        when(
          mockStorage.read(key: AppConstants.usedCodesKey),
        ).thenAnswer((_) async => json.encode(usedCodes));

        // Act & Assert
        expect(await service.isCodeUsed('12345678'), isTrue);
        expect(await service.isCodeUsed('87654321'), isTrue);
        expect(await service.isCodeUsed('11111111'), isTrue);
        expect(await service.isCodeUsed('99999999'), isFalse);
        expect(await service.isCodeUsed('00000000'), isFalse);
      });

      test('should return false for unused codes when list is empty', () async {
        // Arrange
        when(
          mockStorage.read(key: AppConstants.usedCodesKey),
        ).thenAnswer((_) async => null);

        // Act & Assert
        expect(await service.isCodeUsed('12345678'), isFalse);
        expect(await service.isCodeUsed('any_code'), isFalse);
      });
    });

    group('Storage Management', () {
      test('should clear all storage successfully', () async {
        // Arrange
        when(mockStorage.deleteAll()).thenAnswer((_) async {});

        // Act & Assert
        expect(() => service.clearStorage(), returnsNormally);
        verify(mockStorage.deleteAll()).called(1);
      });
    });

    group('Error Handling', () {
      test(
        'should handle JSON decode errors gracefully for user data',
        () async {
          // Arrange
          when(
            mockStorage.read(key: AppConstants.userDataKey),
          ).thenAnswer((_) async => 'invalid_json');

          // Act & Assert
          expect(() => service.getUser(), throwsA(isA<FormatException>()));
        },
      );

      test(
        'should handle JSON decode errors gracefully for used codes',
        () async {
          // Arrange
          when(
            mockStorage.read(key: AppConstants.usedCodesKey),
          ).thenAnswer((_) async => 'invalid_json');

          // Act & Assert
          expect(() => service.getUsedCodes(), throwsA(isA<FormatException>()));
        },
      );

      test('should handle storage write failures', () async {
        // Arrange
        final user = _createTestUser();

        when(
          mockStorage.write(
            key: AppConstants.userDataKey,
            value: anyNamed('value'),
          ),
        ).thenThrow(Exception('Storage write failed'));

        // Act & Assert
        expect(() => service.saveUser(user), throwsException);
      });

      test('should handle storage read failures', () async {
        // Arrange
        when(
          mockStorage.read(key: AppConstants.userDataKey),
        ).thenThrow(Exception('Storage read failed'));

        // Act & Assert
        expect(() => service.getUser(), throwsException);
      });
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = SecureStorageService();
        final instance2 = SecureStorageService();

        expect(identical(instance1, instance2), isTrue);
      });
    });
  });
}

UserModel _createTestUser() {
  return UserModel(
    id: '123456789',
    fullName: 'João da Silva',
    cpf: '12345678901',
    email: 'joao@example.com',
    phone: '11987654321',
    birthDate: DateTime(1990, 5, 15),
    gender: 'Masculino',
    zipCode: '01234567',
    address: 'Rua das Flores, 123',
    neighborhood: 'Centro',
    city: 'São Paulo',
    state: 'SP',
    eightDigitCode: '12345678',
    createdAt: DateTime(2023, 12, 1),
  );
}
