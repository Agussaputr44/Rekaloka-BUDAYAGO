import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rekaloka_app/data/datasources/local/token_local_datasource.dart';
import 'package:rekaloka_app/data/models/auth_response_model.dart';
import 'package:rekaloka_app/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register(
    String email,
    String password,
    String name,
  );
  Future<AuthResponseModel> login(String email, String password);
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
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<AuthResponseModel> register(
    String email,
    String password,
    String name,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/register'),
      headers: _authHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AuthResponseModel.fromJson(json);
    } else {
      throw Exception(json['message'] ?? 'Registration failed');
    }
  }

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/login'),
      headers: _authHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return AuthResponseModel.fromJson(json);
    } else {
      throw Exception(json['message'] ?? 'Login failed');
    }
  }

  @override
  Future<void> verifyEmail(String email, String code) async {
    final response = await client.post(
      Uri.parse('$baseUrl/verify-email'),
      headers: _authHeaders(),
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Verification failed');
    }
  }

  @override
  Future<UserModel> getUserProfile() async {
    final token = 'your_token_here';
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
