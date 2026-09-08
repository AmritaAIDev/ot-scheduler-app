import 'package:shared_preferences/shared_preferences.dart';

/// Persists the logged-in user's session across browser reloads.
///
/// Flutter Web has no server-side session of its own — before this class
/// existed, the JWT and user identity returned at login were held only in
/// local variables, so a browser refresh restarted the app with no way to
/// know a user was ever authenticated, and it fell back to the login screen
/// (see docs/PRD.md Gap #2). Saving the session here and checking for it on
/// app boot (see main.dart) fixes that without changing how login itself
/// works.
class Session {
  final String accessToken;
  final String refreshToken;
  final String userType;
  final String userName;
  final String userEmail;
  final String userId;

  const Session({
    required this.accessToken,
    required this.refreshToken,
    required this.userType,
    required this.userName,
    required this.userEmail,
    required this.userId,
  });
}

class SessionManager {
  static const _keyAccessToken = 'session_access_token';
  static const _keyRefreshToken = 'session_refresh_token';
  static const _keyUserType = 'session_user_type';
  static const _keyUserName = 'session_user_name';
  static const _keyUserEmail = 'session_user_email';
  static const _keyUserId = 'session_user_id';

  static Future<void> save({
    required String accessToken,
    required String refreshToken,
    required String userType,
    required String userName,
    required String userEmail,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
    await prefs.setString(_keyUserType, userType);
    await prefs.setString(_keyUserName, userName);
    await prefs.setString(_keyUserEmail, userEmail);
    await prefs.setString(_keyUserId, userId);
  }

  /// Returns the saved session, or null if the user never logged in (or has
  /// since been signed out) on this browser.
  static Future<Session?> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString(_keyUserType);
    final accessToken = prefs.getString(_keyAccessToken);
    if (userType == null || userType.isEmpty || accessToken == null || accessToken.isEmpty) {
      return null;
    }
    return Session(
      accessToken: accessToken,
      refreshToken: prefs.getString(_keyRefreshToken) ?? '',
      userType: userType,
      userName: prefs.getString(_keyUserName) ?? '',
      userEmail: prefs.getString(_keyUserEmail) ?? '',
      userId: prefs.getString(_keyUserId) ?? '',
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserType);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserId);
  }
}
