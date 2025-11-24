import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import untuk TextInputFormatter
import 'package:provider/provider.dart';
import '../../../common/constants.dart';
import '../../../common/state.dart';
import '../../provider/auth_notifier.dart';
import 'login_page.dart';

// Asumsi: kPrimaryBrown, kTextWhite, kAccentOrange, kScaffoldBackground,
// kSecondaryBrown, kHeading5, kBodyText, kButtonText, RequestState telah didefinisikan.
// Saya menggunakan warna placeholder di sini jika constant Anda tidak tersedia.

class VerificationPage extends StatefulWidget {
  static const ROUTE_NAME = '/verification';
  final String email;

  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  late AuthNotifier _authNotifier;

  List<String> _code = List.filled(6, '');
  final TextEditingController _codeInputController = TextEditingController();
  final FocusNode _codeInputFocusNode = FocusNode();

  // Flag untuk memastikan fokus di-request hanya sekali setelah build
  bool _didRequestFocus = false;

  @override
  void initState() {
    super.initState();

    _authNotifier = context.read<AuthNotifier>();

    _authNotifier.addListener(_onAuthStatusChanged);
    _codeInputController.addListener(_updateCodeVisuals);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authNotifier.resetAuthState();
      // Fokus diminta di sini, dan juga di build/GestureDetector untuk stabilitas
      _codeInputFocusNode.requestFocus(); 
    });
  }

  void _onAuthStatusChanged() {
    // Gunakan Future.microtask untuk memicu navigasi setelah build selesai
    if (!mounted) return;

    if (_authNotifier.authState == RequestState.Loaded) {
      Future.microtask(() {
        _authNotifier.resetAuthState();
        Navigator.of(context).pushReplacementNamed(LoginPage.ROUTE_NAME);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verifikasi berhasil! Silakan login.')),
        );
      });
    } else if (_authNotifier.authState == RequestState.Error && _authNotifier.message.isNotEmpty) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authNotifier.message)),
        );
        _authNotifier.resetAuthState();
        // Setelah error, fokus kembali ke input agar user bisa langsung mengetik
        _codeInputFocusNode.requestFocus(); 
      });
    }
  }

  void _updateCodeVisuals() {
    final text = _codeInputController.text;
    setState(() {
      // Pastikan string hanya berisi angka dan tidak lebih dari 6 karakter
      final cleanedText = text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text != cleanedText) {
        _codeInputController.text = cleanedText;
        _codeInputController.selection = TextSelection.fromPosition(
          TextPosition(offset: cleanedText.length),
        );
        return;
      }
      
      _code = cleanedText.padRight(6).substring(0, 6).split('');
      
      if (cleanedText.length == 6) {
        // Otomatis verifikasi saat kode lengkap
        _handleVerification(cleanedText);
        _codeInputFocusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _authNotifier.removeListener(_onAuthStatusChanged);
    _codeInputController.removeListener(_updateCodeVisuals);
    _codeInputController.dispose();
    _codeInputFocusNode.dispose();
    super.dispose();
  }

  // Metode untuk menangani kirim ulang kode (Resend)
  void _handleResendCode() {
    // TODO: Implementasi logika kirim ulang kode ke widget.email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengirim ulang kode... (Simulasi)')),
    );
    // Setelah resend, kosongkan input dan fokus kembali
    _codeInputController.clear();
    _codeInputFocusNode.requestFocus();
  }

  void _handleVerification(String code) {
    // Pastikan keyboard tersembunyi sebelum memanggil API
    _codeInputFocusNode.unfocus(); 
    _authNotifier.verifyUserEmail(widget.email, code);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.select((AuthNotifier n) => n.authState);
    final isLoading = authState == RequestState.Loading;

    // Tidak perlu lagi memanggil error handler di sini karena sudah dipindahkan ke _onAuthStatusChanged

    return Scaffold(
      // Body diatur ke SingleChildScrollView untuk menghindari overflow saat keyboard muncul
      // Hapus resizeToAvoidBottomInset: false agar keyboard bisa menyesuaikan tampilan
      backgroundColor: kScaffoldBackground, // Ganti background Scaffold menjadi putih
      body: Column(
        children: [
          // Header (Warna Cokelat)
          _buildHeader(), 
          
          // Form Verifikasi (Warna Putih mengisi sisa layar)
          Expanded(
            child: SingleChildScrollView( // Tambahkan SingleChildScrollView di sini
              child: _buildVerificationForm(isLoading),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 24, right: 24, bottom: 30),
      decoration: const BoxDecoration(
        color: kPrimaryBrown, // Tetap cokelat
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: kTextWhite),
            onPressed: () => Navigator.of(context).pushReplacementNamed(LoginPage.ROUTE_NAME),
          ),
          const SizedBox(height: 20),
          Text("Verifikasi", style: kHeading5.copyWith(color: kTextWhite)),
          const SizedBox(height: 8),
          Text(
            "Menunggu kode yang dikirim ke ${widget.email}",
            style: kBodyText.copyWith(color: kTextWhite),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationForm(bool isLoading) {
    // Untuk memastikan layout tetap baik di berbagai ukuran, gunakan LayoutBuilder jika perlu, 
    // tetapi untuk Row dengan 6 item kecil, MainAxisAlignment.spaceEvenly sudah cukup responsif.
    return Container(
      width: double.infinity, // Gunakan double.infinity untuk mengisi lebar
      padding: const EdgeInsets.all(24),
      // Hapus BoxDecoration yang berisi borderRadius di sini, karena sudah dihilangkan 
      // di level build method (Expanded/SingleChildScrollView)
      color: kScaffoldBackground, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          
          // Kotak Input Kode Visual (Menggunakan LayoutBuilder untuk responsivitas yang lebih baik)
          LayoutBuilder(
            builder: (context, constraints) {
              final boxWidth = (constraints.maxWidth - (20 * 5)) / 6; // Hitung lebar yang tersedia
              return GestureDetector(
                onTap: () {
                  // ⭐ Pastikan input tersembunyi selalu fokus saat area ini diklik
                  _codeInputFocusNode.requestFocus();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final isFilled = index < _codeInputController.text.length;
                    
                    return Container(
                      width: boxWidth, // Lebar responsif
                      height: boxWidth * 1.2, // Proporsi tinggi sedikit lebih besar dari lebar
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isFilled || _codeInputFocusNode.hasFocus && index == _codeInputController.text.length
                              ? kAccentOrange // Warna oranye jika aktif/diisi
                              : kSecondaryBrown.withOpacity(0.5), // Warna cokelat jika kosong
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _code[index],
                        style: kHeading5.copyWith(color: kPrimaryBrown),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          
          // Input hidden untuk menangkap keyboard (Diletakkan di luar Kotak Visual)
          SizedBox(
            width: 0,
            height: 0,
            child: Opacity( // Menggunakan Opacity untuk menyembunyikan
              opacity: 0.0,
              child: TextField(
                controller: _codeInputController,
                focusNode: _codeInputFocusNode,
                // Menggunakan TextInputType.numberWithOptions(decimal: false) lebih eksplisit
                keyboardType: TextInputType.number, 
                maxLength: 6,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Memastikan hanya angka
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  // Hilangkan semua dekorasi agar tidak mengganggu layout
                  border: InputBorder.none, 
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          
          // Tombol Kirim Ulang Kode
          TextButton(
            onPressed: isLoading ? null : _handleResendCode,
            child: Text(
              "Tidak menerima kode?",
              style: kBodyText.copyWith(color: kAccentOrange),
            ),
          ),
          
          const SizedBox(height: 50),
          
          // Tombol Verifikasi
          ElevatedButton(
            onPressed: isLoading || _codeInputController.text.length != 6
                ? null
                : () => _handleVerification(_codeInputController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryBrown,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: kTextWhite))
                : Text(
                    "Verifikasi",
                    style: kButtonText.copyWith(color: kTextWhite),
                  ),
          ),
          
          const SizedBox(height: 24),
          
          // Area Ornamen (tetap responsif terhadap lebar layar)
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.width * 0.35,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // awan kiri
                Positioned(
                  left: -MediaQuery.of(context).size.width * 0.2,
                  top: 60,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.width * 0.35,
                    child: Image.asset('assets/images/logo_awan.png'),
                  ),
                ),
                // awan kanan
                Positioned(
                  right: -MediaQuery.of(context).size.width * 0.2,
                  top: 0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.width * 0.35,
                    child: Image.asset('assets/images/logo_awan.png'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}