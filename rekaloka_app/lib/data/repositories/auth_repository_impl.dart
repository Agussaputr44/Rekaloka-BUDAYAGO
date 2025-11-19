import 'package:dartz/dartz.dart';
import '../../common/exceptions.dart';
import '../../common/failure.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/local/token_local_datasource.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/register_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenLocalDataSource tokenLocalDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenLocalDataSource,
  });

  @override
  Future<Either<Failure, void>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final RegisterResponseModel result = await remoteDataSource.register(
        email,
        password,
        name,
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final result = await remoteDataSource.login(email, password);
      return Right(result.user.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String email, String code) async {
    try {
      await remoteDataSource.verifyEmail(email, code);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserProfile() async {
    try {
      final result = await remoteDataSource.getUserProfile();
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
