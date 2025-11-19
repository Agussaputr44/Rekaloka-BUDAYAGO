import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/register_response_model.dart';
import 'local/token_local_datasource.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponseModel> register(
    String email,
    String password,
    String name,
  );
  Future<LoginResponseModel> login(String email, String password);
  Future<void> verifyEmail(String email, String code);
  Future<UserModel> getUserProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final TokenLocalDataSource tokenLocalDataSource;
  final http.Client client;
  final String baseUrl = 'https://rekaloka-api2.vercel.app/api/auth';

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.tokenLocalDataSource,
  });
  Map<String, String> _authHeaders() {
    final token = tokenLocalDataSource.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<RegisterResponseModel> register(
    String email,
    String password,
    String name,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/register'),
      headers: _authHeaders(),
      body: jsonEncode({
        'username': name,
        'email': email,
        'password': password,
      }),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return RegisterResponseModel.fromJson(json);
    } else {
      throw Exception(json['message'] ?? 'Registration failed');
    }
  }

  @override
  Future<LoginResponseModel> login(String email, String password) async {
    print('DEBUG: [Login] Request URL: $baseUrl/login');
    print(
      'DEBUG: [Login] Request Body: ${jsonEncode({'email': email, 'password': password})}',
    );

    final response = await client.post(
      Uri.parse('$baseUrl/login'),
      headers: _authHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('DEBUG: [Login] Response Status Code: ${response.statusCode}');
    print('DEBUG: [Login] Response Body: ${response.body}');

    final String responseBody = response.body; 

    if (response.statusCode == 200) {
      if (responseBody.isEmpty || responseBody == 'null') {
        throw Exception('Login sukses (200 OK), tetapi data respons kosong.');
      }

      final json = jsonDecode(responseBody);

      print('DEBUG: [Login] Parsing LoginResponseModel...');
      return LoginResponseModel.fromJson(json);
    } else {
      String errorMessage = 'Login failed';

      if (responseBody.isNotEmpty && responseBody != 'null') {
        try {
          final json = jsonDecode(responseBody);

          if (json.containsKey('message') && json['message'] is String) {
            errorMessage = json['message'] as String;
          } else if (json.containsKey('error') && json['error'] is String) {
            errorMessage = json['error'] as String;
          } else if (json.containsKey('errors') && json['errors'] is Map) {
            errorMessage = (json['errors'] as Map).values
                .expand((e) => e)
                .join(', ');
          }
        } catch (_) {
          errorMessage =
              'Login failed (Status ${response.statusCode}): Invalid error format.';
        }
      }

      print('DEBUG: [Login] Throwing Exception: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  @override
  Future<void> verifyEmail(String email, String code) async {
    print('DEBUG: Verification req: $email, $code');

    final response = await client.post(
      Uri.parse('$baseUrl/verify'),
      headers: _authHeaders(),
      body: jsonEncode({'email': email, 'code': code}),
    );

    // --- DEBUGGING START ---
    print('DEBUG: Verification Status Code: ${response.statusCode}');
    print('DEBUG: Verification Response Body: ${response.body}');
    // --- DEBUGGING END ---

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Verification failed');
    }
  }

  @override
  Future<UserModel> getUserProfile() async {
    final response = await client.get(
      Uri.parse('$baseUrl/user'),
      headers: _authHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserModel.fromJson(json['data'] ?? json);
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
