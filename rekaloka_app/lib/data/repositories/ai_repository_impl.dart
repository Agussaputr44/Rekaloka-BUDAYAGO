import 'package:dartz/dartz.dart';
import '../datasources/ai_remote_datasource.dart';
import '../../domain/repositories/ai_repository.dart';

import '../../common/exceptions.dart';
import '../../common/failure.dart';
import '../datasources/local/auth_local_datasource.dart';

class AiRepositoryImpl implements AiRepository{
  final AiRemoteDataSource remoteDataSource;
  final AuthLocalDatasource authLocalDatasource;

  AiRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDatasource,
  });


  @override
  Future<Either<Failure, String>> generateImage(String prompt) async {
    try {

        final tokenResult = await authLocalDatasource.getToken(); 
        final token = tokenResult; 

        if (token == null || token.isEmpty) {
            print('Error: Token is null or empty');
            return Left(ServerFailure('Token tidak ditemukan.'));
        }
      final imageUrl = await remoteDataSource.generateImage(prompt, token);
      
      return Right(imageUrl);
    } on ServerException {
      return Left(ServerFailure ('Terjadi kesalahan pada server AI.'));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan yang tidak terduga: ${e.toString()}'));
    }
  }
}