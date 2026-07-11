import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const _usersKey = 'signed_up_users';
  static const _currentUserKey = 'current_user';
  static const _registrationsKey = 'user_registrations';
  static const _profileNamesKey = 'user_profile_names';
  static const _profileImagePathKey = 'user_profile_images';

  static late SharedPreferences _prefs;
  static String? currentUserEmail;

  static final _emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?" r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$");

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    currentUserEmail = _prefs.getString(_currentUserKey);
  }

  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  static String _normalizeEmail(String email) => email.toLowerCase().trim();

  static Map<String, String> _usersFromPrefs() {
    final usersJson = _prefs.getString(_usersKey);
    if (usersJson == null || usersJson.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(usersJson) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  static Map<String, List<String>> _registrationsFromPrefs() {
    final regsJson = _prefs.getString(_registrationsKey);
    if (regsJson == null || regsJson.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(regsJson) as Map<String, dynamic>;
    return decoded.map((key, value) {
      final list = (value as List).map((item) => item as String).toList();
      return MapEntry(key, list);
    });
  }

  static Map<String, String> _profileNamesFromPrefs() {
    final namesJson = _prefs.getString(_profileNamesKey);
    if (namesJson == null || namesJson.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(namesJson) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  static Map<String, String> _profileImagesFromPrefs() {
    final imagesJson = _prefs.getString(_profileImagePathKey);
    if (imagesJson == null || imagesJson.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(imagesJson) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  static Future<bool> registerUser(String email, String password) async {
    final normalizedEmail = _normalizeEmail(email);
    if (!isValidEmail(normalizedEmail)) return false;

    final users = _usersFromPrefs();
    if (users.containsKey(normalizedEmail)) {
      return false;
    }

    users[normalizedEmail] = password;
    await _prefs.setString(_usersKey, jsonEncode(users));
    return true;
  }

  static bool validateCredentials(String email, String password) {
    final normalizedEmail = _normalizeEmail(email);
    final users = _usersFromPrefs();
    return users[normalizedEmail] == password;
  }

  static Future<bool> signIn(String email, String password) async {
    final normalizedEmail = _normalizeEmail(email);
    if (!validateCredentials(normalizedEmail, password)) return false;
    currentUserEmail = normalizedEmail;
    await _prefs.setString(_currentUserKey, normalizedEmail);
    return true;
  }

  static Future<void> signOut() async {
    currentUserEmail = null;
    await _prefs.remove(_currentUserKey);
  }

  static bool userExists(String email) {
    final normalizedEmail = _normalizeEmail(email);
    final users = _usersFromPrefs();
    return users.containsKey(normalizedEmail);
  }

  static List<String> getRegisteredProgramIds([String? email]) {
    final normalizedEmail = _normalizeEmail(email ?? currentUserEmail ?? '');
    final registrations = _registrationsFromPrefs();
    return registrations[normalizedEmail] ?? [];
  }

  static bool isProgramRegistered(String programId, [String? email]) {
    final ids = getRegisteredProgramIds(email);
    return ids.contains(programId);
  }

  static Future<void> toggleProgramRegistration(String programId, [String? email]) async {
    final normalizedEmail = _normalizeEmail(email ?? currentUserEmail ?? '');
    if (normalizedEmail.isEmpty) return;

    final registrations = _registrationsFromPrefs();
    final ids = List<String>.from(registrations[normalizedEmail] ?? []);
    if (ids.contains(programId)) {
      ids.remove(programId);
    } else {
      ids.add(programId);
    }
    registrations[normalizedEmail] = ids;
    await _prefs.setString(_registrationsKey, jsonEncode(registrations));
  }

  static String get displayName {
    final nameMap = _profileNamesFromPrefs();
    final normalizedEmail = _normalizeEmail(currentUserEmail ?? '');
    if (normalizedEmail.isEmpty) return 'Learner';
    return nameMap[normalizedEmail] ?? _defaultDisplayName(normalizedEmail);
  }

  static String _defaultDisplayName(String email) {
    final localPart = email.split('@').first;
    if (localPart.isEmpty) return 'Learner';
    return localPart[0].toUpperCase() + localPart.substring(1);
  }

  static Future<void> updateDisplayName(String name) async {
    final normalizedEmail = _normalizeEmail(currentUserEmail ?? '');
    if (normalizedEmail.isEmpty) return;
    final nameMap = _profileNamesFromPrefs();
    nameMap[normalizedEmail] = name.trim();
    await _prefs.setString(_profileNamesKey, jsonEncode(nameMap));
  }

  static String? get profileImagePath {
    final imageMap = _profileImagesFromPrefs();
    final normalizedEmail = _normalizeEmail(currentUserEmail ?? '');
    return imageMap[normalizedEmail];
  }

  static Future<void> updateProfileImagePath(String path) async {
    final normalizedEmail = _normalizeEmail(currentUserEmail ?? '');
    if (normalizedEmail.isEmpty) return;
    final imageMap = _profileImagesFromPrefs();
    imageMap[normalizedEmail] = path;
    await _prefs.setString(_profileImagePathKey, jsonEncode(imageMap));
  }
}
