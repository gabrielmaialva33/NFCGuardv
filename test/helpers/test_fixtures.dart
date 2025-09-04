import 'package:nfc_guard/data/models/user_model.dart';
import 'package:nfc_guard/domain/entities/user_entity.dart';

/// Test fixtures for consistent test data across the application
class TestFixtures {
  
  /// Creates a valid test user entity
  static UserEntity createUserEntity({
    String? id,
    String? fullName,
    String? cpf,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? gender,
    String? zipCode,
    String? address,
    String? neighborhood,
    String? city,
    String? state,
    String? eightDigitCode,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? 'test-user-123',
      fullName: fullName ?? 'João da Silva',
      cpf: cpf ?? '12345678901',
      email: email ?? 'joao@example.com',
      phone: phone ?? '11987654321',
      birthDate: birthDate ?? DateTime(1990, 5, 15),
      gender: gender ?? 'Masculino',
      zipCode: zipCode ?? '01234567',
      address: address ?? 'Rua das Flores, 123',
      neighborhood: neighborhood ?? 'Centro',
      city: city ?? 'São Paulo',
      state: state ?? 'SP',
      eightDigitCode: eightDigitCode ?? '12345674', // Valid check digit
      createdAt: createdAt ?? DateTime(2023, 12, 1),
    );
  }

  /// Creates a valid test user model
  static UserModel createUserModel({
    String? id,
    String? fullName,
    String? cpf,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? gender,
    String? zipCode,
    String? address,
    String? neighborhood,
    String? city,
    String? state,
    String? eightDigitCode,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? 'test-user-123',
      fullName: fullName ?? 'João da Silva',
      cpf: cpf ?? '12345678901',
      email: email ?? 'joao@example.com',
      phone: phone ?? '11987654321',
      birthDate: birthDate ?? DateTime(1990, 5, 15),
      gender: gender ?? 'Masculino',
      zipCode: zipCode ?? '01234567',
      address: address ?? 'Rua das Flores, 123',
      neighborhood: neighborhood ?? 'Centro',
      city: city ?? 'São Paulo',
      state: state ?? 'SP',
      eightDigitCode: eightDigitCode ?? '12345674', // Valid check digit
      createdAt: createdAt ?? DateTime(2023, 12, 1),
    );
  }

  /// Creates a user with minimal valid data
  static UserModel createMinimalUser() {
    return UserModel(
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
  }

  /// Creates a user with Brazilian-specific data and accents
  static UserModel createBrazilianUser() {
    return UserModel(
      id: 'br-user-456',
      fullName: 'José da Silva Conceição',
      cpf: '11122233344',
      email: 'jose.conceicao@email.com.br',
      phone: '11999887766',
      birthDate: DateTime(1985, 12, 25),
      gender: 'Masculino',
      zipCode: '04567890',
      address: 'Rua Três Corações, 456 - Apto 78',
      neighborhood: 'São João',
      city: 'São Paulo',
      state: 'SP',
      eightDigitCode: '87654321',
      createdAt: DateTime(2024, 1, 15),
    );
  }

  /// Creates NFC operation log data
  static Map<String, dynamic> createNfcOperationLog({
    String? userId,
    String? operationType,
    String? codeUsed,
    int? datasetNumber,
    bool? success,
    String? errorMessage,
    DateTime? createdAt,
  }) {
    return {
      'id': 'op-${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId ?? 'test-user-123',
      'operation_type': operationType ?? 'write',
      'code_used': codeUsed ?? '12345674',
      'dataset_number': datasetNumber,
      'success': success ?? true,
      'error_message': errorMessage,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Creates multiple NFC operation logs for statistics testing
  static List<Map<String, dynamic>> createNfcOperationLogs({
    int writeSuccessful = 3,
    int writeFailed = 1,
    int protectSuccessful = 2,
    int protectFailed = 1,
    int unprotectSuccessful = 1,
    int unprotectFailed = 0,
  }) {
    final logs = <Map<String, dynamic>>[];

    // Add write operations
    for (int i = 0; i < writeSuccessful; i++) {
      logs.add(createNfcOperationLog(
        operationType: 'write',
        success: true,
        codeUsed: 'code$i',
      ));
    }
    for (int i = 0; i < writeFailed; i++) {
      logs.add(createNfcOperationLog(
        operationType: 'write',
        success: false,
        errorMessage: 'Write failed',
        codeUsed: 'fail$i',
      ));
    }

    // Add protect operations
    for (int i = 0; i < protectSuccessful; i++) {
      logs.add(createNfcOperationLog(
        operationType: 'protect',
        success: true,
        codeUsed: 'protect$i',
      ));
    }
    for (int i = 0; i < protectFailed; i++) {
      logs.add(createNfcOperationLog(
        operationType: 'protect',
        success: false,
        errorMessage: 'Protect failed',
        codeUsed: 'protectfail$i',
      ));
    }

    // Add unprotect operations
    for (int i = 0; i < unprotectSuccessful; i++) {
      logs.add(createNfcOperationLog(
        operationType: 'unprotect',
        success: true,
        codeUsed: 'unprotect$i',
      ));
    }
    for (int i = 0; i < unprotectFailed; i++) {
      logs.add(createNfcOperationLog(
        operationType: 'unprotect',
        success: false,
        errorMessage: 'Unprotect failed',
        codeUsed: 'unprotectfail$i',
      ));
    }

    return logs;
  }

  /// Valid Brazilian test data
  static const validCpfs = [
    '11122233344',
    '12345678901',
    '98765432100',
  ];

  static const validZipCodes = [
    '01234567',
    '12345678',
    '87654321',
    '99999999',
  ];

  static const validPhones = [
    '11987654321', // Mobile with 11 digits
    '1134567890',  // Landline with 10 digits
    '85999887766', // Mobile from northeast
    '47988776655', // Mobile from south
  ];

  static const validEmails = [
    'test@example.com',
    'user@test.com.br',
    'jose.silva@email.com',
    'maria_santos@domain.org',
  ];

  static const validStates = [
    'SP', 'RJ', 'MG', 'RS', 'PR', 'SC', 'BA', 'GO',
    'PE', 'CE', 'PA', 'MA', 'PB', 'ES', 'MT', 'MS',
    'DF', 'AL', 'SE', 'RN', 'RO', 'AC', 'AM', 'AP',
    'RR', 'TO', 'PI',
  ];

  static const brazilianCities = [
    'São Paulo',
    'Rio de Janeiro',
    'Belo Horizonte',
    'Porto Alegre',
    'Curitiba',
    'Florianópolis',
    'Salvador',
    'Recife',
    'Fortaleza',
    'Brasília',
  ];

  /// Invalid test data for negative testing
  static const invalidCpfs = [
    '123',           // Too short
    '123456789012',  // Too long
    'abcdefghijk',   // Non-numeric
    '',              // Empty
    '000.000.000-00', // Formatted but invalid
  ];

  static const invalidZipCodes = [
    '1234567',   // Too short
    '123456789', // Too long
    'abcdefgh',  // Non-numeric
    '',          // Empty
    '12345-678', // Formatted
  ];

  static const invalidEmails = [
    'invalid',
    '@example.com',
    'user@',
    'user.example.com',
    '',
  ];

  static const invalidPhones = [
    '123',         // Too short
    '123456789012', // Too long
    'abcdefghij',   // Non-numeric
    '',             // Empty
  ];

  /// Creates address data for CEP testing
  static Map<String, String> createAddressData({
    String? address,
    String? neighborhood,
    String? city,
    String? stateCode,
  }) {
    return {
      'address': address ?? 'Rua das Flores, 123',
      'neighborhood': neighborhood ?? 'Centro',
      'city': city ?? 'São Paulo',
      'stateCode': stateCode ?? 'SP',
    };
  }

  /// Creates error scenarios for testing
  static const commonErrors = [
    'Network connection failed',
    'Storage access denied',
    'Invalid data format',
    'Authentication required',
    'Permission denied',
  ];

  /// Creates test configuration for different environments
  static Map<String, dynamic> createTestConfig({
    bool nfcAvailable = true,
    bool networkAvailable = true,
    bool storageAvailable = true,
  }) {
    return {
      'nfcAvailable': nfcAvailable,
      'networkAvailable': networkAvailable,
      'storageAvailable': storageAvailable,
    };
  }
}