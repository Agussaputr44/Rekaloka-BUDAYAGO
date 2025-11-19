import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/constants.dart';
import 'login_page.dart';
import '../../provider/auth_notifier.dart';

import '../../../common/state.dart';

class VerificationPage extends StatefulWidget {
  static const ROUTE_NAME = '/verification';
  final String email;

  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  // Variabel untuk menyimpan instance Notifier agar aman di dispose
  late AuthNotifier _authNotifier; 
    
  List<String> _code = List.filled(6, '');
  final TextEditingController _codeInputController = TextEditingController();
  final FocusNode _codeInputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    // KOREKSI 1: Baca Notifier SEKALI dan simpan instance-nya
    _authNotifier = context.read<AuthNotifier>(); 
    
    // Gunakan instance yang disimpan untuk mendaftarkan listener
    _authNotifier.addListener(_onAuthStatusChanged);
    
    // Tambahkan listener untuk input visual
    _codeInputController.addListener(_updateCodeVisuals);
    
    // 2. State Reset dan Focus Request
    WidgetsBinding.instance.addPostFrameCallback((_) {
        // Gunakan instance yang disimpan
        _authNotifier.resetAuthState(); 
        _codeInputFocusNode.requestFocus();
    });
  }

  void _onAuthStatusChanged() {
    if (_authNotifier.authState == RequestState.Loaded) {
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
            print('DEBUG: [Listener] Navigasi ke Home DIPICU DARI VERIFIKASI SUKSES.');
            
            _authNotifier.resetAuthState(); 
            
            Navigator.of(context).pushReplacementNamed(LoginPage.ROUTE_NAME);
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
    print('DEBUG: [VerificationPage] Build Dipanggil. State: ${context.watch<AuthNotifier>().authState}'); 
    
    final authState = context.select((AuthNotifier n) => n.authState);
    final errorMessage = context.select((AuthNotifier n) => n.message);

    if (authState == RequestState.Error && errorMessage.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            print('DEBUG: [VerificationPage] Error: $errorMessage');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
            _authNotifier.resetAuthState(); 
        });
    }

    return Scaffold(
      backgroundColor: kPrimaryBrown,
      resizeToAvoidBottomInset: false, 
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildVerificationForm(context, authState == RequestState.Loading),
            const SizedBox(height: 50), 
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDER ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 30),
      color: kPrimaryBrown,
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
            "Menunggu untuk mendeteksi secara otomatis kode yang dikirim ke ${widget.email}",
            style: kBodyText.copyWith(color: kTextWhite),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationForm(BuildContext context, bool isLoading) {
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
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return Container(
                width: 40,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: kSecondaryBrown, width: 2),
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
          
          SizedBox(
            height: 0, 
            width: 0,
            child: Opacity(
              opacity: 0.0,
              child: TextField(
                controller: _codeInputController,
                focusNode: _codeInputFocusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration(
                  counterText: '', 
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              // Logika kirim ulang kode 
            },
            child: Text("Tidak menerima kode?", style: kBodyText.copyWith(color: kAccentOrange)),
          ),
          
          const SizedBox(height: 100), 
          
          ElevatedButton(
            onPressed: isLoading || _codeInputController.text.length != 6 
                ? null 
                : () => _handleVerification(_codeInputController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryBrown, 
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: isLoading 
                ? const CircularProgressIndicator(color: kTextWhite)
                : Text("Verifikasi", style: kButtonText.copyWith(color: kTextWhite)),
          ),
        ],
      ),
    );
  }
  
  void _handleVerification(String code) {
    print('DEBUG: [VerificationPage] Memanggil verifyUserEmail dengan kode: $code');
    _authNotifier.verifyUserEmail(widget.email, code);
  }
}