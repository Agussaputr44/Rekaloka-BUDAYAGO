import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/constants.dart';
import '../../../common/state.dart';
import '../../provider/auth_notifier.dart';
import 'verification_page.dart';
import 'login_page.dart';

// Asumsi: _inputFillColor, kPrimaryBrown, kTextWhite, kAccentOrange, kScaffoldBackground,
// kHeading5, kHeadingRekaloka, kBodyText, kButtonText, kInputIconColor, RequestState telah didefinisikan.

class RegisterPage extends StatefulWidget {
  static const ROUTE_NAME = '/register';
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
    // Watch state untuk logic navigasi dan pesan error
    final authState = context.select((AuthNotifier n) => n.authState);
    final errorMessage = context.select((AuthNotifier n) => n.message);
    final isRegisterSuccess = context.select((AuthNotifier n) => n.isRegisterSuccess);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      if (authState == RequestState.Loaded && isRegisterSuccess) {
        Future.microtask(() {
          context.read<AuthNotifier>().resetAuthState();

          // Navigasi ke halaman verifikasi setelah sukses
          Navigator.of(context).pushReplacementNamed(
            VerificationPage.ROUTE_NAME,
            arguments: _emailController.text,
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
        // Struktur: Header Cokelat di dalam SingleChildScrollView, diikuti Form Putih
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
        top: MediaQuery.of(context).padding.top + 8, 
        left: 24, 
        right: 24, 
        bottom: 30
      ),
      decoration: const BoxDecoration(
        color: kPrimaryBrown,
        // Optional: Tambahkan border radius jika Anda ingin efek melengkung di bawah
        // borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Aksi (Kembali dan Judul)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: kTextWhite),
                onPressed: () => Navigator.pop(context),
              ),
              // Judul "Registrasi" diselaraskan ke kanan atau tengah jika menggunakan Spacer
              Text("Registrasi", style: kHeading5.copyWith(color: kTextWhite)),
              const SizedBox(width: 48), // Spacer visual untuk penyeimbang
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Judul Utama & Nama Aplikasi
          Center(
            child: Text(
              "Buat Akun Baru",
              style: kHeading5.copyWith(color: kTextWhite),
            ),
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
      // Hapus padding top dan gunakan margin negative untuk menutupi bagian lengkungan header (opsional)
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      // Atur background putih di sini, yang akan mengisi sisa area ke bawah
      decoration: const BoxDecoration(
        color: kScaffoldBackground,
        // Jika header Anda memiliki border radius, pastikan radius ini cocok
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Fields
          _buildInputField(
            _usernameController,
            'Username',
            Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            _emailController, 
            'Email', 
            Icons.email_outlined,
            keyboardType: TextInputType.emailAddress, // Tambahkan tipe keyboard
          ),
          const SizedBox(height: 16),
          _buildInputField(
            _passwordController,
            'Password',
            Icons.lock_outline,
            isPassword: true,
          ),
          
          const SizedBox(height: 32),
          
          // Tombol Daftar
          ElevatedButton(
            onPressed: isLoading ? null : _handleRegister,
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
                    "Daftar",
                    style: kButtonText.copyWith(color: kTextWhite),
                  ),
          ),
          
          const SizedBox(height: 24),
          
          // Footer (Dipindahkan ke dalam Form untuk konsistensi scrolling)
          _buildFooter(),
          
          const SizedBox(height: 24),

          // Ornamen Awan (Dibiarkan tetap di bawah form)
          _buildOrnamentSection(context),

          const SizedBox(height: 50), // Padding ekstra di bawah ornamen
        ],
      ),
    );
  }

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
        keyboardType: keyboardType, // Gunakan keyboardType yang disuplai
        style: kBodyText.copyWith(color: kPrimaryBrown),
        decoration: InputDecoration(
          filled: true,
          fillColor: kInputFillColor,
          // Border konsisten (tanpa sisi, radius 10)
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
  
  void _handleRegister() {
    // Validasi dasar
    if (_usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua bidang harus diisi')),
      );
      return;
    }

    final notifier = context.read<AuthNotifier>();
    notifier.registerUser(
      _emailController.text.trim(),
      _passwordController.text,
      _usernameController.text.trim(),
    );
  }
  
  // Footer (Dipindahkan dari _buildFooter ke dalam _buildForm)
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sudah punya akun?",
          style: kBodyText.copyWith(color: kPrimaryBrown),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed(LoginPage.ROUTE_NAME),
          child: Text(
            "Masuk",
            style: kButtonText.copyWith(color: kAccentOrange),
          ),
        ),
      ],
    );
  }

  // Ornamen Awan (Dipindahkan dari Footer)
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