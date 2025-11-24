import 'package:flutter/material.dart';
import '../../domain/usecases/ai/text_to_image.dart';

class AiNotifier extends ChangeNotifier {
  final TextToImage textToImageUseCase;

  AiNotifier({required this.textToImageUseCase}); 

  String? imageUrl;
  bool loading = false;
  String? errorMessage;

  void generateImage(String prompt) async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    final result = await textToImageUseCase.execute(prompt);

    loading = false;

    result.fold(
      (failure) {
        errorMessage = failure.message;
        imageUrl = null;
      },
      (url) {
        imageUrl = url;
        errorMessage = null;
      },
    );

    notifyListeners();
  }

  void clearState() {
    imageUrl = null;
    errorMessage = null;
    loading = false;
    // Panggil notifyListeners() HANYA jika Anda memanggil clearState() secara independen
  }

}