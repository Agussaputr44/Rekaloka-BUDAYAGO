import 'package:dartz/dartz.dart';
import '../../repositories/auth_repository.dart';

import '../../../common/failure.dart';

class VerifyEmail {
  final AuthRepository repository;

  VerifyEmail(this.repository);

  Future<Either<Failure, void>> execute(String email, String code) {
    return repository.verifyEmail(email, code);
  }
}
