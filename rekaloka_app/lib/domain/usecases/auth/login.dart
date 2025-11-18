import 'package:dartz/dartz.dart';
import 'package:rekaloka_app/domain/entities/user.dart';
import 'package:rekaloka_app/domain/repositories/auth_repository.dart';

import '../../../common/failure.dart';

class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<Either<Failure, User>> execute(String email, String password) {
    return repository.login(email, password);
  }
}
