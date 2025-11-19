import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/constants.dart';
import '../../../common/state.dart';
import 'register_page.dart';
import '../../provider/auth_notifier.dart';
import '../Home/home_page.dart';

// Asumsi: Warna khusus untuk Input Field agar sesuai desain oranye muda
const Color _inputFillColor = Color(0xFFE2B79A); 

class LoginPage extends StatefulWidget {
  static const ROUTE_NAME = '/sign-in';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil state dan error dari Notifier
    final authState = context.select((AuthNotifier n) => n.authState);
    final errorMessage = context.select((AuthNotifier n) => n.message);

    // Navigasi atau tampilkan error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState == RequestState.Loaded) {
        // Logika: Setelah sukses login, navigasi ke HomePage
        Navigator.of(context).pushReplacementNamed(HomePage.ROUTE_NAME);
      } else if (authState == RequestState.Error && errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        // Di sini Anda mungkin ingin memanggil method di Notifier untuk mereset error message
      }
    });

    return Scaffold(
      // Background Scaffold harus kPrimaryBrown agar header menyatu
      backgroundColor: kPrimaryBrown, 
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header (Panah dan Teks Selamat Datang) di atas latar cokelat
            _buildHeader(context),
            // Form (Input dan Tombol) di atas latar krem
            _buildForm(authState == RequestState.Loading),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDER ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      // Padding vertikal yang lebih besar untuk memuat teks sambutan
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 50), 
      color: kPrimaryBrown, // Menyatu dengan Scaffold background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Navigasi (Panah Kembali dan Judul "Masuk")
          Row( 
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: kTextWhite),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(), 
              Text("Masuk", style: kHeading5.copyWith(color: kTextWhite)),
              const Spacer(flex: 2), // Flex 2 untuk menyeimbangkan panah
            ],
          ),
          
          const SizedBox(height: 30),
          // Text Sambutan
          Text("Selamat Datang", style: kHeading5.copyWith(color: kTextWhite)),
          Text.rich(
            TextSpan(
              text: "Sobat ",
              style: kHeading1.copyWith(fontSize: 32, color: kTextWhite),
              children: [
                TextSpan(
                  text: "Rekaloka",
                  style: kHeading1.copyWith(fontSize: 32, color: kAccentOrange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: kScaffoldBackground, // Latar belakang krem/putih
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Input Username/Email
          _buildInputField(
            _emailController, 
            'username', 
            Icons.person_outline,
          ),
          const SizedBox(height: 16),
          // Input Password
          _buildInputField(
            _passwordController, 
            '.......', 
            Icons.lock_outline,
            isPassword: true,
          ),
          
          // Opsi Lupa Kata Sandi dan Ingat Saya
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: true, 
                    onChanged: (val){}, 
                    activeColor: kAccentOrange,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text("Ingatkan saya", style: kBodyText),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text("lupa kata sandi?", style: kBodyText.copyWith(color: kSecondaryBrown)), 
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          // Tombol Masuk
          ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryBrown, // Warna Cokelat Tua
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: isLoading 
                ? const CircularProgressIndicator(color: kTextWhite)
                : Text("Masuk", style: kButtonText),
          ),

          const SizedBox(height: 24),
          // Tautan Belum punya akun
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Belum punya akun?", style: kBodyText.copyWith(color: kPrimaryBrown)),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(RegisterPage.ROUTE_NAME);
                },
                child: Text(
                  "Daftar",
                  style: kButtonText.copyWith(color: kAccentOrange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 200), // Memberikan ruang di bawah form
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
        keyboardType: hint.contains('username') ? TextInputType.text : TextInputType.emailAddress,
        obscureText: isPassword && !_isPasswordVisible,
        style: kBodyText.copyWith(color: kPrimaryBrown), 
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: kBodyText.copyWith(color: kInputIconColor.withOpacity(0.7)),
          
          // Warna Oranye Muda Kustom untuk Fill
          filled: true,
          fillColor: _inputFillColor, 
          
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          
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
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        ),
      ),
    );
  }

  // --- LOGIKA NOTIFIER ---

  void _handleLogin() {
    // Panggil method login di AuthNotifier
    final notifier = context.read<AuthNotifier>();
    notifier.loginUser(
      _emailController.text, 
      _passwordController.text, 
    );
  }
}