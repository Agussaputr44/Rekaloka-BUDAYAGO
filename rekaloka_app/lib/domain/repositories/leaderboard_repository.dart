// File: domain/repositories/leaderboard_repository.dart

import 'package:dartz/dartz.dart';

import '../../../common/failure.dart';
import '../entities/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  Future<Either<Failure, List<LeaderboardEntry>>> GetTopLeaderboard(int limit);
}