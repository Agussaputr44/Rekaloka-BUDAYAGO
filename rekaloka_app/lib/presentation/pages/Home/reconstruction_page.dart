import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'dart:convert'; // Import untuk Base64 decoding
import 'dart:typed_data'; // Import untuk Uint8List

import '../../../common/constants.dart';
import '../../provider/ai_notifier.dart';

// Akses ke GetIt instance
final sl = GetIt.instance;

enum ChatAssetType {
  text,
  image2d,
  model3d,
  error,
}

class ChatMessage {
  final String text;
  final bool isUser;
  final ChatAssetType type;
  final String? assetUrl; // Ini akan berisi Base64 string untuk gambar 2D
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.type = ChatAssetType.text,
    this.assetUrl,
    required this.timestamp,
  });
}

class ReconstructionPage extends StatefulWidget {
  static const ROUTE_NAME = '/reconstruction';
  const ReconstructionPage({super.key});

  @override
  State<ReconstructionPage> createState() => _ReconstructionPageState();
}

class _ReconstructionPageState extends State<ReconstructionPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _showWelcome = true;
  String? _lastPrompt; // Menyimpan prompt terakhir
  String? _lastGeneratedImageUrl; // Menyimpan URL/Base64 dari gambar 2D terakhir

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _start3DSimulation(String imageUrl2D) {
    // Pesan AI: Gambar 2D berhasil, memulai konversi 3D
    setState(() {
      _messages.add(ChatMessage(
        text: 'Gambar 2D berhasil dibuat. Sekarang, Rekaloka akan memulai proses konversi ke Model 3D. Mohon tunggu...',
        isUser: false,
        type: ChatAssetType.text,
        timestamp: DateTime.now(),
      ));
      _messages.add(ChatMessage(
        text: 'Model 3D sedang dibuat...',
        isUser: false,
        type: ChatAssetType.model3d, // Menggunakan model3d type untuk menampilkan indikator loading khusus
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();

    // Simulasi Tahap 2: Konversi 2D ke 3D (Simulasi 3 detik)
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        // Hapus pesan loading 3D
        _messages.removeWhere((msg) => msg.type == ChatAssetType.model3d && msg.text == 'Model 3D sedang dibuat...');

        // Tampilkan hasil Model 3D (menggunakan URL dummy karena konversi 3D belum ada)
        _messages.add(ChatMessage(
          text: 'Model 3D berhasil direkonstruksi dari gambar 2D!',
          isUser: false,
          type: ChatAssetType.model3d,
          assetUrl: 'https://example.com/model-${DateTime.now().microsecondsSinceEpoch}.glb', // URL model 3D dummy
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  void _handleImageGenerationResult(AiNotifier notifier, String prompt) {
    // Cek apakah state AI Notifier sudah berubah dan hasil untuk prompt terakhir sudah tersedia
    // Ini mencegah memproses ulang hasil yang sama
    if (notifier.loading == false && _lastPrompt == prompt) {
      if (notifier.errorMessage != null) {
        // Hapus pesan loading 2D jika ada
        _messages.removeWhere((msg) => msg.text == 'Mengakses AI untuk membuat gambar...');

        // Tampilkan pesan error
        setState(() {
          _messages.add(ChatMessage(
            text: notifier.errorMessage!,
            isUser: false,
            type: ChatAssetType.error,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
        notifier.clearState(); // Reset state setelah menampilkan error
        _lastPrompt = null; // Reset prompt terakhir
      } else if (notifier.imageUrl != null && notifier.imageUrl != _lastGeneratedImageUrl) {
        // ✅ LOGGING: Pastikan kita mendapatkan Base64 String
        print('✅ DEBUG: Gambar 2D berhasil didapatkan (Base64). Panjang: ${notifier.imageUrl!.length} karakter.');

        // Hapus pesan loading 2D jika ada
        _messages.removeWhere((msg) => msg.text == 'Mengakses AI untuk membuat gambar...');

        // Tampilkan hasil Gambar 2D
        setState(() {
          _messages.add(ChatMessage(
            text: 'Gambar 2D untuk "$prompt" berhasil dibuat.',
            isUser: false,
            type: ChatAssetType.image2d,
            assetUrl: notifier.imageUrl, // Ini adalah Base64 String
            timestamp: DateTime.now(),
          ));
          _lastGeneratedImageUrl = notifier.imageUrl; // Simpan untuk mencegah duplikasi
        });
        _scrollToBottom();

        // Lanjutkan ke Tahap 2: Simulasi 3D (gunakan prompt asli, bukan Base64 string)
        _start3DSimulation(prompt); // Atau jika 3D butuh gambar 2D, Anda bisa kirim Base64 string atau URL aslinya

        // Reset state di AiNotifier setelah selesai
        notifier.clearState();
        _lastPrompt = null; // Reset prompt terakhir
      }
    }
  }

  void _sendMessage(AiNotifier notifier) {
    if (_textController.text.trim().isEmpty) return;
    if (notifier.loading) return; // Mencegah kirim saat loading

    final userText = _textController.text;
    _lastPrompt = userText; // Simpan prompt terakhir untuk error handling

    setState(() {
      // 1. Add user message
      _messages.add(ChatMessage(
        text: userText,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _showWelcome = false;
    });

    _textController.clear();
    _isTyping = false;

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());

    // 2. Panggil AI Use Case (Text-to-Image)
    notifier.generateImage(userText);
  }

  @override
  Widget build(BuildContext context) {
    // 3. Watch state dari AiNotifier
    return Consumer<AiNotifier>(
      builder: (context, notifier, child) {
        // Gunakan _handleImageGenerationResult untuk merespon perubahan state notifier
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_lastPrompt != null) {
             _handleImageGenerationResult(notifier, _lastPrompt!);
          }
        });

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Header
              _buildHeader(context),

              // Chat Messages Area
              Expanded(
                child: _showWelcome && _messages.isEmpty
                    ? _buildWelcomeScreen()
                    : _buildChatList(notifier),
              ),

              // Input Field
              _buildInputField(notifier),
            ],
          ),
        );
      },
    );
  }

  // =======================================================
  // UI Components
  // =======================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        20,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/bg_awan.png'),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
        color: kPrimaryBrown.withOpacity(0.7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: kTextWhite,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Rekaloka',
                  style: kHeadingRekaloka.copyWith(
                    color: kTextWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kAccentOrange.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: kTextWhite.withOpacity(0.4),
                width: 2,
              ),
              image: const DecorationImage(
                image: AssetImage('assets/images/bg_awan.png'),
                fit: BoxFit.cover,
                opacity: 0.7, // Tingkatkan opasitas jika diperlukan
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          _buildInstructionCard(),
          const SizedBox(height: 24),
          _buildExamplePrompts(),
        ],
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kPrimaryBrown.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBrown.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Halo! Tuliskan deskripsi objek budaya yang ingin kamu rekonstruksi.',
            textAlign: TextAlign.center,
            style: kSubtitle.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: kPrimaryBrown,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Rekaloka akan mengubah promptmu menjadi model 3D secara otomatis. Semakin detail, semakin akurat hasilnya!',
            textAlign: TextAlign.center,
            style: kBodyText.copyWith(
              fontSize: 13,
              color: kPrimaryBrown.withOpacity(0.7),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamplePrompts() {
    final examples = [
      'Candi Borobudur dengan detail relief',
      'Rumah Gadang Minangkabau',
      'Wayang Kulit Arjuna dengan detail kostum',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Contoh prompt:',
            style: kBodyText.copyWith(
              fontSize: 12,
              color: kPrimaryBrown.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...examples.map((example) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              _textController.text = example;
              setState(() {
                _isTyping = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: kInputFillColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: kPrimaryBrown.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: kAccentOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      example,
                      style: kBodyText.copyWith(
                        fontSize: 13,
                        color: kPrimaryBrown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildChatList(AiNotifier notifier) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildChatBubble(message);
      },
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    // Menampilkan Model 3D Card
    if (message.type == ChatAssetType.model3d && message.assetUrl != null) {
      return _build3DPreviewCard(message);
    }

    // Menampilkan 2D Image Card (Tahap 1 Result)
    if (message.type == ChatAssetType.image2d && message.assetUrl != null) {
      return _build2DImageCard(message); // Akan menggunakan Image.memory sekarang
    }

    // Menampilkan Loading 3D Card (Simulasi Tahap 2)
    if (message.type == ChatAssetType.model3d && message.assetUrl == null) {
      return _buildGeneratingCard(message.text);
    }

    // Menampilkan Error Card
    if (message.type == ChatAssetType.error) {
       return _buildErrorCard(message.text);
    }

    // Menampilkan Text Bubble (Termasuk pesan User dan pesan Loading AI 2D)
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser
              ? kPrimaryBrown
              : kInputFillColor.withOpacity(0.3),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimaryBrown.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: kBodyText.copyWith(
            fontSize: 14,
            color: message.isUser ? kTextWhite : kPrimaryBrown,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratingCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kInputFillColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kAccentOrange.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(kAccentOrange),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text, // Bisa berupa 'Model 3D sedang dibuat...'
            style: kSubtitle.copyWith(
              fontSize: 14,
              color: kPrimaryBrown,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ini mungkin memakan waktu beberapa detik',
            style: kBodyText.copyWith(
              fontSize: 12,
              color: kPrimaryBrown.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kInputFillColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gagal!',
                  style: kSubtitle.copyWith(
                    fontSize: 14,
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: kBodyText.copyWith(
                    fontSize: 13,
                    color: kPrimaryBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MODIFIKASI: Menampilkan Gambar 2D yang Dihasilkan dari Base64
 Widget _build2DImageCard(ChatMessage message) {
   // Pastikan assetUrl tidak null dan merupakan Base64 string yang valid
   if (message.assetUrl == null || message.assetUrl!.isEmpty) {
     return _buildErrorCard('Base64 gambar 2D tidak tersedia.');
   }
   
   // --- START PERBAIKAN BASE64 ---
   String base64String = message.assetUrl!;

   // 1. Hapus header URI Data jika ada (contoh: "data:image/jpeg;base64,")
   if (base64String.contains(',')) {
       base64String = base64String.split(',').last;
       print('DEBUG: Base64 header dihapus.');
   }
   
   // 2. Tambahkan padding jika diperlukan. Base64 harus kelipatan 4.
   while (base64String.length % 4 != 0) {
       base64String += '=';
   }
   // --- END PERBAIKAN BASE64 ---

   Uint8List? imageBytes;
   try {
     // Decode Base64 string yang sudah dibersihkan
     imageBytes = base64Decode(base64String);
   } catch (e) {
     print('ERROR decoding Base64: $e');
     return _buildErrorCard('Gagal mendekode gambar 2D dari Base64. Cek konsol.');
   }

   return Container(
     margin: const EdgeInsets.only(bottom: 12),
     padding: const EdgeInsets.all(16),
     decoration: BoxDecoration(
       color: Colors.white,
       borderRadius: BorderRadius.circular(20),
       border: Border.all(
         color: kPrimaryBrown.withOpacity(0.2),
         width: 1,
       ),
       boxShadow: [
         BoxShadow(
           color: kPrimaryBrown.withOpacity(0.15),
           blurRadius: 15,
           offset: const Offset(0, 4),
         ),
       ],
     ),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Padding(
           padding: const EdgeInsets.only(bottom: 12),
           child: Text(
             message.text, // "Gambar 2D untuk "prompt" berhasil dibuat."
             style: kBodyText.copyWith(
               fontSize: 14,
               color: kPrimaryBrown,
               height: 1.4,
             ),
           ),
         ),

         // Tampilan Gambar 2D menggunakan Image.memory
         Container(
           height: 200,
           width: double.infinity,
           decoration: BoxDecoration(
             color: kInputFillColor.withOpacity(0.2),
             borderRadius: BorderRadius.circular(16),
           ),
           child: ClipRRect(
             borderRadius: BorderRadius.circular(16),
             child: imageBytes != null && imageBytes.isNotEmpty // Tambahkan cek isNotEmpty
                 ? Image.memory(
                       imageBytes,
                       fit: BoxFit.cover,
                       errorBuilder: (context, error, stackTrace) {
                         print('ERROR rendering Image.memory: $error');
                         return Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(Icons.broken_image, color: Colors.red.shade400, size: 40),
                               const SizedBox(height: 8),
                               Text(
                                 'Gagal menampilkan gambar 2D.\nError: ${error.toString().split(':').first}',
                                 textAlign: TextAlign.center,
                                 style: kBodyText.copyWith(color: Colors.red.shade700, fontSize: 13),
                               ),
                             ],
                           ),
                         );
                       },
                     )
                 : Center(
                     child: Text(
                       'Data gambar kosong atau tidak valid setelah decode.', // Pesan error yang lebih spesifik
                       style: kBodyText.copyWith(color: Colors.red),
                     ),
                   ),
           ),
         ),
         const SizedBox(height: 12),
         Text(
           'Gambar 2D ini akan digunakan sebagai dasar Model 3D.',
           style: kBodyText.copyWith(
             fontSize: 12,
             color: kPrimaryBrown.withOpacity(0.6),
           ),
         ),
       ],
     ),
   );
 }
  Widget _build3DPreviewCard(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kPrimaryBrown.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBrown.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Message
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAccentOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: kAccentOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message.text,
                    style: kBodyText.copyWith(
                      fontSize: 14,
                      color: kPrimaryBrown,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3D Preview Area
          Container(
            height: 250,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kInputFillColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: kPrimaryBrown.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.view_in_ar,
                        size: 60,
                        color: kPrimaryBrown.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Model 3D Preview',
                        style: kSubtitle.copyWith(
                          fontSize: 14,
                          color: kPrimaryBrown.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gesek untuk memutar (${message.assetUrl!.split('/').last})',
                        style: kBodyText.copyWith(
                          fontSize: 12,
                          color: kPrimaryBrown.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                // Floating controls
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      _buildControlButton(Icons.refresh, 'Reset'),
                      const SizedBox(width: 8),
                      _buildControlButton(Icons.zoom_in, 'Zoom'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print('View in AR: ${message.assetUrl}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryBrown,
                      foregroundColor: kTextWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.view_in_ar, size: 18),
                    label: Text(
                      'Lihat AR',
                      style: kButtonText.copyWith(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print('Download: ${message.assetUrl}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentOrange,
                      foregroundColor: kTextWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(
                      'Unduh',
                      style: kButtonText.copyWith(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kPrimaryBrown.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: kPrimaryBrown,
        ),
      ),
    );
  }

  Widget _buildInputField(AiNotifier notifier) {
    // Tombol send disabled jika sedang loading
    final bool isSendButtonActive = _isTyping && !notifier.loading;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Image picker button
          GestureDetector(
            onTap: notifier.loading ? null : () {
              print('Pick image');
              // TODO: Implement image picker for 2D-to-3D flow
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.image_outlined,
                color: kPrimaryBrown.withOpacity(0.6),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSendButtonActive
                      ? kAccentOrange.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Icon(
                      Icons.edit_outlined,
                      color: isSendButtonActive
                          ? kAccentOrange
                          : Colors.grey.withOpacity(0.4),
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      // Non-aktifkan input saat AI sedang bekerja
                      enabled: !notifier.loading,
                      onChanged: (value) {
                        setState(() {
                          _isTyping = value.isNotEmpty;
                        });
                      },
                      maxLines: null,
                      maxLength: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: isSendButtonActive
                          ? (_) => _sendMessage(notifier)
                          : null,
                      style: kBodyText.copyWith(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: notifier.loading ? 'AI sedang bekerja...' : 'Tuliskan sesuatu...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: notifier.loading ? kAccentOrange : Colors.grey.withOpacity(0.45),
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 12,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isSendButtonActive
                            ? () => _sendMessage(notifier)
                            : null,
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSendButtonActive
                                ? kAccentOrange
                                : Colors.grey.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: isSendButtonActive
                                ? Colors.white
                                : Colors.grey.withOpacity(0.4),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}