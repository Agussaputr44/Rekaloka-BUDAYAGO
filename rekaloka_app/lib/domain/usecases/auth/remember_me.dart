// Di file remember_me_use_case.dart
import 'package:dartz/dartz.dart';

import '../../../common/failure.dart' show Failure;
import '../../repositories/auth_repository.dart';

class RememberMe {
  final AuthRepository repository;

  RememberMe(this.repository);

  Future<Either<Failure, Unit>> saveRememberMe(String email, bool remember) {
    return repository.saveRememberMe(email, remember);
  }

  Future<Either<Failure, Map<String, dynamic>>> getRememberMeStatus() {
    return repository.getRememberMeStatus();
  }
}