import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_guard/core/utils/code_generator.dart';

void main() {
  group('CodeGenerator', () {
    group('generateUniqueCode', () {
      test('should generate an 8-digit code', () {
        final code = CodeGenerator.generateUniqueCode();

        expect(code.length, equals(8));
        expect(code, matches(RegExp(r'^\d{8}$')));
      });

      test('should generate unique codes on multiple calls', () {
        final codes = <String>{};

        // Generate 100 codes to test uniqueness
        for (int i = 0; i < 100; i++) {
          final code = CodeGenerator.generateUniqueCode();
          codes.add(code);
        }

        // Should have 100 unique codes (very high probability)
        expect(
          codes.length,
          greaterThan(95),
        ); // Allow for minimal collision chance
      });

      test('should generate valid codes that pass validation', () {
        for (int i = 0; i < 10; i++) {
          final code = CodeGenerator.generateUniqueCode();
          expect(CodeGenerator.validateCode(code), isTrue);
        }
      });

      test('should contain only digits', () {
        final code = CodeGenerator.generateUniqueCode();

        for (int i = 0; i < code.length; i++) {
          expect(int.tryParse(code[i]), isNotNull);
        }
      });
    });

    group('validateCode', () {
      test('should return true for valid codes', () {
        // Generate a valid code and test it
        final validCode = CodeGenerator.generateUniqueCode();
        expect(CodeGenerator.validateCode(validCode), isTrue);
      });

      test('should return false for codes with wrong length', () {
        expect(CodeGenerator.validateCode('1234567'), isFalse); // 7 digits
        expect(CodeGenerator.validateCode('123456789'), isFalse); // 9 digits
        expect(CodeGenerator.validateCode(''), isFalse); // empty
        expect(CodeGenerator.validateCode('123'), isFalse); // too short
      });

      test('should return false for codes with invalid check digit', () {
        // Create a code with wrong check digit
        expect(CodeGenerator.validateCode('12345678'), isFalse);
        expect(CodeGenerator.validateCode('00000000'), isFalse);
        expect(CodeGenerator.validateCode('99999999'), isFalse);
      });

      test('should return false for non-numeric codes', () {
        expect(CodeGenerator.validateCode('1234567a'), isFalse);
        expect(CodeGenerator.validateCode('abcdefgh'), isFalse);
        expect(CodeGenerator.validateCode('1234-567'), isFalse);
        expect(CodeGenerator.validateCode('1234 567'), isFalse);
      });

      test('should validate specific known valid codes', () {
        // Test with manually calculated valid codes
        // Code: 1234567, check digit calculation:
        // Sum: (1*2 + 2*1 + 3*2 + 4*1 + 5*2 + 6*1 + 7*2) = 2+2+6+4+10+6+14 = 44
        // Products > 9: 10 -> 1+0 = 1, 14 -> 1+4 = 5
        // Adjusted sum: 2+2+6+4+1+6+5 = 26
        // Remainder: 26 % 10 = 6
        // Check digit: 10 - 6 = 4
        expect(CodeGenerator.validateCode('12345674'), isTrue);
      });
    });

    group('_calculateCheckDigit', () {
      test('should calculate correct check digit for known cases', () {
        // Since _calculateCheckDigit is private, we test through validateCode

        // Test edge cases
        expect(CodeGenerator.validateCode('00000000'), isFalse);

        // Generate valid codes and verify they validate
        final codes = List.generate(
          20,
          (_) => CodeGenerator.generateUniqueCode(),
        );
        for (final code in codes) {
          expect(
            CodeGenerator.validateCode(code),
            isTrue,
            reason: 'Generated code $code should be valid',
          );
        }
      });
    });

    group('Edge Cases', () {
      test('should handle null or malformed input gracefully', () {
        expect(() => CodeGenerator.validateCode(''), returnNormally);
        expect(() => CodeGenerator.validateCode('12345678'), returnNormally);
      });

      test('should be consistent across multiple validations', () {
        final code = CodeGenerator.generateUniqueCode();

        // Validate the same code multiple times
        expect(CodeGenerator.validateCode(code), isTrue);
        expect(CodeGenerator.validateCode(code), isTrue);
        expect(CodeGenerator.validateCode(code), isTrue);
      });

      test('should handle leading zeros correctly', () {
        // Generate codes that might start with zero
        bool foundLeadingZero = false;
        for (int i = 0; i < 50; i++) {
          final code = CodeGenerator.generateUniqueCode();
          if (code.startsWith('0')) {
            foundLeadingZero = true;
            expect(CodeGenerator.validateCode(code), isTrue);
            expect(code.length, equals(8));
          }
        }
        // Note: Due to randomness, leading zeros might not appear in 50 iterations
        // This test mainly ensures they're handled correctly if they occur
      });
    });

    group('Performance', () {
      test('should generate codes quickly', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          CodeGenerator.generateUniqueCode();
        }

        stopwatch.stop();

        // Should generate 1000 codes in less than 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('should validate codes quickly', () {
        final codes = List.generate(
          100,
          (_) => CodeGenerator.generateUniqueCode(),
        );
        final stopwatch = Stopwatch()..start();

        for (final code in codes) {
          CodeGenerator.validateCode(code);
        }

        stopwatch.stop();

        // Should validate 100 codes in less than 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });
  });
}
