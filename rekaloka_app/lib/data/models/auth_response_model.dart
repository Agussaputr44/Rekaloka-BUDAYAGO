import 'package:rekaloka_app/data/models/user_model.dart';

class AuthResponseModel {
  String? message;
  final String token;
  final UserModel user;

  AuthResponseModel({message, required this.token, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      message: json['message'],
      token: json['token'] ?? json['access_token'] ?? '',
      user: UserModel.fromJson(json['user']),
    );
  }
}
