import 'package:dartz/dartz.dart';
import 'package:rekaloka_app/domain/entities/user.dart';
import 'package:rekaloka_app/domain/repositories/auth_repository.dart';

import '../../../common/failure.dart';

class Register {
  final AuthRepository repository;

  Register(this.repository);

  Future<Either<Failure, User>> execute(
    String email,
    String password,
    String name,
  ) {
    return repository.register(email, password, name);
  }
}
