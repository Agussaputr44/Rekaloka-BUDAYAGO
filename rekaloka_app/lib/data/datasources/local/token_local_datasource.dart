
import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

class TokenLocalDataSourceImpl implements TokenLocalDataSource {
  final SharedPreferences prefs;
  static const String _key = 'auth_token';

  TokenLocalDataSourceImpl({required this.prefs});

  @override
  Future<void> saveToken(String token) async {
    await prefs.setString(_key, token);
  }

  @override
  Future<String?> getToken() async {
    return prefs.getString(_key);
  }

  @override
  Future<void> clearToken() async {
    await prefs.remove(_key);
  }
}