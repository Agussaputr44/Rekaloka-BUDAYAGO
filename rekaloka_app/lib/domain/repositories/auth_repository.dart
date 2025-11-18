import 'package:dartz/dartz.dart';
import 'package:rekaloka_app/common/failure.dart';
import 'package:rekaloka_app/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> register(String email, String password, String name);
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> verifyEmail(String email, String code);
  Future<Either<Failure, User>> getUserProfile();
  // Future<Either<Failure, void>> resendVerificationCode(String email);
  

}