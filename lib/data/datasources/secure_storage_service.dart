import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainItemAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> saveUser(UserModel user) async {
    final userJson = json.encode(user.toJson());
    await _secureStorage.write(key: AppConstants.userDataKey, value: userJson);
  }

  Future<UserModel?> getUser() async {
    final userJson = await _secureStorage.read(key: AppConstants.userDataKey);
    if (userJson == null) return null;
    
    final userMap = json.decode(userJson) as Map<String, dynamic>;
    return UserModel.fromJson(userMap);
  }

  Future<void> saveUsedCodes(List<String> codes) async {
    final codesJson = json.encode(codes);
    await _secureStorage.write(key: AppConstants.usedCodesKey, value: codesJson);
  }

  Future<List<String>> getUsedCodes() async {
    final codesJson = await _secureStorage.read(key: AppConstants.usedCodesKey);
    if (codesJson == null) return [];
    
    final codesList = json.decode(codesJson) as List;
    return codesList.cast<String>();
  }

  Future<void> addUsedCode(String code) async {
    final usedCodes = await getUsedCodes();
    usedCodes.add(code);
    await saveUsedCodes(usedCodes);
  }

  Future<bool> isCodeUsed(String code) async {
    final usedCodes = await getUsedCodes();
    return usedCodes.contains(code);
  }

  Future<void> deleteUser() async {
    await _secureStorage.delete(key: AppConstants.userDataKey);
  }

  Future<void> clearStorage() async {
    await _secureStorage.deleteAll();
  }
}