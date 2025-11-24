// File: domain/usecases/get_top_scores.dart

import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../../entities/leaderboard_entry.dart';
import '../../repositories/leaderboard_repository.dart';

class GetTopLeaderboard {
  final LeaderboardRepository repository;

  GetTopLeaderboard(this.repository);

  Future<Either<Failure, List<LeaderboardEntry>>> execute(int limit) {
    return repository.GetTopLeaderboard(limit);
  }
}