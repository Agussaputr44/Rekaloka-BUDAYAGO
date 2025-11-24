// File: data/datasources/leaderboard_remote_data_source.dart (Perbaikan Final)

import 'dart:convert';
import 'dart:io'; 
import 'package:http/http.dart' as http;
// Import Models yang dibutuhkan
import '../models/leaderboard_model.dart';
import '../models/leaderboard_response_model.dart'; // Diperlukan untuk kasus respons dibungkus

import '../../common/exceptions.dart'; 
// Asumsi: Konstruktor ServerException TIDAK menerima pesan String, 
// meskipun ini adalah praktik yang buruk.

abstract class LeaderboardRemoteDataSource {
  Future<List<LeaderboardModel>> fetchTopLeaderboard(int limit, String token);
}

class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'https://7154edf69811.ngrok-free.app/api';

  LeaderboardRemoteDataSourceImpl({required this.client});

  @override
  Future<List<LeaderboardModel>> fetchTopLeaderboard(int limit, String token) async {
    final url = Uri.parse('$baseUrl/leaderboard?limit=$limit'); 
    

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // --- DEBUGGING: Tampilkan status dan body mentah di konsol ---
      print('DEBUG API: Status Code: ${response.statusCode}');
      print('DEBUG API: Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      
      // 1. Cek Status Code 200
      if (response.statusCode == 200) {
        final dynamic decodedJson = json.decode(response.body); 
        
        // Kasus 1: Respons adalah List Mentah (Raw List)
        if (decodedJson is List) {
           print('Leaderboard data fetched successfully (RAW LIST).');
           final List<LeaderboardModel> entries = decodedJson
               .map((e) => LeaderboardModel.fromJson(e as Map<String, dynamic>))
               .toList();
           return entries;
        }
        
        // Kasus 2: Respons adalah Map yang Dibungkus ({ "data": [...] })
        if (decodedJson is Map<String, dynamic> && decodedJson.containsKey('data')) {
            final responseModel = LeaderboardResponseModel.fromJson(decodedJson);
            print('Leaderboard data fetched successfully (WRAPPED). ${responseModel.data.length} entries retrieved.'); 
            return responseModel.data;
        }

        // Jika respons 200 tapi format JSON tidak valid
        print('ERROR API: Respons 200 tapi format JSON tidak valid (Bukan List/Map dengan "data").');
        throw  ServerException(); // Throw kosong

      } else if (response.statusCode == 403) {
        print('ERROR API: Akses ditolak (403). Token tidak valid atau tidak memiliki izin.');
        throw  ServerException(); 
      } else {
        // Ambil pesan error dari body jika tersedia
        String errorMessage = 'Gagal mengambil leaderboard. Status: ${response.statusCode}';
        
        try {
          final errorJson = json.decode(response.body);
          if (errorJson['message'] != null) {
            errorMessage = errorJson['message'];
          }
        } catch (_) {
          // Abaikan jika body bukan JSON
        }
        
        print('ERROR API: Status ${response.statusCode}. Pesan: $errorMessage');
        throw  ServerException();
      }

    // 2. Tangani Error Jaringan (SocketException)
    } on SocketException {
      print('ERROR API: SocketException. Tidak ada koneksi internet.');
      throw  ServerException(); 
    } catch (e) {
      // Tangani error parsing atau error tak terduga
      print('ERROR API: Terjadi kesalahan tak terduga: ${e.toString()}'); 
      throw  ServerException(); 
    }
  }
}