// Di file get_token_use_case.dart
import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../../repositories/auth_repository.dart';

class GetTokenUser {
  final AuthRepository repository;

  GetTokenUser(this.repository);

  Future<Either<Failure, String?>> execute() {
    return repository.getToken();
  }
}