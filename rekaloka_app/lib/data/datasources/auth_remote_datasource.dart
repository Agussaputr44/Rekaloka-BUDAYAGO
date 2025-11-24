import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/register_response_model.dart';
import 'local/auth_local_datasource.dart';
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
  Future<UserModel> getUserProfile(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthLocalDatasource authLocalDatasource;
  final http.Client client;
  final String authUrl = 'https://7154edf69811.ngrok-free.app/api/auth';
  
  final String profileUrl =
      'https://7154edf69811.ngrok-free.app/api/profile';

  AuthRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDatasource,
  });

  Map<String, String> _authHeaders() {
    final token = authLocalDatasource.getToken();
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
      Uri.parse('$authUrl/register'),
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
    final response = await client.post(
      Uri.parse('$authUrl/login'),
      headers: _authHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );

    final String responseBody = response.body;

    if (response.statusCode == 200) {
      if (responseBody.isEmpty || responseBody == 'null') {
        throw Exception('Login sukses (200 OK), tetapi data respons kosong.');
      }

      final json = jsonDecode(responseBody);

      authLocalDatasource.saveToken(json['data']['token'] as String);

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

      throw Exception(errorMessage);
    }
  }

  @override
  Future<void> verifyEmail(String email, String code) async {
    final response = await client.post(
      Uri.parse('$authUrl/verify'),
      headers: _authHeaders(),
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Verification failed');
    }
  }

  @override
  Future<UserModel> getUserProfile(String token) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await client.get(
      Uri.parse(profileUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json.containsKey('data') && json['data'] != null) {
        return UserModel.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        return UserModel.fromJson(json as Map<String, dynamic>);
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Token otorisasi tidak valid atau kadaluarsa.');
    } else {
      throw Exception(
        'Gagal memuat profil (Status ${response.statusCode}): ${response.body}',
      );
    }
  }
}
