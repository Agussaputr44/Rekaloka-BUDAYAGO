import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDatasource {
  // --- Metode Token yang Sudah Ada ---
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  
  // --- Metode Remember Me yang Sudah Ada ---
  Future<void> saveRememberMe(String email, bool remember);
  Future<Map<String, dynamic>> getRememberMeStatus();
  
  // --- BARU: Metode User ID ---
  Future<void> saveUserId(String userId);
  String? getUserId(); // Ubah ke sinkron (String?) karena SharedPreferences adalah sinkron
  Future<void> clearUserId(); // Tambahkan clear user ID
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final SharedPreferences prefs;
  
  // --- Konstanta Keys ---
  static const String _key = 'auth_token';
  static const String _keyRememberEmail = 'remember_email';
  static const String _keyRememberMeStatus = 'remember_me_status';
  static const String _keyUserId = 'user_id'; // Kunci baru untuk User ID

  AuthLocalDatasourceImpl({required this.prefs});

  // ======================================================
  // Implementasi Token (Tidak Berubah)
  // ======================================================

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
  
  // ======================================================
  // Implementasi Remember Me (Tidak Berubah)
  // ======================================================

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

  // ======================================================
  // BARU: Implementasi User ID
  // ======================================================
  
  @override
  Future<void> saveUserId(String userId) async {
    // ID harus disimpan saat login sukses/token disimpan
    await prefs.setString(_keyUserId, userId);
  }

  @override
  String? getUserId() {
    // Mengambil userId secara sinkron karena SharedPreferences bersifat sinkron
    return prefs.getString(_keyUserId);
  }
  
  @override
  Future<void> clearUserId() async {
    // Hapus ID saat logout
    await prefs.remove(_keyUserId);
  }
}