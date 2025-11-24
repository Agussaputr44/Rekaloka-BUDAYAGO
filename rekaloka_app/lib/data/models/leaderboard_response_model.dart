
// Model untuk membungkus respons API (jika server mengirim { "data": [...] })
import 'leaderboard_model.dart';

class LeaderboardResponseModel {
  final String message;
  final List<LeaderboardModel> data;

  LeaderboardResponseModel({
    required this.message,
    required this.data,
  });

  factory LeaderboardResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] as List<dynamic>;

    final List<LeaderboardModel> entries = dataList
        .map((e) => LeaderboardModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return LeaderboardResponseModel(
      message: json['message'] as String,
      data: entries,
    );
  }
}