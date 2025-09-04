import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  static void verifyMockCall(Mock mock, String methodName, List<dynamic> args) {
    verify(mock.noSuchMethod(Invocation.method(Symbol(methodName), args)))
        .called(1);
  }

  /// Creates a sample address data for testing
  static Map<String, dynamic> createAddressData() {
    return {
      'zipCode': '01234567',
      'address': 'Rua das Flores, 123',
      'complement': 'Apto 45',
      'neighborhood': 'Centro',
      'city': 'São Paulo',
      'stateCode': 'SP',
      'ibge': '3550308',
      'gia': '1004',
      'ddd': '11',
      'siafi': '7107',
    };
  }

  /// Validates Brazilian data formats
  static bool isValidCpfFormat(String cpf) {
    return RegExp(r'^\d{11}$').hasMatch(cpf);
  }
}

/// Validates Brazilian data formats
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
}

/// Mock data generators for testing
class MockDataGenerators {
  /// Generates a list of valid test CPF numbers
  static List<String> generateValidCpfs() {
    return [
      '11144477735',
      '12345678909',
      '98765432100',
    ];
  }

  /// Generates a list of invalid CPF numbers for testing
  static List<String> generateInvalidCpfs() {
    return [
      '00000000000', // All zeros
      '11111111111', // All same digits
      '123456789',   // Too short
      '12345678901', // Invalid checksum
      '123.456.789-10', // Formatted but invalid
    ];
  }

  /// Generates valid Brazilian phone numbers
  static List<String> generateValidPhones() {
    return [
      '11987654321', // Mobile with area code
      '1134567890',  // Landline with area code
      '21987654321', // Rio mobile
      '8534567890',  // Northeastern landline
    ];
  }

  /// Generates valid ZIP codes
  static List<String> generateValidZipCodes() {
    return [
      '01234567',
      '12345678',
      '87654321',
      '98765432',
    ];
  }

  /// Generates valid Brazilian state codes
  static List<String> generateValidStates() {
    return [
      'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
      'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI',
      'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
    ];
  }

  /// Generates common Brazilian city names
  static List<String> generateBrazilianCities() {
    return [
      'São Paulo',
      'Rio de Janeiro',
      'Belo Horizonte',
      'Salvador',
      'Fortaleza',
      'Brasília',
      'Curitiba',
      'Recife',
      'Manaus',
      'Porto Alegre',
    ];
  }
}

/// Test utilities for async operations
class AsyncTestUtilities {
  /// Pumps the event loop to ensure async operations complete
  static Future<void> pumpEventLoop([int times = 1]) async {
    for (var i = 0; i < times; i++) {
      await Future.delayed(Duration.zero);
    }
  }

  /// Creates a delayed future for testing timeout scenarios
  static Future<T> createDelayedFuture<T>(T value, Duration delay) {
    return Future.delayed(delay, () => value);
  }

  /// Creates a future that throws an error after a delay
  static Future<T> createDelayedError<T>(dynamic error, Duration delay) {
    return Future.delayed(delay, () => throw error);
  }
}

/// Security testing utilities
class SecurityTestUtilities {
  /// Validates that a string doesn't contain sensitive patterns
  static bool containsSensitiveData(String input) {
    final sensitivePatterns = [
      RegExp(r'\d{11}'),        // CPF-like patterns
      RegExp(r'\d{8}'),         // Code-like patterns
      RegExp(r'password'),      // Password references
      RegExp(r'token'),         // Token references
      RegExp(r'secret'),        // Secret references
      RegExp(r'key'),           // Key references
    ];

    return sensitivePatterns.any((pattern) => pattern.hasMatch(input.toLowerCase()));
  }

  /// Generates a secure random string for testing
  static String generateSecureRandomString(int length) {
    const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    
    for (int i = 0; i < length; i++) {
      buffer.write(characters[(random + i) % characters.length]);
    }
    
    return buffer.toString();
  }
}

/// Performance testing utilities
class PerformanceTestUtilities {
  /// Measures execution time of a function
  static Duration measureExecutionTime(void Function() function) {
    final stopwatch = Stopwatch()..start();
    function();
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Measures async execution time
  static Future<Duration> measureAsyncExecutionTime(Future<void> Function() function) async {
    final stopwatch = Stopwatch()..start();
    await function();
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Runs a function multiple times and returns average execution time
  static Duration benchmarkFunction(void Function() function, int iterations) {
    final times = <Duration>[];
    
    for (int i = 0; i < iterations; i++) {
      times.add(measureExecutionTime(function));
    }
    
    final totalMicroseconds = times.fold<int>(
      0, 
      (sum, duration) => sum + duration.inMicroseconds,
    );
    
    return Duration(microseconds: totalMicroseconds ~/ iterations);
  }
}