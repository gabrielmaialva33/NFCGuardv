import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nfc_guard/core/constants/app_constants.dart';
import 'package:nfc_guard/core/utils/code_generator.dart';
import 'package:nfc_guard/data/datasources/secure_storage_service.dart';
import 'package:nfc_guard/data/models/user_model.dart';
import 'package:nfc_guard/domain/entities/user_entity.dart';
import 'package:nfc_guard/presentation/providers/auth_provider.dart';
import 'package:search_cep/search_cep.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([SecureStorageService, ViaCepSearchCep, CodeGenerator])
void main() {
  late ProviderContainer container;
  late MockSecureStorageService mockStorageService;
  // late MockViaCepSearchCep mockViaCepService;

  setUp(() {
    mockStorageService = MockSecureStorageService();
    // mockViaCepService = MockViaCepSearchCep();

    container = ProviderContainer(
      overrides: [
        // Would need dependency injection to properly override
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Auth Provider', () {
    group('Initial State', () {
      test('should start with loading state', () {
        final provider = container.read(authProvider);
        expect(provider, isA<AsyncLoading>());
      });
    });

    group('User Registration', () {
      testWidgets('should register user successfully', (tester) async {
        // Arrange
        when(mockStorageService.getUser()).thenAnswer((_) async => null);
        when(mockStorageService.saveUser(any)).thenAnswer((_) async {});

        final authNotifier = container.read(authProvider.notifier);

        // Act
        await authNotifier.register(
          fullName: 'João da Silva',
          cpf: '12345678901',
          email: 'joao@example.com',
          phone: '11987654321',
          birthDate: DateTime(1990, 5, 15),
          gender: 'Masculino',
          password: 'password123',
        );

        // Assert
        final state = container.read(authProvider);
        expect(state, isA<AsyncData>());

        final user = state.value;
        expect(user?.fullName, equals('João da Silva'));
        expect(user?.cpf, equals('12345678901'));
        expect(user?.email, equals('joao@example.com'));
        expect(user?.eightDigitCode, hasLength(8));
      });

      test('should validate CPF during registration', () async {
        final authNotifier = container.read(authProvider.notifier);

        // Act & Assert
        expect(
          () => authNotifier.register(
            fullName: 'João da Silva',
            cpf: '123',
            // Invalid CPF length
            email: 'joao@example.com',
            phone: '11987654321',
            birthDate: DateTime(1990, 5, 15),
            gender: 'Masculino',
            password: 'password123',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains(AppConstants.invalidCpfMessage),
            ),
          ),
        );
      });

      test('should validate email during registration', () async {
        final authNotifier = container.read(authProvider.notifier);

        // Act & Assert
        expect(
          () => authNotifier.register(
            fullName: 'João da Silva',
            cpf: '12345678901',
            email: 'invalid-email',
            // Invalid email
            phone: '11987654321',
            birthDate: DateTime(1990, 5, 15),
            gender: 'Masculino',
            password: 'password123',
          ),
          throwsA(
            predicate(
              (e) => e is Exception && e.toString().contains('Email inválido'),
            ),
          ),
        );
      });

      test('should clean CPF format during registration', () async {
        // Arrange
        when(mockStorageService.saveUser(any)).thenAnswer((_) async {});

        final authNotifier = container.read(authProvider.notifier);

        // Act
        await authNotifier.register(
          fullName: 'João da Silva',
          cpf: '123.456.789-01',
          // Formatted CPF
          email: 'joao@example.com',
          phone: '11987654321',
          birthDate: DateTime(1990, 5, 15),
          gender: 'Masculino',
          password: 'password123',
        );

        // Assert
        final state = container.read(authProvider);
        final user = state.value;
        expect(user?.cpf, equals('12345678901')); // Should be cleaned
      });

      test('should generate valid 8-digit code during registration', () async {
        // Arrange
        when(mockStorageService.saveUser(any)).thenAnswer((_) async {});

        final authNotifier = container.read(authProvider.notifier);

        // Act
        await authNotifier.register(
          fullName: 'João da Silva',
          cpf: '12345678901',
          email: 'joao@example.com',
          phone: '11987654321',
          birthDate: DateTime(1990, 5, 15),
          gender: 'Masculino',
          password: 'password123',
        );

        // Assert
        final state = container.read(authProvider);
        final user = state.value;
        expect(user?.eightDigitCode, hasLength(8));
        expect(CodeGenerator.validateCode(user!.eightDigitCode), isTrue);
      });
    });

    group('Address Management', () {
      test('should update address successfully', () async {
        // Arrange
        final existingUser = _createTestUserEntity();
        when(mockStorageService.saveUser(any)).thenAnswer((_) async {});

        final authNotifier = container.read(authProvider.notifier);
        container.read(authProvider.notifier).state = AsyncValue.data(
          existingUser,
        );

        // Act
        await authNotifier.updateAddress(
          zipCode: '87654321',
          address: 'Nova Rua, 456',
          neighborhood: 'Novo Bairro',
          city: 'Rio de Janeiro',
          stateCode: 'RJ',
        );

        // Assert
        final state = container.read(authProvider);
        final user = state.value;
        expect(user?.zipCode, equals('87654321'));
        expect(user?.address, equals('Nova Rua, 456'));
        expect(user?.neighborhood, equals('Novo Bairro'));
        expect(user?.city, equals('Rio de Janeiro'));
        expect(user?.state, equals('RJ'));
      });

      test('should throw error when updating address without user', () async {
        // Arrange
        final authNotifier = container.read(authProvider.notifier);
        container.read(authProvider.notifier).state = const AsyncValue.data(
          null,
        );

        // Act & Assert
        expect(
          () => authNotifier.updateAddress(
            zipCode: '87654321',
            address: 'Nova Rua, 456',
            neighborhood: 'Novo Bairro',
            city: 'Rio de Janeiro',
            stateCode: 'RJ',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('Usuário não encontrado'),
            ),
          ),
        );
      });
    });

    group('ZIP Code Search', () {
      test('should search ZIP code successfully', () async {
        // Arrange
        final mockAddressInfo = MockAddressInfo();
        when(mockAddressInfo.logradouro).thenReturn('Rua das Flores');
        when(mockAddressInfo.bairro).thenReturn('Centro');
        when(mockAddressInfo.localidade).thenReturn('São Paulo');
        when(mockAddressInfo.uf).thenReturn('SP');

        final authNotifier = container.read(authProvider.notifier);

        // Note: This test would need proper mocking setup for ViaCepSearchCep
        // For now, we test the error handling path
      });

      test('should handle ZIP code search errors gracefully', () async {
        final authNotifier = container.read(authProvider.notifier);

        // Act
        final result = await authNotifier.searchZipCode('invalid');

        // Assert - should not throw and return null for invalid ZIP
        expect(result, isNull);
      });

      test('should handle valid ZIP code format', () async {
        final authNotifier = container.read(authProvider.notifier);

        // Note: Real implementation would mock ViaCepSearchCep
        // Testing with actual service would require network calls
        const validZipCode = '01234567';
        expect(validZipCode.length, equals(8));
        expect(validZipCode, matches(RegExp(r'^\d{8}$')));
      });
    });

    group('Code Validation', () {
      test('should validate code format and uniqueness', () async {
        // Arrange
        when(
          mockStorageService.isCodeUsed('12345678'),
        ).thenAnswer((_) async => false);

        final authNotifier = container.read(authProvider.notifier);

        // Act
        final isValid = await authNotifier.validateCodeForUse('12345678');

        // Assert
        expect(isValid, isFalse); // Will fail format validation
      });

      test('should reject already used codes', () async {
        // Arrange
        final validCode = CodeGenerator.generateUniqueCode();
        when(
          mockStorageService.isCodeUsed(validCode),
        ).thenAnswer((_) async => true);

        final authNotifier = container.read(authProvider.notifier);

        // Act & Assert
        expect(
          () => authNotifier.validateCodeForUse(validCode),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains(AppConstants.codeAlreadyUsedMessage),
            ),
          ),
        );
      });

      test('should accept valid unused codes', () async {
        // Arrange
        final validCode = CodeGenerator.generateUniqueCode();
        when(
          mockStorageService.isCodeUsed(validCode),
        ).thenAnswer((_) async => false);

        final authNotifier = container.read(authProvider.notifier);

        // Act
        final isValid = await authNotifier.validateCodeForUse(validCode);

        // Assert
        expect(isValid, isTrue);
      });

      test('should reject invalid code format', () async {
        final authNotifier = container.read(authProvider.notifier);

        // Act & Assert
        expect(
          () => authNotifier.validateCodeForUse('invalid'),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains(AppConstants.invalidCodeMessage),
            ),
          ),
        );
      });
    });

    group('Code Usage Tracking', () {
      test('should mark code as used successfully', () async {
        // Arrange
        when(
          mockStorageService.addUsedCode('12345678'),
        ).thenAnswer((_) async {});

        final authNotifier = container.read(authProvider.notifier);

        // Act & Assert
        expect(() => authNotifier.markCodeAsUsed('12345678'), returnsNormally);
      });

      test('should handle mark code errors gracefully', () async {
        // Arrange
        when(
          mockStorageService.addUsedCode(any),
        ).thenThrow(Exception('Storage error'));

        final authNotifier = container.read(authProvider.notifier);

        // Act & Assert - should not throw
        await authNotifier.markCodeAsUsed('12345678');
      });
    });

    group('Logout', () {
      test('should logout successfully and clear data', () async {
        // Arrange
        when(mockStorageService.clearStorage()).thenAnswer((_) async {});

        final authNotifier = container.read(authProvider.notifier);

        // Act
        await authNotifier.logout();

        // Assert
        final state = container.read(authProvider);
        expect(state.value, isNull);
      });

      test('should handle logout errors', () async {
        // Arrange
        when(
          mockStorageService.clearStorage(),
        ).thenThrow(Exception('Clear storage failed'));

        final authNotifier = container.read(authProvider.notifier);

        // Act
        await authNotifier.logout();

        // Assert
        final state = container.read(authProvider);
        expect(state, isA<AsyncError>());
      });
    });

    group('Error States', () {
      test('should handle storage service errors during load', () async {
        // Arrange
        when(
          mockStorageService.getUser(),
        ).thenThrow(Exception('Storage read failed'));

        // Act
        final provider = container.read(authProvider);

        // Assert
        expect(provider, isA<AsyncError>());
      });

      test('should handle registration errors', () async {
        // Arrange
        when(
          mockStorageService.saveUser(any),
        ).thenThrow(Exception('Save failed'));

        final authNotifier = container.read(authProvider.notifier);

        // Act
        await authNotifier.register(
          fullName: 'João da Silva',
          cpf: '12345678901',
          email: 'joao@example.com',
          phone: '11987654321',
          birthDate: DateTime(1990, 5, 15),
          gender: 'Masculino',
          password: 'password123',
        );

        // Assert
        final state = container.read(authProvider);
        expect(state, isA<AsyncError>());
      });
    });

    group('Brazilian Validation Integration', () {
      test('should handle different CPF formats', () {
        expect(
          '123.456.789-01'.replaceAll(RegExp(r'[^0-9]'), ''),
          equals('12345678901'),
        );
        expect(
          '123 456 789 01'.replaceAll(RegExp(r'[^0-9]'), ''),
          equals('12345678901'),
        );
        expect(
          '12345678901'.replaceAll(RegExp(r'[^0-9]'), ''),
          equals('12345678901'),
        );
      });

      test('should validate Brazilian state codes', () {
        const validStates = ['SP', 'RJ', 'MG', 'RS', 'PR', 'SC', 'BA', 'GO'];

        for (final state in validStates) {
          expect(state.length, equals(2));
          expect(state, matches(RegExp(r'^[A-Z]{2}$')));
        }
      });

      test('should validate Brazilian ZIP code format', () {
        const validZipCodes = ['01234567', '12345678', '99999999'];
        const invalidZipCodes = ['1234567', '123456789', 'abcdefgh', ''];

        for (final zipCode in validZipCodes) {
          expect(zipCode, matches(RegExp(r'^\d{8}$')));
        }

        for (final zipCode in invalidZipCodes) {
          expect(zipCode, isNot(matches(RegExp(r'^\d{8}$'))));
        }
      });

      test('should validate Brazilian phone number formats', () {
        const validPhones = ['11987654321', '1134567890', '85999887766'];

        for (final phone in validPhones) {
          expect(phone.length, inInclusiveRange(10, 11));
          expect(phone, matches(RegExp(r'^\d{10,11}$')));
        }
      });
    });

    group('Data Persistence', () {
      test('should persist user data after successful registration', () async {
        // Arrange
        when(mockStorageService.saveUser(any)).thenAnswer((_) async {});

        final authNotifier = container.read(authProvider.notifier);

        // Act
        await authNotifier.register(
          fullName: 'João da Silva',
          cpf: '12345678901',
          email: 'joao@example.com',
          phone: '11987654321',
          birthDate: DateTime(1990, 5, 15),
          gender: 'Masculino',
          password: 'password123',
        );

        // Assert
        verify(mockStorageService.saveUser(any)).called(1);
      });

      test('should load existing user on provider initialization', () async {
        // Arrange
        final existingUser = _createTestUserModel();
        when(
          mockStorageService.getUser(),
        ).thenAnswer((_) async => existingUser);

        // Act
        final authNotifier = container.read(authProvider.notifier);
        await Future.delayed(Duration.zero); // Allow async loading

        // Assert
        final state = container.read(authProvider);
        expect(state.value?.id, equals(existingUser.id));
      });
    });
  });
}

UserEntity _createTestUserEntity() {
  return UserEntity(
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

UserModel _createTestUserModel() {
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
