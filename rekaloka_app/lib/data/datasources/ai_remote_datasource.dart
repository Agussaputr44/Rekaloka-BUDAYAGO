import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/generate_image_response_model.dart';

import '../../common/exceptions.dart';
import 'local/auth_local_datasource.dart';

abstract class AiRemoteDataSource {
  Future<String> generateImage(String prompt, String token);
}


class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final AuthLocalDatasource authLocalDatasource;
  final http.Client client;

  AiRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDatasource,
  });

 
  @override
  Future<String> generateImage(String prompt, String token) async {
      final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    const String baseUrl = 'https://7154edf69811.ngrok-free.app/api/ai';
    final response = await client.post(
      Uri.parse('$baseUrl/generate-image'),
      headers: headers,
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final responseDto = GenerateImageResponseModel.fromJson(data);

      return responseDto.imageUrl;
    } else {
      final String reason = response.reasonPhrase ?? 'Unknown Error';
      throw ServerException();
    }
  }
}
