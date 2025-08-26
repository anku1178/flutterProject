import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _cartItemsKey = 'cart_items';
  static const String _themePreferenceKey = 'theme_preference';
  static const String _notificationEnabledKey = 'notification_enabled';
  static const String _languageKey = 'language';
  static const String _lastLoginDateKey = 'last_login_date';
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    assert(
        _prefs != null, 'StorageService not initialized. Call init() first.');
    return _prefs!;
  }

  // User Authentication
  Future<void> saveUser(User user) async {
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_lastLoginDateKey, DateTime.now().toIso8601String());
  }

  User? getUser() {
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        return User.fromJson(jsonDecode(userJson));
      } catch (e) {
        // Handle JSON decode error gracefully
        clearUser();
        return null;
      }
    }
    return null;
  }

  bool isLoggedIn() {
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> clearUser() async {
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_lastLoginDateKey);
  }

  DateTime? getLastLoginDate() {
    final dateString = prefs.getString(_lastLoginDateKey);
    if (dateString != null) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Onboarding
  Future<void> setOnboardingCompleted(bool completed) async {
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  bool isOnboardingCompleted() {
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  // Cart Management
  Future<void> saveCartItems(List<CartItem> items) async {
    final cartJson = items.map((item) => item.toJson()).toList();
    await prefs.setString(_cartItemsKey, jsonEncode(cartJson));
  }

  List<CartItem> getCartItems() {
    final cartJson = prefs.getString(_cartItemsKey);
    if (cartJson != null) {
      try {
        final List<dynamic> itemsList = jsonDecode(cartJson);
        return itemsList.map((item) => CartItem.fromJson(item)).toList();
      } catch (e) {
        // Handle JSON decode error gracefully
        clearCartItems();
        return [];
      }
    }
    return [];
  }

  Future<void> clearCartItems() async {
    await prefs.remove(_cartItemsKey);
  }

  // App Settings
  Future<void> setThemePreference(String theme) async {
    await prefs.setString(_themePreferenceKey, theme);
  }

  String getThemePreference() {
    return prefs.getString(_themePreferenceKey) ?? 'light';
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    await prefs.setBool(_notificationEnabledKey, enabled);
  }

  bool isNotificationEnabled() {
    return prefs.getBool(_notificationEnabledKey) ?? true;
  }

  Future<void> setLanguage(String language) async {
    await prefs.setString(_languageKey, language);
  }

  String getLanguage() {
    return prefs.getString(_languageKey) ?? 'en';
  }

  // Auth token methods for API integration
  Future<void> saveAuthToken(String token) async {
    await prefs.setString(_authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    return prefs.getString(_authTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await prefs.setString(_refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> clearAuthTokens() async {
    await prefs.remove(_authTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // Clear all data (for logout or reset)
  Future<void> clearAllData() async {
    await prefs.clear();
  }

  // Utility method to check if user data exists and is valid
  bool hasValidUserData() {
    try {
      final user = getUser();
      return user != null && isLoggedIn();
    } catch (e) {
      return false;
    }
  }
}
