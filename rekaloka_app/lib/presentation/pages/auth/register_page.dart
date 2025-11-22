import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/constants.dart';
import '../../../common/state.dart';
import '../../provider/auth_notifier.dart';
import 'verification_page.dart';
import 'login_page.dart';

const Color _inputFillColor = Color(0xFFE2B79A);

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
    final authState = context.select((AuthNotifier n) => n.authState);
    final errorMessage = context.select((AuthNotifier n) => n.message);
    final isRegisterSuccess = context.select(
      (AuthNotifier n) => n.isRegisterSuccess,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState == RequestState.Loaded && isRegisterSuccess) {
        Future.microtask(() {
          context.read<AuthNotifier>().resetAuthState();

          Navigator.of(context).pushReplacementNamed(
            VerificationPage.ROUTE_NAME,
            arguments: _emailController.text,
          );
        });
      } else if (authState == RequestState.Error && errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        Future.microtask(() => context.read<AuthNotifier>().resetAuthState());
      }
    });

    return Scaffold(
      backgroundColor: kPrimaryBrown,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildForm(authState == RequestState.Loading),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 50),
      color: kPrimaryBrown,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: kTextWhite),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text("Registrasi", style: kHeading5.copyWith(color: kTextWhite)),
              const Spacer(flex: 2),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              "Buat Akun Baru",
              style: kHeading5.copyWith(color: kTextWhite),
            ),
          ),
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

  Widget _buildForm(bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: kScaffoldBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildInputField(
            _usernameController,
            'Username',
            Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildInputField(_emailController, 'Email', Icons.email_outlined),
          const SizedBox(height: 16),
          _buildInputField(
            _passwordController,
            'Password',
            Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 16),
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
                ? const CircularProgressIndicator(color: kTextWhite)
                : Text(
                    "Daftar",
                    style: kButtonText.copyWith(color: kTextWhite),
                  ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sudah punya akun?",
                style: kBodyText.copyWith(color: kPrimaryBrown),
              ),
              TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushReplacementNamed(LoginPage.ROUTE_NAME),
                child: Text(
                  "Masuk",
                  style: kButtonText.copyWith(color: kAccentOrange),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
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
          ),
          const SizedBox(height: 150),
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
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 10,
          ),
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
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua bidang harus diisi')));
      return;
    }

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Sudah punya akun?",
            style: kBodyText.copyWith(color: kPrimaryBrown),
          ),
          TextButton(
            onPressed: () => Navigator.of(
              context,
            ).pushReplacementNamed(LoginPage.ROUTE_NAME),
            child: Text(
              "Masuk",
              style: kButtonText.copyWith(color: kAccentOrange),
            ),
          ),
        ],
      ),
    );
  }
}
