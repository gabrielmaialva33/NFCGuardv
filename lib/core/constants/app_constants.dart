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

  // Performance constants for responsive UI
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration debounceDelay = Duration(milliseconds: 300);
  
  // Breakpoints for responsive design
  static const double mobileBreakpoint = 480.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const double minTouchTarget = 44.0;

  // Validation messages
  static const String invalidCpfMessage = 'CPF inválido';
  static const String codeAlreadyUsedMessage = 'CÓDIGO JÁ UTILIZADO';
  static const String invalidCodeMessage = 'CÓDIGO INVÁLIDO';
}
