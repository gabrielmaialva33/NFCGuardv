<h1 align="center">
  <br>
  <img src="https://github.com/gabrielmaialva33/nfc-guard/blob/main/.github/assets/sensor.png" alt="NFCGuard" width="200">
  <br>
  NFCGuard - Secure NFC Tag Writer with Unique Code Protection 🔐
  <br>
</h1>

<p align="center">
  <strong>A sophisticated Flutter application for securely writing NFC tags with unique codes and Brazilian CPF validation</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.9.0+-blue?style=flat&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.0+-blue?style=flat&logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=flat&logo=android" alt="Platform" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat&logo=appveyor" alt="License" />
  <img src="https://img.shields.io/badge/Made%20with-❤️%20by%20Maia-red?style=flat&logo=appveyor" alt="Made with Love" />
</p>

<br>

<p align="center">
  <a href="#sparkles-features">Features</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#shield-security">Security</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#computer-technologies">Technologies</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#package-installation">Installation</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#gear-configuration">Configuration</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#electric_plug-usage">Usage</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#memo-license">License</a>
</p>

<br>

## :sparkles: Features

### Secure NFC Writing 🔐

- **Unique Code Generation** - 8-character secure codes for each tag
- **Anti-Replication Protection** - Prevents code reuse and duplication
- **Multiple Tag Support** - Write up to 8 different datasets per NFC tag
- **Real-Time Validation** - Instant verification of code validity
- **Secure Storage** - Encrypted storage for sensitive data using Flutter Secure Storage
- **Usage Tracking** - Monitor and prevent duplicate code usage
- **🆕 Enterprise Logging** - Complete NFC operation audit trail
- **🆕 Cloud Synchronization** - Real-time data backup with Supabase

### Brazilian Integration 🇧🇷

- **CPF Validation** - Built-in Brazilian CPF document validation
- **CEP Lookup** - Automatic postal code verification and address lookup
- **Portuguese Interface** - Fully localized in Portuguese
- **Brazilian Standards** - Compliance with local data protection requirements
- **Local Storage** - Secure local data persistence with SharedPreferences

### Modern Architecture 🏗️

- **Riverpod State Management** - Reactive state management with code generation
- **Material Design 3** - Modern UI components with light/dark theme support
- **Clean Architecture** - Organized code structure with separation of concerns
- **Type Safety** - Full Dart null safety implementation
- **Code Generation** - Automated provider and JSON serialization generation

<br>

## :shield: Security Features

### Code Protection System 🔒

```bash
# Security Measures:
✅ 8-character unique code generation
✅ Code reuse prevention system
✅ Encrypted secure storage
✅ Usage history tracking
✅ Anti-tampering validation
✅ Secure key management
```

### Data Protection

```bash
# Security Implementation:
- Flutter Secure Storage for sensitive data
- Local validation before NFC write
- Code uniqueness verification
- Encrypted user data storage
- Secure token management
- Protected against replay attacks
```

### NFC Security

```bash
# NFC Protection:
- Unique identifiers per tag
- Multiple dataset support (up to 8)
- Secure write protocols
- Tag authentication
- Anti-cloning measures
```

<br>

## :computer: Technologies

### Core Framework

- **[Flutter](https://flutter.dev/)** 3.9.0+ - Cross-platform mobile framework
- **[Dart](https://dart.dev/)** 3.0+ - Modern programming language
- **[Material Design 3](https://m3.material.io/)** - Contemporary UI components

### Backend & Database

- **[Supabase](https://supabase.io/)** 2.5.6 - Real-time backend-as-a-service
- **PostgreSQL** - Robust relational database
- **Real-time subscriptions** - Live data synchronization
- **Authentication** - Built-in user management

### State Management & Architecture

- **[Riverpod](https://riverpod.dev/)** 2.4.9 - Reactive state management
- **[riverpod_annotation](https://pub.dev/packages/riverpod_annotation)** 2.3.3 - Code generation
  annotations
- **[riverpod_generator](https://pub.dev/packages/riverpod_generator)** 2.3.9 - Provider code
  generation

### NFC & Hardware

- **[nfc_manager](https://pub.dev/packages/nfc_manager)** 4.0.2 - NFC tag reading and writing
- **NFC Operation Logging** - Enterprise-level operation tracking
- **Native Android/iOS NFC** - Platform-specific NFC implementations
- **Hardware Security** - Secure element integration where available

### Brazilian Localization

- **[all_validations_br](https://pub.dev/packages/all_validations_br)** 3.0.0 - Brazilian document
  validation
- **[search_cep](https://pub.dev/packages/search_cep)** 4.0.2 - Brazilian postal code API
  integration
- **Portuguese Localization** - Full app translation and formatting

### Data & Storage

- **[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)** 9.0.0 - Encrypted
  key-value storage
- **[shared_preferences](https://pub.dev/packages/shared_preferences)** 2.2.2 - Local preferences
  storage
- **[http](https://pub.dev/packages/http)** 1.1.0 - HTTP client for API calls

### Development Tools

- **[build_runner](https://pub.dev/packages/build_runner)** 2.4.7 - Code generation automation
- **[json_annotation](https://pub.dev/packages/json_annotation)** 4.8.1 - JSON serialization
  annotations
- **[json_serializable](https://pub.dev/packages/json_serializable)** 6.7.1 - JSON code generation
- **[flutter_lints](https://pub.dev/packages/flutter_lints)** 5.0.0 - Dart/Flutter linting rules

<br>

## :package: Installation

### Prerequisites

- **[Flutter SDK](https://flutter.dev/docs/get-started/install)** 3.9.0+
- **[Android Studio](https://developer.android.com/studio)** or *
  *[VS Code](https://code.visualstudio.com/)**
- **[Git](https://git-scm.com/)**
- **NFC-enabled Device** (Android/iOS with NFC support)

### Quick Start

1. **Clone the repository**

```bash
git clone https://github.com/gabrielmaialva33/nfc-guard.git
cd nfc-guard
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Generate code**

```bash
flutter packages pub run build_runner build
```

4. **Check Flutter setup**

```bash
flutter doctor
```

5. **Run on device**

```bash
# Android device (NFC required)
flutter run

# iOS device (NFC required)
flutter run -d ios

# Check connected devices
flutter devices
```

6. **Build for production**

```bash
# Android APK
flutter build apk --release

# iOS (requires Xcode and Apple Developer account)
flutter build ios --release
```

<br>

## :gear: Configuration

### NFC Permissions

#### Android

```xml
<!-- Required for NFC functionality -->
<uses-permission android:name="android.permission.NFC" /><uses-feature
android:name="android.hardware.nfc" android:required="true" />

    <!-- Optional: for enhanced NFC features -->
<uses-permission android:name="android.permission.NFC_PREFERRED_PAYMENT_INFO" />
```

#### iOS

```xml
<!-- Info.plist -->
<key>NFCReaderUsageDescription</key><string>This app uses NFC to write secure tags with unique
codes
</string>

    <!-- Required NFC entitlements -->
<key>com.apple.developer.nfc.readersession.formats</key><array>
<string>NDEF</string>
<string>TAG</string>
</array>
```

### Code Generation Setup

1. **Watch for Changes** (Development):

```bash
flutter packages pub run build_runner watch
```

2. **One-time Generation**:

```bash
flutter packages pub run build_runner build
```

3. **Clean and Rebuild**:

```bash
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Environment Configuration

Create necessary configuration files:

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String apiBaseUrl = 'YOUR_API_URL';
  static const String cepApiUrl = 'https://viacep.com.br/ws/';
  static const bool enableDebugMode = false;
}
```

<br>

## :electric_plug: Usage

### Basic Workflow

1. **Launch App** - Open NFCGuard
2. **Authentication** - Enter CPF for Brazilian users
3. **Generate Code** - Create unique 8-character security code
4. **Prepare NFC Tag** - Hold NFC tag ready
5. **Write Tag** - Tap "Write to NFC" and hold tag to device
6. **Verification** - Confirm successful write and code storage

### NFC Tag Writing Process

```bash
# Step-by-step Process:
1. 📱 Open NFCGuard app
2. 🆔 Validate Brazilian CPF
3. 🔐 Generate unique security code
4. 📡 Enable NFC on device
5. 🏷️ Place NFC tag near device
6. ✍️ Write data to tag
7. ✅ Verify successful write
8. 💾 Store usage history
```

### Code Management

**Code Generation**:

- Automatically generates 8-character codes
- Validates uniqueness against stored history
- Prevents code replication and reuse
- Encrypts codes in secure storage

**Code Validation**:

- Real-time validation during generation
- Checks against previously used codes
- Validates format and structure
- Provides instant feedback

**Usage Tracking**:

- Records all generated codes
- Tracks write timestamps
- Prevents duplicate usage
- Maintains audit trail

### Supported NFC Tags

```bash
# Compatible NFC Tag Types:
✅ NTAG213 (180 bytes)
✅ NTAG215 (540 bytes) 
✅ NTAG216 (924 bytes)
✅ Mifare Classic 1K/4K
✅ Mifare Ultralight
✅ ISO14443 Type A/B
✅ FeliCa (Android only)
```

### Brazilian Features

**CPF Validation**:

- Real-time CPF format validation
- Mathematical verification
- Error handling with Portuguese messages
- Integration with user authentication

**CEP Integration**:

- Automatic address lookup
- Postal code validation
- Brazilian address formatting
- Integration with user registration

<br>

## :test_tube: Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/nfc_service_test.dart

# Integration tests (requires device)
flutter test integration_test/
```

### NFC Testing Requirements

- **Physical Device**: NFC functionality requires real hardware
- **NFC Tags**: Various tag types for compatibility testing
- **Test Environment**: Isolated test codes to prevent conflicts
- **Mock Services**: Unit tests with mocked NFC operations

<br>

## :memo: License

This project is under the **MIT** license. See [LICENSE](./LICENSE) for details.

<br>

## :handshake: Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/SecureNFCFeature`)
3. Commit your changes (`git commit -m 'Add secure NFC writing feature'`)
4. Push to the branch (`git push origin feature/SecureNFCFeature`)
5. Open a Pull Request

<br>

## :star: Support

If you find this project helpful, please give it a star ⭐ to help others discover it!

**For support or questions**:

- 📧 Email: [gabrielmaialva33@gmail.com](mailto:gabrielmaialva33@gmail.com)
- 💬 Telegram: [@mrootx](https://t.me/mrootx)
- 🐙 GitHub Issues: [Create an issue](https://github.com/gabrielmaialva33/nfc-guard/issues)

<br>

## :busts_in_silhouette: Author

<p align="center">
  <img src="https://avatars.githubusercontent.com/u/26732067" alt="Maia" width="100">
</p>

Made with ❤️ by **Maia** - Passionate about secure mobile solutions!

- 📧 Email: [gabrielmaialva33@gmail.com](mailto:gabrielmaialva33@gmail.com)
- 💬 Telegram: [@mrootx](https://t.me/mrootx)
- 🐙 GitHub: [@gabrielmaialva33](https://github.com/gabrielmaialva33)

<br>

<p align="center">
  <img src="https://raw.githubusercontent.com/gabrielmaialva33/gabrielmaialva33/master/assets/gray0_ctp_on_line.svg?sanitize=true" />
</p>

<p align="center">
  &copy; 2017-present <a href="https://github.com/gabrielmaialva33/" target="_blank">Maia</a>
</p>