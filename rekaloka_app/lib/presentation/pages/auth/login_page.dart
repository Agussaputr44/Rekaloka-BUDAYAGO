import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/constants.dart';
import '../../../common/state.dart';
import '../../provider/auth_notifier.dart';
import '../Home/home_page.dart';
import 'register_page.dart';

const Color _inputFillColor = Color(0xFFE2B79A);

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
    Future.microtask(() {
      final notifier = context.read<AuthNotifier>();

      if (notifier.rememberedEmail != null &&
          notifier.rememberedEmail!.isNotEmpty) {
        _emailController.text = notifier.rememberedEmail!;
      }

      setState(() {
        _isRememberMe = notifier.rememberMe;
      });

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
          ],
        ),
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
          _buildInputField(_emailController, 'Email', Icons.person_outline),
          const SizedBox(height: 16),
          _buildInputField(
            _passwordController,
            '.......',
            Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 16),
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
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text("Ingat saya", style: kBodyText),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "lupa kata sandi?",
                  style: kBodyText.copyWith(color: kSecondaryBrown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                ? const CircularProgressIndicator(color: kTextWhite)
                : Text("Masuk", style: kButtonText),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Belum punya akun?",
                style: kBodyText.copyWith(color: kPrimaryBrown),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(RegisterPage.ROUTE_NAME),
                child: Text(
                  "Daftar",
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
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // ... (kode _buildHeader yang sudah ada)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 50),
      color: kPrimaryBrown,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   children: [
          //     // IconButton(
          //     //   icon: const Icon(Icons.arrow_back_ios, color: kTextWhite),
          //     //   onPressed: () => Navigator.pop(context),
          //     // ),
          //     const Spacer(),
          //     Center(child: Text("Masuk", style: kHeading5.copyWith(color: kTextWhite))),
          //     const Spacer(flex: 2),
          //   ],
          // ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              "Selamat Datang",
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

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    // ... (kode _buildInputField yang sudah ada)
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

  void _handleLogin() {
    final notifier = context.read<AuthNotifier>();
    notifier.loginUser(_emailController.text, _passwordController.text);
  }
}
