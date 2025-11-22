import 'package:dartz/dartz.dart';
import '../../common/exceptions.dart';
import '../../common/failure.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDatasource authLocalDatasource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDatasource,
  });

  @override
  Future<Either<Failure, Unit>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      await remoteDataSource.register(email, password, name);
      return const Right(unit);
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
  Future<Either<Failure, Unit>> verifyEmail(String email, String code) async {
    try {
      await remoteDataSource.verifyEmail(email, code);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserProfile() async {

   try {
        final tokenResult = await authLocalDatasource.getToken(); 
        final token = tokenResult; 

        if (token == null || token.isEmpty) {
            return Left(ServerFailure('Token tidak ditemukan.'));
        }

        final UserModel userModel = await remoteDataSource.getUserProfile(token); 
        
        return Right(userModel.toEntity()); 

    } on Exception catch (e) {
        return Left(ServerFailure(e.toString()));
    }
}

  @override
  Future<Either<Failure, Unit>> saveRememberMe(
    String email,
    bool remember,
  ) async {
    try {
      await authLocalDatasource.saveRememberMe(email, remember);

      return const Right(unit);
    } on Exception catch (e) {
      return Left(DatabaseFailure('Gagal menyimpan status Remember Me: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRememberMeStatus() async {
    try {
      final result = await authLocalDatasource.getRememberMeStatus();
      return Right(result);
    } on Exception {
      return Left(
        DatabaseFailure('Gagal memuat status Remember Me dari lokal.'),
      );
    }
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      final result = await authLocalDatasource.getToken();
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure("Gagal mendapatkan token lokal."));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveToken(String token) async {
    try {
      await authLocalDatasource.saveToken(token);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure("Gagal menyimpan token lokal."));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearToken() async {
    try {
      await authLocalDatasource.clearToken();
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure("Gagal menghapus token lokal."));
    }
  }
}
