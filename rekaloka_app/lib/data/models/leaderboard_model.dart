// File: data/models/leaderboard_model.dart

import '../../domain/entities/leaderboard_entry.dart';

class LeaderboardModel {
  final int rank;
  final String id;
  final String username;
  final int level;
  final int exp;
  final List<String> badges; // Mengharap List of Strings (nama badge)

  const LeaderboardModel({
    required this.rank,
    required this.id,
    required this.username,
    required this.level,
    required this.exp,
    required this.badges,
  });

  // Logika Konversi ke Domain Entitas (toEntity)
  LeaderboardEntry toEntity() {
    return LeaderboardEntry(
      rank: rank,
      id: id,
      username: username,
      level: level,
      exp: exp,
      badges: badges,
    );
  }

  // Logika Parsing dari JSON (fromJson)
  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawBadges = json['badges'] as List<dynamic>? ?? [];

    // FIX KRITIS: Mengonversi List<Map<String, dynamic>> menjadi List<String> (hanya mengambil 'name')
    final List<String> badgesList = rawBadges
        .whereType<Map<String, dynamic>>() 
        .map((item) => item['name']?.toString() ?? 'Unknown Badge')
        .toList();

    return LeaderboardModel(
      rank: json['rank'] as int,
      id: json['id'] as String,
      username: json['username'] as String,
      level: json['level'] as int,
      exp: json['exp'] as int,
      badges: badgesList, // Sekarang berisi List<String>
    );
  }
  
  // Method toJson (Opsional, untuk debugging atau mengirim data keluar)
  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'id': id,
      'username': username,
      'level': level,
      'exp': exp,
      'badges': badges,
    };
  }
}
