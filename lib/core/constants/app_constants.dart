class AppConstants {
  static const String appName = 'NFCGuard';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String usedCodesKey = 'used_codes';

  // NFC Constants
  static const int codeLength = 8;
  static const int maxTagDataSets = 8;

  // Validation messages
  static const String invalidCpfMessage = 'CPF inválido';
  static const String codeAlreadyUsedMessage = 'CÓDIGO JÁ UTILIZADO';
  static const String invalidCodeMessage = 'CÓDIGO INVÁLIDO';
}
