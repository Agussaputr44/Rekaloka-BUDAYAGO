// File: presentation/provider/leaderboard_notifier.dart

import 'package:flutter/material.dart';
import 'package:rekaloka_app/domain/usecases/leaderboard/get_top_leaderboard.dart';

import '../../../common/state.dart';
import '../../domain/entities/leaderboard_entry.dart';

class LeaderboardNotifier extends ChangeNotifier {
  final GetTopLeaderboard getTopScoresUseCase;

  LeaderboardNotifier(this.getTopScoresUseCase);

  RequestState _state = RequestState.Empty;
  List<LeaderboardEntry> _entries = [];
  String _message = '';

  RequestState get state => _state;
  List<LeaderboardEntry> get entries => _entries;
  String get message => _message;

  Future<void> fetchLeaderboard(int limit) async {
    print('🔵 NOTIFIER: Starting fetch for $limit entries...');
    
    _state = RequestState.Loading;
    notifyListeners();

    final result = await getTopScoresUseCase.execute(limit);

    result.fold(
      (failure) {
        print('🔴 NOTIFIER: Fetch FAILED - ${failure.message}');
        _state = RequestState.Error;
        _message = failure.message ?? 'Terjadi kesalahan saat mengambil data leaderboard.';
        _entries = []; // Clear entries on error
        notifyListeners(); // ✅ PENTING: Panggil notifyListeners di sini
      },
      (data) {
        print('🟢 NOTIFIER: Fetch SUCCESS - ${data.length} entries received');
        _entries = data;
        _state = RequestState.Loaded;
        _message = 'Data Leaderboard berhasil dimuat.';
        
        // Debug: Print first entry if available
        if (_entries.isNotEmpty) {
          print('🟢 NOTIFIER: First entry - Rank: ${_entries[0].rank}, Username: ${_entries[0].username}');
        }
        
        notifyListeners(); // ✅ PENTING: Panggil notifyListeners di sini
      },
    );

    // ❌ HAPUS notifyListeners() di luar fold - sudah dipanggil di dalam fold
    print('🔵 NOTIFIER: Fetch completed. Final state: $_state, Entries: ${_entries.length}');
  }

  // Method untuk reset/clear data
  void clearLeaderboard() {
    _entries = [];
    _state = RequestState.Empty;
    _message = '';
    notifyListeners();
  }
}