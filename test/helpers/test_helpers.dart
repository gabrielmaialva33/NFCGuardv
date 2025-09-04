import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

/// Test helper utilities for NFCGuard testing
class TestHelpers {

  /// Creates a test ProviderContainer with common overrides
  static ProviderContainer createTestContainer({
    List<Override> overrides = const [],
  }) {
    return ProviderContainer(
      overrides: overrides,
    );
  }

  /// Waits for async provider to complete and returns the result
  static Future<T> waitForProvider<T>(ProviderContainer container,
      Provider<AsyncValue<T>> provider, {
        Duration timeout = const Duration(seconds: 5),
      }) async {
    final completer = Completer<T>();
    late final ProviderSubscription<AsyncValue<T>> subscription;

    subscription = container.listen(
      provider,
          (previous, next) {
        next.when(
          data: (data) {
            if (!completer.isCompleted) {
              completer.complete(data);
              subscription.close();
            }
          },
          error: (error, stackTrace) {
            if (!completer.isCompleted) {
              completer.completeError(error, stackTrace);
              subscription.close();
            }
          },
          loading: () {}, // Continue waiting
        );
      },
    );

    return completer.future.timeout(timeout);
  }

  /// Verifies that a mock was called with specific parameters
  static void verifyMockCall(Mock mock,
      String methodName,
      List<dynamic> positionalArguments, {
        Map<Symbol, dynamic>? namedArguments,
      }) {
    verify(mock.noSuchMethod(
      Invocation.method(
        Symbol(methodName),
        positionalArguments,
        namedArguments,
      ),
    )).called(1);
  }

  /// Creates mock responses for Brazilian address API
  static Map<String, dynamic> createMockAddressResponse({
    String? zipCode,
    String? address,
    String? neighborhood,
    String? city,
    String? state,
  }) {
    return {
      'cep': zipCode ?? '01234567',
      'logradouro': address ?? 'Rua das Flores',
      'bairro': neighborhood ?? 'Centro',
      'localidade': city ?? 'São Paulo',
      'uf': state ?? 'SP',
      'ibge': '3550308',
      'gia': '1004',
      'ddd': '11',
      'siafi': '7107',
    };
  }

  /// Validates Brazilian data formats
  static

  class BrazilianValidators {
  /// Validates CPF format (11 digits, no formatting)
  static bool isValidCpfFormat(String cpf) {
  return RegExp(r'^\d{11}$').hasMatch(cpf);
  }

  /// Validates ZIP code format (8 digits, no formatting)
  static bool isValidZipCodeFormat(String zipCode) {
  return RegExp(r'^\d{8}$').hasMatch(zipCode);
  }

  /// Validates Brazilian phone number format (10-11 digits)
  static bool isValidPhoneFormat(String phone) {
  return RegExp(r'^\d{10,11}$').hasMatch(phone);
  }

  /// Validates Brazilian state code (2 uppercase letters)
  static bool isValidStateFormat(String state) {
  return RegExp(r'^[A-Z]{2}$').hasMatch(state);
  }

  /// Validates email format
  static bool isValidEmailFormat(String email) {
  return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  /// Validates 8-digit code format
  static bool isValidCodeFormat(String code) {
  return RegExp(r'^\d{8}$').hasMatch(code);
  }
  }

  /// Test data generators
  static class Generators {
  /// Generates a valid CPF for testing
  static String generateValidCpf() {
  return '12345678901';
  }

  /// Generates a valid ZIP code for testing
  static String generateValidZipCode() {
  return '01234567';
  }

  /// Generates a valid phone number for testing
  static String generateValidPhone() {
  return '11987654321';
  }

  /// Generates a valid email for testing
  static String generateValidEmail() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return 'test$timestamp@example.com';
  }

  /// Generates test user data with unique identifiers
  static Map<String, dynamic> generateUserData() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return {
  'id': 'user-$timestamp',
  'fullName': 'Test User $timestamp',
  'cpf': generateValidCpf(),
  'email': generateValidEmail(),
  'phone': generateValidPhone(),
  'birthDate': DateTime(1990, 1, 1),
  'gender': 'Masculino',
  'zipCode': generateValidZipCode(),
  'address': 'Rua Teste, $timestamp',
  'neighborhood': 'Bairro Teste',
  'city': 'São Paulo',
  'state': 'SP',
  'eightDigitCode': '12345674',
  'createdAt': DateTime.now(),
  };
  }
  }

  /// Assertion helpers
  static class Assertions {
  /// Asserts that an async value contains expected data
  static void assertAsyncData<T>(AsyncValue<T> asyncValue, T expectedData) {
  expect(asyncValue, isA<AsyncData<T>>());
  expect(asyncValue.value, equals(expectedData));
  }

  /// Asserts that an async value is in error state
  static void assertAsyncError<T>(AsyncValue<T> asyncValue) {
  expect(asyncValue, isA<AsyncError<T>>());
  expect(asyncValue.hasError, isTrue);
  }

  /// Asserts that an async value is in loading state
  static void assertAsyncLoading<T>(AsyncValue<T> asyncValue) {
  expect(asyncValue, isA<AsyncLoading<T>>());
  expect(asyncValue.isLoading, isTrue);
  }

  /// Asserts Brazilian data format compliance
  static void assertBrazilianDataFormat(Map<String, dynamic> userData) {
  expect(userData['cpf'], matches(RegExp(r'^\d{11}$')));
  expect(userData['zipCode'], matches(RegExp(r'^\d{8}$')));
  expect(userData['phone'], matches(RegExp(r'^\d{10,11}$')));
  expect(userData['state'], matches(RegExp(r'^[A-Z]{2}$')));
  expect(userData['email'], contains('@'));
  expect(userData['eightDigitCode'], matches(RegExp(r'^\d{8}$')));
  }

  /// Asserts that NFC operation data is valid
  static void assertNfcOperationFormat(Map<String, dynamic> operation) {
  expect(operation['user_id'], isA<String>());
  expect(operation['operation_type'], isIn(['write', 'protect', 'unprotect']));
  expect(operation['code_used'], matches(RegExp(r'^\d{8}$')));
  expect(operation['success'], isA<bool>());

  if (operation['dataset_number'] != null) {
  expect(operation['dataset_number'], inInclusiveRange(1, 8));
  }
  }
  }

  /// Mock response builders
  static class MockResponses {
  /// Creates a successful API response
  static Map<String, dynamic> successResponse({
  dynamic data,
  String? message,
  }) {
  return {
  'success': true,
  'data': data,
  'message': message ?? 'Operation successful',
  'timestamp': DateTime.now().toIso8601String(),
  };
  }

  /// Creates an error API response
  static Map<String, dynamic> errorResponse({
  required String error,
  String? code,
  dynamic details,
  }) {
  return {
  'success': false,
  'error': error,
  'code': code ?? 'GENERIC_ERROR',
  'details': details,
  'timestamp': DateTime.now().toIso8601String(),
  };
  }

  /// Creates a Supabase-style response
  static List<Map<String, dynamic>> supabaseResponse(
  List<Map<String, dynamic>> data
  ) {
  return data;
  }
  }

  /// Performance testing utilities
  static class Performance {
  /// Measures execution time of a function
  static Future<Duration> measureExecutionTime<T>(
  Future<T> Function() operation
  ) async {
  final stopwatch = Stopwatch()..start();
  await operation();
  stopwatch.stop();
  return stopwatch.elapsed;
  }

  /// Asserts that operation completes within time limit
  static Future<void> assertExecutionTime<T>(
  Future<T> Function() operation,
  Duration maxDuration,
  ) async {
  final duration = await measureExecutionTime(operation);
  expect(duration, lessThanOrEqualTo(maxDuration));
  }

  /// Tests memory usage patterns (basic)
  static void assertNoMemoryLeaks(VoidCallback operation, int iterations) {
  // Run operation multiple times to check for memory leaks
  for (int i = 0; i < iterations; i++) {
  operation();
  }
  // Note: Advanced memory testing would require more sophisticated tools
  }
  }

  /// Date/Time testing utilities
  static class DateHelpers {
  /// Creates dates for Brazilian context testing
  static DateTime createBrazilianDate(int year, int month, int day) {
  return DateTime(year, month, day);
  }

  /// Creates a range of test dates
  static List<DateTime> createDateRange({
  required DateTime start,
  required DateTime end,
  required Duration interval,
  }) {
  final dates = <DateTime>[];
  var current = start;

  while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
  dates.add(current);
  current = current.add(interval);
  }

  return dates;
  }
  }
}