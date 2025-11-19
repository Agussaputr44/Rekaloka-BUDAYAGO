class RegisterResponseModel {
    final String message;
    final String userId;

    RegisterResponseModel({required this.message, required this.userId});

    factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
        return RegisterResponseModel(
            message: json['message'] ?? '',
            userId: json['userId'] ?? '',
        );
    }
}