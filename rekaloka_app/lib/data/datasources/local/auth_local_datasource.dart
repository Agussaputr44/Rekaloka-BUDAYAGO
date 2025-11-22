import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDatasource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> saveRememberMe(String email, bool remember);
  Future<Map<String, dynamic>> getRememberMeStatus();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final SharedPreferences prefs;
  static const String _key = 'auth_token';
  static const String _keyRememberEmail = 'remember_email';
  static const String _keyRememberMeStatus = 'remember_me_status';

  AuthLocalDatasourceImpl({required this.prefs});

  @override
  Future<void> saveToken(String token) async {
    await prefs.setString(_key, token);
  }

  @override
  Future<String?> getToken() async {
    final token = prefs.getString(_key);
    return token;
  }

  @override
  Future<void> clearToken() async {
    await prefs.remove(_key);
  }

  @override
  Future<void> saveRememberMe(String email, bool remember) async {
    await prefs.setBool(_keyRememberMeStatus, remember);
    if (remember) {
      await prefs.setString(_keyRememberEmail, email);
    } else {
      await prefs.remove(_keyRememberEmail);
    }
  }

  @override
  Future<Map<String, dynamic>> getRememberMeStatus() async {
    final status = prefs.getBool(_keyRememberMeStatus) ?? false;
    final email = prefs.getString(_keyRememberEmail);
    return {'status': status, 'email': email};
  }
}