import 'dart:math';

class CodeGenerator {
  static String generateUniqueCode() {
    final random = Random();

    // Gerar 7 dígitos aleatórios
    String code = '';
    for (int i = 0; i < 7; i++) {
      code += random.nextInt(10).toString();
    }

    // Calcular dígito verificador
    int digitoVerificador = _calculateCheckDigit(code);

    return code + digitoVerificador.toString();
  }

  static bool validateCode(String code) {
    if (code.length != 8) return false;

    String baseCode = code.substring(0, 7);
    int providedCheckDigit = int.tryParse(code.substring(7)) ?? -1;
    int calculatedCheckDigit = _calculateCheckDigit(baseCode);

    return providedCheckDigit == calculatedCheckDigit;
  }

  static int _calculateCheckDigit(String code) {
    int sum = 0;
    for (int i = 0; i < code.length; i++) {
      int digit = int.parse(code[i]);
      int weight = (i % 2 == 0) ? 2 : 1;
      int product = digit * weight;

      if (product > 9) {
        product = (product ~/ 10) + (product % 10);
      }

      sum += product;
    }

    int remainder = sum % 10;
    return remainder == 0 ? 0 : 10 - remainder;
  }
}
