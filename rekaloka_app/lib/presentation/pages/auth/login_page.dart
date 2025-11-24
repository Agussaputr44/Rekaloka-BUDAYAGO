import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/constants.dart';
import '../../../common/state.dart';
import '../../provider/auth_notifier.dart';
import '../Home/home_page.dart';
import 'register_page.dart';

const Color _inputFillColor = Color(0xFFE2B79A); 
// Asumsi: kPrimaryBrown, kTextWhite, kAccentOrange, kScaffoldBackground,
// kHeading5, kHeadingRekaloka, kBodyText, kButtonText, kInputIconColor, kSecondaryBrown, RequestState telah didefinisikan.

class LoginPage extends StatefulWidget {
  static const ROUTE_NAME = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isRememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  void _loadRememberedCredentials() {
    // Gunakan Future.microtask untuk mengakses Provider setelah initState selesai
    Future.microtask(() {
      if (!mounted) return;
      
      final notifier = context.read<AuthNotifier>();

      if (notifier.rememberedEmail != null &&
          notifier.rememberedEmail!.isNotEmpty) {
        _emailController.text = notifier.rememberedEmail!;
      }

      setState(() {
        _isRememberMe = notifier.rememberMe;
      });

      // Pastikan state di notifier sinkron dengan UI awal
      notifier.setRememberMe(_isRememberMe); 
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.select((AuthNotifier n) => n.authState);
    final errorMessage = context.select((AuthNotifier n) => n.message);
    final isRegisterSuccess = context.select(
      (AuthNotifier n) => n.isRegisterSuccess,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Navigasi setelah login sukses (authState == Loaded dan BUKAN register success)
      if (authState == RequestState.Loaded && !isRegisterSuccess) {
        Future.microtask(() {
          Navigator.of(context).pushReplacementNamed(HomePage.ROUTE_NAME);
          context.read<AuthNotifier>().resetAuthState();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login berhasil! Selamat datang kembali.'),
            ),
          );
        });
      } else if (authState == RequestState.Error && errorMessage.isNotEmpty) {
        // Tampilkan snackbar jika ada error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        Future.microtask(() => context.read<AuthNotifier>().resetAuthState());
      }
    });

    return Scaffold(
      // Background Scaffold diatur ke warna putih (kScaffoldBackground)
      backgroundColor: kScaffoldBackground, 
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            // Form kini bertanggung jawab untuk mengisi sisa area di bawah header
            _buildForm(authState == RequestState.Loading),
          ],
        ),
      ),
    );
  }

  // Header (Warna Cokelat)
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      // Padding adaptif, menggunakan MediaQuery untuk top safe area
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 24, 
        right: 24, 
        bottom: 30
      ),
      decoration: const BoxDecoration(
        color: kPrimaryBrown,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Baris "Masuk"
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text("Masuk", style: kHeading5.copyWith(color: kTextWhite)),
          //   ],
          // ),
          
          const SizedBox(height: 30),
          
          // Judul Utama & Nama Aplikasi
          Text(
            "Selamat Datang",
            style: kHeading5.copyWith(color: kTextWhite),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text.rich(
              TextSpan(
                text: "Sobat ",
                style: kHeadingRekaloka.copyWith(
                  fontSize: 32,
                  color: kTextWhite,
                ),
                children: [
                  TextSpan(
                    text: "Rekaloka",
                    style: kHeadingRekaloka.copyWith(
                      fontSize: 32,
                      color: kAccentOrange,
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

  // Form (Warna Putih)
  Widget _buildForm(bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      // Atur background putih di sini
      decoration: const BoxDecoration(
        color: kScaffoldBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Fields
          _buildInputField(
            _emailController, 
            'Email', 
            Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            _passwordController,
            'Kata Sandi', // Ubah hintText agar lebih deskriptif
            Icons.lock_outline,
            isPassword: true,
          ),
          
          const SizedBox(height: 16),
          
          // Remember Me & Lupa Kata Sandi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _isRememberMe,
                    onChanged: (val) {
                      setState(() {
                        _isRememberMe = val ?? false;
                      });
                      context.read<AuthNotifier>().setRememberMe(_isRememberMe);
                    },
                    activeColor: kAccentOrange,
                    // Hilangkan padding ekstra di sekitar Checkbox
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, 
                  ),
                  Text("Ingat saya", style: kBodyText.copyWith(color: kPrimaryBrown)),
                ],
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigasi ke Lupa Kata Sandi
                },
                child: Text(
                  "Lupa kata sandi?",
                  style: kBodyText.copyWith(color: kSecondaryBrown),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Tombol Masuk
          ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryBrown,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: kTextWhite))
                : Text("Masuk", style: kButtonText.copyWith(color: kTextWhite)),
          ),
          
          const SizedBox(height: 24),
          
          // Navigasi ke Registrasi
          _buildRegisterNavigation(),

          const SizedBox(height: 24),
          
          // Ornamen Awan
          _buildOrnamentSection(context),

          const SizedBox(height: 50), // Padding ekstra di bawah ornamen
        ],
      ),
    );
  }

  // Membangun Input Field yang Konsisten
  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
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
        keyboardType: keyboardType,
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
          hintStyle: kBodyText.copyWith(
            color: kInputIconColor.withOpacity(0.7),
          ),
          prefixIcon: Icon(icon, color: kInputIconColor),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
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
  
  void _handleLogin() {
    // Validasi dasar
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Kata Sandi harus diisi')),
      );
      return;
    }
    
    // Sembunyikan keyboard sebelum memanggil API
    FocusScope.of(context).unfocus(); 

    final notifier = context.read<AuthNotifier>();
    notifier.loginUser(_emailController.text.trim(), _passwordController.text.trim());
  }

  // Widget navigasi ke Registrasi
  Widget _buildRegisterNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Belum punya akun?",
          style: kBodyText.copyWith(color: kPrimaryBrown),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(RegisterPage.ROUTE_NAME),
          child: Text(
            "Daftar",
            style: kButtonText.copyWith(color: kAccentOrange),
          ),
        ),
      ],
    );
  }

  // Ornamen Awan (Dipindahkan ke dalam Form)
  Widget _buildOrnamentSection(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.width * 0.40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -MediaQuery.of(context).size.width * 0.18,
            top: 80,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.30,
              height: MediaQuery.of(context).size.width * 0.30,
              child: Image.asset('assets/images/logo_awan.png'),
            ),
          ),
          Positioned(
            right: -MediaQuery.of(context).size.width * 0.18,
            top: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.30,
              height: MediaQuery.of(context).size.width * 0.30,
              child: Image.asset('assets/images/logo_awan.png'),
            ),
          ),
        ],
      ),
    );
  }
}