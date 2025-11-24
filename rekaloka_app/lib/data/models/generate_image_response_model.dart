class GenerateImageResponseModel {
  final String message;
  final String imageUrl;

  GenerateImageResponseModel({
    required this.message,
    required this.imageUrl,
  });

  factory GenerateImageResponseModel.fromJson(Map<String, dynamic> json) {
    return GenerateImageResponseModel(
      // Kunci yang digunakan harus 'imageUrl' sesuai respons API Anda
      imageUrl: json['imageUrl'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'imageUrl': imageUrl,
    };
  }
}