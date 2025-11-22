import 'package:dartz/dartz.dart';
import '../../common/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, Unit>> register(
    String email,
    String password,
    String name,
  );
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, Unit>> verifyEmail(String email, String code);
  Future<Either<Failure, User>> getUserProfile();
  // Future<Either<Failure, void>> resendVerificationCode(String email);


  Future<Either<Failure, Unit>> saveRememberMe(String email, bool remember);
  Future<Either<Failure, Map<String, dynamic>>>
  getRememberMeStatus(); 
  Future<Either<Failure, String?>> getToken();
  Future<Either<Failure, Unit>> saveToken(String token);
  Future<Either<Failure, Unit>> clearToken();
  
}
