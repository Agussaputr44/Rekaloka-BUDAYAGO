import 'user_model.dart';

class LoginResponseModel {
  final String? message;
  final String token;
  final UserModel user;

  LoginResponseModel({this.message, required this.token, required this.user});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    if (data == null) {
      throw FormatException('Response data is missing or null.');
    }

    final String? token = data['token'] as String?;
    final Map<String, dynamic>? userJson =
        data['user'] as Map<String, dynamic>?;

    if (token == null) {
      throw FormatException('Token field is missing in data object.');
    }
    if (userJson == null) {
      throw FormatException('User object is missing in data object.');
    }

    return LoginResponseModel(
      message: json['message'] as String?,

      token: token,

      user: UserModel.fromJson(userJson),
    );
  }
}
