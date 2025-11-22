import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/constants.dart';
import '../../../common/state.dart';
import '../../provider/auth_notifier.dart';
import 'login_page.dart';

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

  @override
  void initState() {
    super.initState();

    _authNotifier = context.read<AuthNotifier>();

    _authNotifier.addListener(_onAuthStatusChanged);
    _codeInputController.addListener(_updateCodeVisuals);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authNotifier.resetAuthState();
      _codeInputFocusNode.requestFocus();
    });
  }

  void _onAuthStatusChanged() {
    if (_authNotifier.authState == RequestState.Loaded) {
      Future.microtask(() {
        _authNotifier.resetAuthState();
        Navigator.of(context).pushReplacementNamed(LoginPage.ROUTE_NAME);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verifikasi berhasil! Silakan login.')),
        );
      });
    }
  }

  void _updateCodeVisuals() {
    final text = _codeInputController.text;
    setState(() {
      _code = text.padRight(6).substring(0, 6).split('');
      if (text.length == 6) {
        _handleVerification(text);
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

  @override
  Widget build(BuildContext context) {
    final authState = context.select((AuthNotifier n) => n.authState);
    final errorMessage = context.select((AuthNotifier n) => n.message);

    if (authState == RequestState.Error && errorMessage.isNotEmpty) {
      Future.microtask(() {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        _authNotifier.resetAuthState();
      });
    }

    return Scaffold(
      backgroundColor: kPrimaryBrown,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildVerificationForm(authState == RequestState.Loading),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 30),
      color: kPrimaryBrown,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: kTextWhite),
            onPressed: () => Navigator.of(
              context,
            ).pushReplacementNamed(LoginPage.ROUTE_NAME),
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
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: kScaffoldBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () {
              // ⭐ Arahkan fokus ke TextField tersembunyi saat area ini diklik
              _codeInputFocusNode.requestFocus();
            },
            child: AbsorbPointer(
              // Mencegah klik ganda jika ada item interaktif lain di dalam Row
              absorbing: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  // ... (Kotak kode visual Anda)
                  return Container(
                    width: 40,
                    height: 50,
                    decoration: BoxDecoration(
                      // Tambahkan indikasi fokus agar user tahu mana yang aktif
                      border: Border.all(
                        color: index < _codeInputController.text.length
                            ? kAccentOrange // Warna oranye jika sudah diisi
                            : kSecondaryBrown, // Warna cokelat jika kosong
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
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
            ),
          ),
          // Input hidden untuk menangkap keyboard
          SizedBox(
            width: 0,
            height: 0,
            child: TextField(
              controller: _codeInputController,
              focusNode: _codeInputFocusNode,
              keyboardType: TextInputType.number,
              maxLength: 6,
              // Hilangkan warna agar benar-benar tersembunyi
              style: const TextStyle(color: Colors.transparent, fontSize: 0),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                fillColor: Colors.transparent, // Pastikan tidak ada warna isi
                filled: true,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              // TODO: logika kirim ulang kode
            },
            child: Text(
              "Tidak menerima kode?",
              style: kBodyText.copyWith(color: kAccentOrange),
            ),
          ),
          const SizedBox(height: 50),
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
                ? const CircularProgressIndicator(color: kTextWhite)
                : Text(
                    "Verifikasi",
                    style: kButtonText.copyWith(color: kTextWhite),
                  ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.width * 0.35, // area ornamen
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

  void _handleVerification(String code) {
    _authNotifier.verifyUserEmail(widget.email, code);
  }
}
