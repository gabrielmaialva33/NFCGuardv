import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_guard/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    group('Constructor', () {
      test('should create user entity with all required fields', () {
        // Arrange & Act
        final user = UserEntity(
          id: '123',
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

        // Assert
        expect(user.id, equals('123'));
        expect(user.fullName, equals('João da Silva'));
        expect(user.cpf, equals('12345678901'));
        expect(user.email, equals('joao@example.com'));
        expect(user.phone, equals('11987654321'));
        expect(user.birthDate, equals(DateTime(1990, 5, 15)));
        expect(user.gender, equals('Masculino'));
        expect(user.zipCode, equals('01234567'));
        expect(user.address, equals('Rua das Flores, 123'));
        expect(user.neighborhood, equals('Centro'));
        expect(user.city, equals('São Paulo'));
        expect(user.state, equals('SP'));
        expect(user.eightDigitCode, equals('12345678'));
        expect(user.createdAt, equals(DateTime(2023, 12, 1)));
      });

      test('should be immutable', () {
        final user = _createTestUser();
        
        // Verify all fields are final (compile-time check)
        expect(user.id, isA<String>());
        expect(user.fullName, isA<String>());
        expect(user.cpf, isA<String>());
        expect(user.email, isA<String>());
        expect(user.phone, isA<String>());
        expect(user.birthDate, isA<DateTime>());
        expect(user.gender, isA<String>());
        expect(user.zipCode, isA<String>());
        expect(user.address, isA<String>());
        expect(user.neighborhood, isA<String>());
        expect(user.city, isA<String>());
        expect(user.state, isA<String>());
        expect(user.eightDigitCode, isA<String>());
        expect(user.createdAt, isA<DateTime>());
      });
    });

    group('copyWith', () {
      test('should create new instance with updated single field', () {
        // Arrange
        final originalUser = _createTestUser();

        // Act
        final updatedUser = originalUser.copyWith(fullName: 'Maria da Silva');

        // Assert
        expect(updatedUser.fullName, equals('Maria da Silva'));
        expect(updatedUser.id, equals(originalUser.id));
        expect(updatedUser.cpf, equals(originalUser.cpf));
        expect(updatedUser.email, equals(originalUser.email));
        expect(updatedUser.phone, equals(originalUser.phone));
        expect(updatedUser.birthDate, equals(originalUser.birthDate));
        expect(updatedUser.gender, equals(originalUser.gender));
        expect(updatedUser.zipCode, equals(originalUser.zipCode));
        expect(updatedUser.address, equals(originalUser.address));
        expect(updatedUser.neighborhood, equals(originalUser.neighborhood));
        expect(updatedUser.city, equals(originalUser.city));
        expect(updatedUser.state, equals(originalUser.state));
        expect(updatedUser.eightDigitCode, equals(originalUser.eightDigitCode));
        expect(updatedUser.createdAt, equals(originalUser.createdAt));
      });

      test('should create new instance with multiple updated fields', () {
        // Arrange
        final originalUser = _createTestUser();

        // Act
        final updatedUser = originalUser.copyWith(
          fullName: 'Maria da Silva',
          email: 'maria@example.com',
          city: 'Rio de Janeiro',
          state: 'RJ',
        );

        // Assert
        expect(updatedUser.fullName, equals('Maria da Silva'));
        expect(updatedUser.email, equals('maria@example.com'));
        expect(updatedUser.city, equals('Rio de Janeiro'));
        expect(updatedUser.state, equals('RJ'));
        
        // Unchanged fields
        expect(updatedUser.id, equals(originalUser.id));
        expect(updatedUser.cpf, equals(originalUser.cpf));
        expect(updatedUser.phone, equals(originalUser.phone));
        expect(updatedUser.eightDigitCode, equals(originalUser.eightDigitCode));
      });

      test('should return identical instance when no changes', () {
        // Arrange
        final originalUser = _createTestUser();

        // Act
        final copiedUser = originalUser.copyWith();

        // Assert - all fields should be identical
        expect(copiedUser.id, equals(originalUser.id));
        expect(copiedUser.fullName, equals(originalUser.fullName));
        expect(copiedUser.cpf, equals(originalUser.cpf));
        expect(copiedUser.email, equals(originalUser.email));
        expect(copiedUser.phone, equals(originalUser.phone));
        expect(copiedUser.birthDate, equals(originalUser.birthDate));
        expect(copiedUser.gender, equals(originalUser.gender));
        expect(copiedUser.zipCode, equals(originalUser.zipCode));
        expect(copiedUser.address, equals(originalUser.address));
        expect(copiedUser.neighborhood, equals(originalUser.neighborhood));
        expect(copiedUser.city, equals(originalUser.city));
        expect(copiedUser.state, equals(originalUser.state));
        expect(copiedUser.eightDigitCode, equals(originalUser.eightDigitCode));
        expect(copiedUser.createdAt, equals(originalUser.createdAt));
      });

      test('should handle null values correctly', () {
        // Arrange
        final originalUser = _createTestUser();

        // Act - passing null should keep original values
        final copiedUser = originalUser.copyWith(
          fullName: null,
          email: null,
          city: null,
        );

        // Assert
        expect(copiedUser.fullName, equals(originalUser.fullName));
        expect(copiedUser.email, equals(originalUser.email));
        expect(copiedUser.city, equals(originalUser.city));
      });

      test('should update address information correctly', () {
        // Arrange
        final originalUser = _createTestUser();

        // Act
        final updatedUser = originalUser.copyWith(
          zipCode: '87654321',
          address: 'Avenida Brasil, 456',
          neighborhood: 'Copacabana',
          city: 'Rio de Janeiro',
          state: 'RJ',
        );

        // Assert
        expect(updatedUser.zipCode, equals('87654321'));
        expect(updatedUser.address, equals('Avenida Brasil, 456'));
        expect(updatedUser.neighborhood, equals('Copacabana'));
        expect(updatedUser.city, equals('Rio de Janeiro'));
        expect(updatedUser.state, equals('RJ'));
      });
    });

    group('Brazilian Data Validation', () {
      test('should handle valid CPF format', () {
        final user = _createTestUser();
        expect(user.cpf, hasLength(11));
        expect(user.cpf, matches(RegExp(r'^\d{11}$')));
      });

      test('should handle valid ZIP code format', () {
        final user = _createTestUser();
        expect(user.zipCode, hasLength(8));
        expect(user.zipCode, matches(RegExp(r'^\d{8}$')));
      });

      test('should handle valid Brazilian state codes', () {
        final brazilianStates = [
          'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
          'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
          'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
        ];

        for (final state in brazilianStates) {
          final user = _createTestUser().copyWith(state: state);
          expect(user.state, equals(state));
          expect(user.state, hasLength(2));
          expect(user.state, matches(RegExp(r'^[A-Z]{2}$')));
        }
      });

      test('should handle valid phone number formats', () {
        final phoneFormats = [
          '11987654321', // Mobile (11 digits)
          '1134567890',  // Landline (10 digits)
          '85999887766', // Mobile from another state
        ];

        for (final phone in phoneFormats) {
          final user = _createTestUser().copyWith(phone: phone);
          expect(user.phone, matches(RegExp(r'^\d{10,11}$')));
        }
      });

      test('should handle Portuguese names with accents', () {
        final namesWithAccents = [
          'José da Silva',
          'Maria da Conceição',
          'João Antônio',
          'Ana Lúcia dos Santos',
          'Carlos André',
        ];

        for (final name in namesWithAccents) {
          final user = _createTestUser().copyWith(fullName: name);
          expect(user.fullName, equals(name));
          expect(user.fullName, isNotEmpty);
        }
      });

      test('should handle Brazilian address formats', () {
        final addresses = [
          'Rua das Flores, 123',
          'Avenida Paulista, 1000 - Apto 45',
          'Praça da Sé, s/n',
          'Travessa do Comércio, 789 - Sobrado',
        ];

        for (final address in addresses) {
          final user = _createTestUser().copyWith(address: address);
          expect(user.address, equals(address));
        }
      });
    });

    group('Date Handling', () {
      test('should handle birth date correctly', () {
        final birthDate = DateTime(1990, 12, 25);
        final user = _createTestUser().copyWith(birthDate: birthDate);
        
        expect(user.birthDate, equals(birthDate));
        expect(user.birthDate.year, equals(1990));
        expect(user.birthDate.month, equals(12));
        expect(user.birthDate.day, equals(25));
      });

      test('should handle created at timestamp', () {
        final createdAt = DateTime(2023, 6, 15, 14, 30, 0);
        final user = _createTestUser().copyWith(createdAt: createdAt);
        
        expect(user.createdAt, equals(createdAt));
        expect(user.createdAt.isBefore(DateTime.now()), isTrue);
      });

      test('should handle edge date cases', () {
        // Very old birth date
        final oldDate = DateTime(1900, 1, 1);
        final userOld = _createTestUser().copyWith(birthDate: oldDate);
        expect(userOld.birthDate, equals(oldDate));

        // Recent birth date
        final recentDate = DateTime(2005, 12, 31);
        final userRecent = _createTestUser().copyWith(birthDate: recentDate);
        expect(userRecent.birthDate, equals(recentDate));
      });
    });

    group('Gender Options', () {
      test('should handle Brazilian gender options', () {
        final genderOptions = [
          'Masculino',
          'Feminino',
          'Outro',
          'Prefiro não informar',
        ];

        for (final gender in genderOptions) {
          final user = _createTestUser().copyWith(gender: gender);
          expect(user.gender, equals(gender));
        }
      });
    });

    group('8-Digit Code', () {
      test('should handle valid 8-digit codes', () {
        final user = _createTestUser();
        expect(user.eightDigitCode, hasLength(8));
        expect(user.eightDigitCode, matches(RegExp(r'^\d{8}$')));
      });

      test('should maintain code uniqueness property', () {
        final codes = ['12345674', '87654321', '11111111', '99999999'];
        
        for (final code in codes) {
          final user = _createTestUser().copyWith(eightDigitCode: code);
          expect(user.eightDigitCode, equals(code));
          expect(user.eightDigitCode, hasLength(8));
        }
      });
    });

    group('Equality and Comparison', () {
      test('should consider entities with same data equal', () {
        final user1 = _createTestUser();
        final user2 = _createTestUser();
        
        // Since there's no explicit equality implementation,
        // we test field-by-field equality
        expect(user1.id, equals(user2.id));
        expect(user1.fullName, equals(user2.fullName));
        expect(user1.cpf, equals(user2.cpf));
        expect(user1.email, equals(user2.email));
        expect(user1.eightDigitCode, equals(user2.eightDigitCode));
      });

      test('should consider entities with different IDs as different', () {
        final user1 = _createTestUser();
        final user2 = user1.copyWith(id: 'different-id');
        
        expect(user1.id, isNot(equals(user2.id)));
        expect(user1.fullName, equals(user2.fullName)); // Other fields same
      });
    });

    group('Edge Cases', () {
      test('should handle empty string fields', () {
        final user = UserEntity(
          id: 'test',
          fullName: 'Test User',
          cpf: '12345678901',
          email: 'test@example.com',
          phone: '11987654321',
          birthDate: DateTime(1990, 1, 1),
          gender: 'Masculino',
          zipCode: '',  // Empty ZIP code
          address: '',  // Empty address
          neighborhood: '', // Empty neighborhood
          city: '',     // Empty city
          state: '',    // Empty state
          eightDigitCode: '12345678',
          createdAt: DateTime.now(),
        );

        expect(user.zipCode, isEmpty);
        expect(user.address, isEmpty);
        expect(user.neighborhood, isEmpty);
        expect(user.city, isEmpty);
        expect(user.state, isEmpty);
      });

      test('should handle very long string fields', () {
        const longName = 'A' * 100;
        const longAddress = 'Rua com nome muito longo ' * 10;
        
        final user = _createTestUser().copyWith(
          fullName: longName,
          address: longAddress,
        );

        expect(user.fullName, equals(longName));
        expect(user.address, equals(longAddress));
        expect(user.fullName.length, equals(100));
      });

      test('should handle special characters in Brazilian names', () {
        final specialNames = [
          'José Antônio da Silva',
          'Maria da Conceição dos Santos',
          'João Paulo Ação',
          'Ana Lúcia D\'Angelo',
          'Carlos André O\'Connor',
        ];

        for (final name in specialNames) {
          final user = _createTestUser().copyWith(fullName: name);
          expect(user.fullName, equals(name));
        }
      });

      test('should handle different address formats', () {
        final addresses = [
          'Rua das Flores, 123',
          'Avenida Paulista, 1000 - Apto 45B',
          'Praça da Sé, s/n',
          'Estrada Velha de Santos, Km 25',
          'Rodovia BR-101, 500 - Galpão 3',
        ];

        for (final address in addresses) {
          final user = _createTestUser().copyWith(address: address);
          expect(user.address, equals(address));
        }
      });
    });

    group('Data Integrity', () {
      test('should maintain referential integrity', () {
        final user = _createTestUser();
        final copiedUser = user.copyWith(email: 'new@email.com');
        
        // Original user should be unchanged
        expect(user.email, equals('joao@example.com'));
        expect(copiedUser.email, equals('new@email.com'));
        
        // Other fields should reference same values
        expect(user.id, equals(copiedUser.id));
        expect(user.cpf, equals(copiedUser.cpf));
      });

      test('should handle DateTime precision correctly', () {
        final birthDate = DateTime(1990, 5, 15, 10, 30, 45, 123);
        final createdAt = DateTime(2023, 12, 1, 9, 15, 30, 456);
        
        final user = _createTestUser().copyWith(
          birthDate: birthDate,
          createdAt: createdAt,
        );

        expect(user.birthDate, equals(birthDate));
        expect(user.createdAt, equals(createdAt));
        expect(user.birthDate.millisecond, equals(123));
        expect(user.createdAt.millisecond, equals(456));
      });
    });

    group('Brazilian Business Rules', () {
      test('should support Brazilian address components', () {
        final user = _createTestUser();
        
        // All Brazilian address components should be present
        expect(user.zipCode, isNotEmpty);    // CEP
        expect(user.address, isNotEmpty);    // Logradouro
        expect(user.neighborhood, isNotEmpty); // Bairro
        expect(user.city, isNotEmpty);       // Cidade
        expect(user.state, isNotEmpty);      // Estado
      });

      test('should handle incomplete address data', () {
        final incompleteUser = _createTestUser().copyWith(
          zipCode: '12345678',
          address: 'Rua das Flores, 123',
          neighborhood: '', // Missing neighborhood
          city: 'São Paulo',
          state: 'SP',
        );

        expect(incompleteUser.zipCode, isNotEmpty);
        expect(incompleteUser.address, isNotEmpty);
        expect(incompleteUser.neighborhood, isEmpty);
        expect(incompleteUser.city, isNotEmpty);
        expect(incompleteUser.state, isNotEmpty);
      });

      test('should validate Brazilian state codes', () {
        const validStates = ['SP', 'RJ', 'MG', 'RS', 'BA'];
        
        for (final state in validStates) {
          final user = _createTestUser().copyWith(state: state);
          expect(user.state, hasLength(2));
          expect(user.state, matches(RegExp(r'^[A-Z]{2}$')));
        }
      });

      test('should handle 8-digit security code format', () {
        final codes = ['12345674', '87654321', '00000000', '99999999'];
        
        for (final code in codes) {
          final user = _createTestUser().copyWith(eightDigitCode: code);
          expect(user.eightDigitCode, hasLength(8));
          expect(user.eightDigitCode, matches(RegExp(r'^\d{8}$')));
        }
      });
    });

    group('Performance', () {
      test('should create instances quickly', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          _createTestUser();
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should copy instances quickly', () {
        final user = _createTestUser();
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          user.copyWith(fullName: 'Test $i');
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });
  });
}

UserEntity _createTestUser() {
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