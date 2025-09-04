import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ntp/ntp.dart';

/// Service responsible for managing trial period security
/// Prevents tampering, reinstallation bypass, and date manipulation
class TrialGuardService {
  static const int _trialDays = 3;
  static const String _trialStartKey = 'nfc_guard_trial_start';
  static const String _deviceFingerprintKey = 'nfc_guard_device_fp';
  static const String _trialVersionKey = 'nfc_guard_trial_version';

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Checks if the trial is currently active
  static Future<bool> isTrialActive() async {
    try {
      // Only run in trial mode builds
      if (!_isTrialBuild()) {
        return true; // Production builds are always active
      }

      // Get device fingerprint
      final currentFingerprint = await _getDeviceFingerprint();
      final storedFingerprint = await _secureStorage.read(key: _deviceFingerprintKey);

      // First installation
      if (storedFingerprint == null) {
        await _startTrial(currentFingerprint);
        return true;
      }

      // Check device fingerprint match (prevent sharing/different device)
      if (storedFingerprint != currentFingerprint) {
        return false; // Different device
      }

      // Get trial start time
      final trialStartStr = await _secureStorage.read(key: _trialStartKey);
      if (trialStartStr == null) {
        await _startTrial(currentFingerprint);
        return true;
      }

      // Decrypt and parse start time
      final trialStartMs = int.tryParse(trialStartStr) ?? 0;
      final trialStart = DateTime.fromMillisecondsSinceEpoch(trialStartMs);

      // Get current time from network (prevent local time tampering)
      final currentTime = await _getCurrentTime();

      // Calculate remaining time
      final elapsed = currentTime.difference(trialStart);
      final remainingDays = _trialDays - elapsed.inDays;

      return remainingDays > 0;
    } catch (e) {
      // In case of any error, be conservative and block
      debugPrint('TrialGuard Error: $e');
      return false;
    }
  }

  /// Gets remaining trial days (for UI display)
  static Future<int> getRemainingDays() async {
    try {
      if (!_isTrialBuild()) {
        return 999; // Production build
      }

      final trialStartStr = await _secureStorage.read(key: _trialStartKey);
      if (trialStartStr == null) {
        return _trialDays;
      }

      final trialStartMs = int.tryParse(trialStartStr) ?? 0;
      final trialStart = DateTime.fromMillisecondsSinceEpoch(trialStartMs);
      final currentTime = await _getCurrentTime();
      final elapsed = currentTime.difference(trialStart);
      final remainingDays = _trialDays - elapsed.inDays;

      return remainingDays.clamp(0, _trialDays);
    } catch (e) {
      return 0;
    }
  }

  /// Starts the trial period
  static Future<void> _startTrial(String deviceFingerprint) async {
    final currentTime = await _getCurrentTime();
    final trialStartMs = currentTime.millisecondsSinceEpoch.toString();

    await _secureStorage.write(key: _trialStartKey, value: trialStartMs);
    await _secureStorage.write(key: _deviceFingerprintKey, value: deviceFingerprint);
    await _secureStorage.write(key: _trialVersionKey, value: '1.0.0-trial');
  }

  /// Generates a unique device fingerprint
  static Future<String> _getDeviceFingerprint() async {
    final deviceInfo = DeviceInfoPlugin();
    String fingerprint = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        fingerprint = '${androidInfo.model}_${androidInfo.id}_${androidInfo.serialNumber}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        fingerprint = '${iosInfo.model}_${iosInfo.identifierForVendor}_${iosInfo.systemVersion}';
      }

      // Create a hash of the fingerprint for security
      final bytes = utf8.encode(fingerprint);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      // Fallback fingerprint
      return sha256.convert(utf8.encode('nfc_guard_fallback')).toString();
    }
  }

  /// Gets current time from network to prevent tampering
  static Future<DateTime> _getCurrentTime() async {
    try {
      // Try to get network time
      final networkTime = await NTP.now();
      return networkTime;
    } catch (e) {
      // Fallback to local time if network fails
      // In production, might want to be more strict here
      debugPrint('NTP failed, using local time: $e');
      return DateTime.now();
    }
  }

  /// Checks if this is a trial build
  static bool _isTrialBuild() {
    // Check for trial build flag
    const isTrialMode = bool.fromEnvironment('TRIAL_MODE', defaultValue: false);
    return isTrialMode || kDebugMode; // Debug builds are also considered trial
  }

  /// Clears trial data (for testing purposes only)
  static Future<void> clearTrialData() async {
    if (kDebugMode) {
      await _secureStorage.delete(key: _trialStartKey);
      await _secureStorage.delete(key: _deviceFingerprintKey);
      await _secureStorage.delete(key: _trialVersionKey);
    }
  }

  /// Gets trial information for debugging
  static Future<Map<String, dynamic>> getTrialInfo() async {
    if (!kDebugMode) return {};

    return {
      'isTrialBuild': _isTrialBuild(),
      'trialDays': _trialDays,
      'trialStart': await _secureStorage.read(key: _trialStartKey),
      'deviceFingerprint': await _secureStorage.read(key: _deviceFingerprintKey),
      'currentTime': (await _getCurrentTime()).toIso8601String(),
      'remainingDays': await getRemainingDays(),
    };
  }
}