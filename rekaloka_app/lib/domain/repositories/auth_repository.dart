import 'package:dartz/dartz.dart';
import '../../common/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> register(String email, String password, String name);
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> verifyEmail(String email, String code);
  Future<Either<Failure, User>> getUserProfile();
  // Future<Either<Failure, void>> resendVerificationCode(String email);
  

}