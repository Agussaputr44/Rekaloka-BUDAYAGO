import 'package:dartz/dartz.dart';
import 'package:rekaloka_app/domain/entities/user.dart';
import 'package:rekaloka_app/domain/repositories/auth_repository.dart';

import '../../../common/failure.dart';

class GetUserProfile {
  final AuthRepository repository;

  GetUserProfile(this.repository);

  Future<Either<Failure, User>> execute() {
    return repository.getUserProfile();
  }
}
