// File: domain/entities/leaderboard_entry.dart

import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  final int rank;
  final String id;
  final String username;
  final int level;
  final int exp;
  final List<String> badges; // Mengharap List of Strings (nama badge)

  const LeaderboardEntry({
    required this.rank,
    required this.id,
    required this.username,
    required this.level,
    required this.exp,
    required this.badges,
  });

  // Metode toMap() ditambahkan di Lapisan Domain untuk memfasilitasi UI mapping
  Map<String, dynamic> toMap() {
    return {
      'rank': rank,
      'id': id,
      'username': username,
      'level': level,
      'exp': exp,
      'badges': badges,
    };
  }

  @override
  List<Object?> get props => [rank, id, username, level, exp, badges];
}