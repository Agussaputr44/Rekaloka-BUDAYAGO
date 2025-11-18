import 'package:dartz/dartz.dart';
import 'package:rekaloka_app/common/failure.dart';
import 'package:rekaloka_app/data/datasources/auth_remote_datasource.dart';
import 'package:rekaloka_app/data/datasources/local/token_local_datasource.dart';
import 'package:rekaloka_app/domain/entities/user.dart';
import 'package:rekaloka_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenLocalDataSource tokenLocalDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenLocalDataSource,
  });

  @override
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final result = await remoteDataSource.register(email, password, name);
      await tokenLocalDataSource.saveToken(result.token);
      return Right(result.user.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final result = await remoteDataSource.login(email, password);
      // Simpan token di sini nanti (shared prefs / secure storage)
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
