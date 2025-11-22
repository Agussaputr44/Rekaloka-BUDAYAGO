// Di file save_token_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:rekaloka_app/domain/repositories/auth_repository.dart';

import '../../../common/failure.dart';

class SaveTokenUser {
  final AuthRepository repository;

  SaveTokenUser(this.repository);

  Future<Either<Failure, Unit>> execute(String token) {
    return repository.saveToken(token);
  }
}