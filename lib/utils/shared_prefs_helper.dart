import 'package:shared_preferences/shared_preferences.dart';

/// **SharedPrefsHelper Class**
/// Handles storing and retrieving user data using SharedPreferences.
class SharedPrefsHelper {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';

  /// **Saves user login state**
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  /// **Checks if the user is logged in**
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// **Saves user details (name & email)**
  static Future<void> saveUserDetails(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
  }

  /// **Retrieves stored user name**
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'User';
  }

  /// **Retrieves stored user email**
  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey) ?? 'user@example.com';
  }

  /// **Clears all user data (Logout)**
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
