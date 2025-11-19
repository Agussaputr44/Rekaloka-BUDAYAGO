import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/constants.dart';
import 'login_page.dart';
import 'verification_page.dart';
import '../../provider/auth_notifier.dart';

import '../../../common/state.dart';

const Color _inputFillColor = Color(0xFFE2B79A); 

class RegisterPage extends StatefulWidget {
  static const ROUTE_NAME = '/sign-up';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.select((AuthNotifier n) => n.authState);
    final errorMessage = context.select((AuthNotifier n) => n.message);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState == RequestState.Loaded) {
        print('Navigating to VerificationPage with email: ${_emailController.text}');
        Navigator.of(context).pushReplacementNamed(
        
          VerificationPage.ROUTE_NAME, 
          arguments: _emailController.text,
        );
      } else if (authState == RequestState.Error && errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    });

    return Scaffold(
      backgroundColor: kPrimaryBrown, 
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            _buildHeader(context),
            // --- FORM ---
            _buildForm(authState == RequestState.Loading),
            // --- FOOTER DENGAN ORNAMEN BATIK ---
            _buildFooter(context),
          ],
        ),
      ),
    );
  }
  

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 30),
      color: kPrimaryBrown,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          // Panah kembali
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: kTextWhite),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(), 
            ],
          ),
          
          const SizedBox(height: 20),
          Text("Registrasi", style: kHeading5.copyWith(color: kTextWhite)), 
          const SizedBox(height: 8), 
          Text("Buat akun baru kamu", style: kSubtitle.copyWith(color: kTextWhite)), 
        ],
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: kScaffoldBackground, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Input Username
          _buildInputField(
            _usernameController, 
            'username', 
            Icons.person_outline,
          ),
          const SizedBox(height: 16),
          // Input Email
          _buildInputField(
            _emailController, 
            'Email', 
            Icons.email_outlined,
          ),
          const SizedBox(height: 16),
          // Input Password
          _buildInputField(
            _passwordController, 
            '.......', 
            Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 32),
          // Tombol Daftar
          ElevatedButton(
            onPressed: isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentOrange, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: isLoading 
                ? const CircularProgressIndicator(color: kTextWhite)
                : Text("Daftar", style: kButtonText.copyWith(color: kTextWhite)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller, 
    String hint, 
    IconData icon, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: kBodyText.copyWith(color: kPrimaryBrown), 
        decoration: InputDecoration(
          filled: true,
          fillColor: _inputFillColor, 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, 
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),

          hintText: hint,
          hintStyle: kBodyText.copyWith(color: kInputIconColor.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: kInputIconColor),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: kInputIconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  void _handleRegister() {
    final notifier = context.read<AuthNotifier>();
    notifier.registerUser(
      _emailController.text, 
      _passwordController.text, 
      _usernameController.text,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kScaffoldBackground, 
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Sudah punya akun?", style: kBodyText.copyWith(color: kPrimaryBrown)),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(LoginPage.ROUTE_NAME);
                },
                child: Text(
                  "Masuk",
                  style: kButtonText.copyWith(color: kAccentOrange),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 50), 
          // // Ornamen Batik (Jika ada gambar aset)
          // // Image.asset('assets/images/logo_awan.png', height: 100),
          // // Tambahkan ornamen batik di sini jika Anda memilikinya di assets
          // // Untuk saat ini, kita bisa menambahkan Placeholder atau Container kosong
          // // agar ada ruang yang cukup.
          // Container(
          //   height: 100, // Sesuaikan tinggi ornamen batik Anda
          //   width: double.infinity,
          //   // child: Image.asset('assets/images/logo_awan.png', fit: BoxFit.fitWidth), // Contoh
          // ),
        ],
      ),
    );
  }
}