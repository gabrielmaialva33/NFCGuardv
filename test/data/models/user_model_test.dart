import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_guard/data/models/user_model.dart';
import 'package:nfc_guard/domain/entities/user_entity.dart';

void main() {
  group('UserModel', () {
    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final user = _createTestUserModel();

        // Act
        final json = user.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals('123456789'));
        expect(json['full_name'], equals('João da Silva'));
        expect(json['cpf'], equals('12345678901'));
        expect(json['email'], equals('joao@example.com'));
        expect(json['phone'], equals('11987654321'));
        expect(json['birth_date'], equals('1990-05-15T00:00:00.000'));
        expect(json['gender'], equals('Masculino'));
        expect(json['zip_code'], equals('01234567'));
        expect(json['address'], equals('Rua das Flores, 123'));
        expect(json['neighborhood'], equals('Centro'));
        expect(json['city'], equals('São Paulo'));
        expect(json['state'], equals('SP'));
        expect(json['eight_digit_code'], equals('12345678'));
        expect(json['created_at'], equals('2023-12-01T00:00:00.000'));
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'id': '123456789',
          'full_name': 'João da Silva',
          'cpf': '12345678901',
          'email': 'joao@example.com',
          'phone': '11987654321',
          'birth_date': '1990-05-15T00:00:00.000',
          'gender': 'Masculino',
          'zip_code': '01234567',
          'address': 'Rua das Flores, 123',
          'neighborhood': 'Centro',
          'city': 'São Paulo',
          'state': 'SP',
          'eight_digit_code': '12345678',
          'created_at': '2023-12-01T00:00:00.000',
        };

        // Act
        final user = UserModel.fromJson(json);

        // Assert
        expect(user.id, equals('123456789'));
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

      test('should handle round-trip JSON serialization', () {
        // Arrange
        final originalUser = _createTestUserModel();

        // Act
        final json = originalUser.toJson();
        final deserializedUser = UserModel.fromJson(json);

        // Assert
        expect(deserializedUser.id, equals(originalUser.id));
        expect(deserializedUser.fullName, equals(originalUser.fullName));
        expect(deserializedUser.cpf, equals(originalUser.cpf));
        expect(deserializedUser.email, equals(originalUser.email));
        expect(deserializedUser.phone, equals(originalUser.phone));
        expect(deserializedUser.birthDate, equals(originalUser.birthDate));
        expect(deserializedUser.gender, equals(originalUser.gender));
        expect(deserializedUser.zipCode, equals(originalUser.zipCode));
        expect(deserializedUser.address, equals(originalUser.address));
        expect(deserializedUser.neighborhood, equals(originalUser.neighborhood));
        expect(deserializedUser.city, equals(originalUser.city));
        expect(deserializedUser.state, equals(originalUser.state));
        expect(deserializedUser.eightDigitCode, equals(originalUser.eightDigitCode));
        expect(deserializedUser.createdAt, equals(originalUser.createdAt));
      });
    });

    group('Factory Constructors', () {
      test('should create UserModel from UserEntity', () {
        // Arrange
        final entity = _createTestUserEntity();

        // Act
        final model = UserModel.fromEntity(entity);

        // Assert
        expect(model.id, equals(entity.id));
        expect(model.fullName, equals(entity.fullName));
        expect(model.cpf, equals(entity.cpf));
        expect(model.email, equals(entity.email));
        expect(model.phone, equals(entity.phone));
        expect(model.birthDate, equals(entity.birthDate));
        expect(model.gender, equals(entity.gender));
        expect(model.zipCode, equals(entity.zipCode));
        expect(model.address, equals(entity.address));
        expect(model.neighborhood, equals(entity.neighborhood));
        expect(model.city, equals(entity.city));
        expect(model.state, equals(entity.state));
        expect(model.eightDigitCode, equals(entity.eightDigitCode));
        expect(model.createdAt, equals(entity.createdAt));
      });
    });

    group('Inheritance', () {
      test('should extend UserEntity', () {
        final userModel = _createTestUserModel();
        expect(userModel, isA<UserEntity>());
      });

      test('should have access to UserEntity methods', () {
        // Arrange
        final userModel = _createTestUserModel();

        // Act
        final copiedUser = userModel.copyWith(fullName: 'Maria Silva');

        // Assert
        expect(copiedUser.fullName, equals('Maria Silva'));
        expect(copiedUser.id, equals(userModel.id)); // Other fields unchanged
        expect(copiedUser.cpf, equals(userModel.cpf));
      });
    });

    group('Brazilian Data Handling', () {
      test('should handle CPF correctly', () {
        final user = _createTestUserModel();
        expect(user.cpf, matches(RegExp(r'^\d{11}$')));
      });

      test('should handle Brazilian address formats', () {
        final user = _createTestUserModel();
        expect(user.zipCode, matches(RegExp(r'^\d{8}$')));
        expect(user.state, hasLength(2)); // Brazilian state codes are 2 letters
      });

      test('should handle Portuguese characters in names', () {
        final userWithAccents = UserModel(
          id: '123',
          fullName: 'José da Silva Ção',
          cpf: '12345678901',
          email: 'jose@example.com',
          phone: '11987654321',
          birthDate: DateTime(1990, 1, 1),
          gender: 'Masculino',
          zipCode: '01234567',
          address: 'Rua Três Corações, 456',
          neighborhood: 'São João',
          city: 'São Paulo',
          state: 'SP',
          eightDigitCode: '12345678',
          createdAt: DateTime.now(),
        );

        final json = userWithAccents.toJson();
        final deserialized = UserModel.fromJson(json);

        expect(deserialized.fullName, equals('José da Silva Ção'));
        expect(deserialized.address, equals('Rua Três Corações, 456'));
        expect(deserialized.neighborhood, equals('São João'));
      });
    });

    group('Validation', () {
      test('should handle valid Brazilian phone numbers', () {
        final user = _createTestUserModel();
        expect(user.phone, matches(RegExp(r'^\d{10,11}$')));
      });

      test('should handle valid email formats', () {
        final user = _createTestUserModel();
        expect(user.email, contains('@'));
        expect(user.email, contains('.'));
      });

      test('should handle valid 8-digit codes', () {
        final user = _createTestUserModel();
        expect(user.eightDigitCode, hasLength(8));
        expect(user.eightDigitCode, matches(RegExp(r'^\d{8}$')));
      });
    });

    group('Edge Cases', () {
      test('should handle minimum valid data', () {
        final minimalUser = UserModel(
          id: '1',
          fullName: 'A',
          cpf: '00000000000',
          email: 'a@b.c',
          phone: '1122334455',
          birthDate: DateTime(1900, 1, 1),
          gender: 'Outro',
          zipCode: '00000000',
          address: '',
          neighborhood: '',
          city: '',
          state: '',
          eightDigitCode: '00000000',
          createdAt: DateTime(2020, 1, 1),
        );

        final json = minimalUser.toJson();
        final deserialized = UserModel.fromJson(json);

        expect(deserialized.fullName, equals('A'));
        expect(deserialized.address, isEmpty);
        expect(deserialized.neighborhood, isEmpty);
      });

      test('should handle maximum length data', () {
        final maxUser = UserModel(
          id: '123456789012345678901234567890', // Very long ID
          fullName: 'A' * 100, // Long name
          cpf: '99999999999',
          email: 'very.long.email.address.test@example-domain.com',
          phone: '11999887766',
          birthDate: DateTime(2000, 12, 31),
          gender: 'Prefiro não informar',
          zipCode: '99999999',
          address: 'Rua com nome muito longo para testar limites de caracteres, 9999',
          neighborhood: 'Bairro com nome extenso para validação',
          city: 'Cidade com Nome Muito Extenso Para Teste',
          state: 'RJ',
          eightDigitCode: '99999999',
          createdAt: DateTime(2024, 12, 31),
        );

        final json = maxUser.toJson();
        final deserialized = UserModel.fromJson(json);

        expect(deserialized.fullName, equals('A' * 100));
        expect(deserialized.address, contains('muito longo'));
      });
    });
  });
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