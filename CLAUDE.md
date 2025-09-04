# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.

## Project Overview

NFCGuard is a Flutter application for securely writing NFC tags with unique codes. The app is
designed for Brazilian users and includes CPF validation functionality.

## Technology Stack

- **Framework**: Flutter (Dart SDK ^3.9.0)
- **State Management**: Riverpod (flutter_riverpod, riverpod_annotation, riverpod_generator)
- **NFC Integration**: nfc_manager package
- **Storage**: flutter_secure_storage (secure), shared_preferences (local)
- **Brazilian Features**: all_validations_br (CPF validation), search_cep (CEP API)
- **HTTP**: http package
- **JSON**: json_annotation with json_serializable for code generation
- **Linting**: flutter_lints with default Flutter lint rules

## Common Commands

### Development

```bash
# Get dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Run with hot reload
flutter run --hot

# Build for production (Android)
flutter build apk --release

# Build for production (iOS)  
flutter build ios --release

# Code generation (for Riverpod providers and JSON serialization)
flutter packages pub run build_runner build

# Watch for changes and regenerate code
flutter packages pub run build_runner watch

# Clean generated files and rebuild
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Testing & Quality

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/ test/
```

## Code Architecture

The project follows a minimal structure with core utilities:

### Directory Structure

- `lib/core/constants/` - Application constants including NFC parameters, storage keys, and
  validation messages
- `lib/core/theme/` - Material Design 3 theme configuration with light/dark themes
- `lib/main.dart` - Entry point (currently default Flutter counter app)

### Key Components

**AppConstants** (`lib/core/constants/app_constants.dart`):

- App metadata (name, version)
- Storage key definitions
- NFC configuration (8-character codes, max 8 datasets per tag)
- Portuguese validation messages for Brazilian users

**AppTheme** (`lib/core/theme/app_theme.dart`):

- Material Design 3 implementation
- Blue color scheme (#2196F3)
- Consistent styling for buttons and inputs
- Dark/light theme support

### State Management

- Uses Riverpod with code generation
- Annotations require `flutter packages pub run build_runner build` after changes to providers
- Generated files should be committed to repository

### Brazilian Localization

- CPF validation through all_validations_br
- CEP (postal code) lookup via search_cep
- Portuguese error messages in constants

### Security Features

- Secure storage for sensitive data (user tokens, user data)
- Code uniqueness tracking to prevent reuse
- 8-character unique code generation system

## Development Notes

- The main.dart currently contains default Flutter boilerplate - actual NFC functionality needs to
  be implemented
- Generated code from build_runner should be version controlled
- The app appears to be in early development stage with infrastructure in place
- NFC functionality will require physical device testing (not available in simulators)