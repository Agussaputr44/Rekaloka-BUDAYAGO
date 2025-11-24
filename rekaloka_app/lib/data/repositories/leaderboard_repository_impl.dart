// File: data/repositories/leaderboard_repository_impl.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart'; // HAPUS: Tidak lagi digunakan

import '../../../common/failure.dart'; // Import kelas Failure
import '../../../common/exceptions.dart'; // Import kelas Exception (ServerException, dll.)
import '../../domain/repositories/leaderboard_repository.dart'; // Import interface
import '../../domain/entities/leaderboard_entry.dart';
import '../datasources/leaderboard_remote_datasource.dart';
import '../datasources/local/auth_local_datasource.dart'; // Import entitas

class LeaderboardRepositoryImpl implements LeaderboardRepository {

  final LeaderboardRemoteDataSource remoteDataSource;
  final AuthLocalDatasource authLocalDatasource; 

  LeaderboardRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDatasource,
  });

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> GetTopLeaderboard(int limit) async {
    try {
      final tokenResult = await authLocalDatasource.getToken(); 
        final token = tokenResult; 

        if (token == null || token.isEmpty) {
            return Left(ServerFailure('Token tidak ditemukan.'));
        }
      
      final resultModel = await remoteDataSource.fetchTopLeaderboard(limit, token);
      
      final entries = resultModel.map((model) => model.toEntity()).toList();
      
      return Right(entries);
      
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString())); 
      
    } on SocketException {
      return Left(ConnectionFailure('Gagal terhubung ke internet.')); 
      
    } on Exception catch (e) {
      return Left(ServerFailure('Terjadi kesalahan tidak terduga: ${e.toString()}'));
    }
  }
}