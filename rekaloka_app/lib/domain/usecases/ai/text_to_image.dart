import 'package:dartz/dartz.dart';
import '../../repositories/ai_repository.dart';

import '../../../common/failure.dart';

class TextToImage {
  final AiRepository repository;

  TextToImage(this.repository);

  Future<Either<Failure, String>> execute(String prompt) {
    return repository.generateImage(prompt);
  }
}