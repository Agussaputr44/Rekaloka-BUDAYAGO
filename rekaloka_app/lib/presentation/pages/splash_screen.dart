import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/constants.dart';
import 'Home/home_page.dart';
import 'auth/login_page.dart';

import '../../common/state.dart';
import '../provider/auth_notifier.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _isLogoVisible = false;

  // Controllers dan Animasi gabungan (Intro + Floating)
  late final AnimationController _cloudController1;
  late final Animation<Offset> _cloudAnimation1;
  late final AnimationController _cloudController2;
  late final Animation<Offset> _cloudAnimation2;
  late final AnimationController _cloudController3;
  late final Animation<Offset> _cloudAnimation3;
  late final AnimationController _cloudController4;
  late final Animation<Offset> _cloudAnimation4;

  @override
  void initState() {
    super.initState();

    // Inisialisasi Controllers Awan
    _cloudController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _cloudController2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _cloudController3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _cloudController4 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Animasi Awan
    // Awan 1 (Kiri Atas): Masuk dari kiri, melayang ke kanan-bawah
    _cloudAnimation1 =
        Tween<Offset>(
          begin: const Offset(-1.0, -0.2),
          end: const Offset(0.01, 0.01),
        ).animate(
          CurvedAnimation(parent: _cloudController1, curve: Curves.easeOut),
        );

    // Awan 2 (Kanan Atas)
    _cloudAnimation2 =
        Tween<Offset>(
          begin: const Offset(1.0, -0.2),
          end: const Offset(-0.01, 0.01),
        ).animate(
          CurvedAnimation(parent: _cloudController2, curve: Curves.easeOut),
        );

    // Awan 3 (Kiri Bawah)
    _cloudAnimation3 =
        Tween<Offset>(
          begin: const Offset(-1.0, 0.2),
          end: const Offset(0.01, -0.01),
        ).animate(
          CurvedAnimation(parent: _cloudController3, curve: Curves.easeOut),
        );

    // Awan 4 (Kanan Bawah)
    _cloudAnimation4 =
        Tween<Offset>(
          begin: const Offset(1.0, 0.2),
          end: const Offset(-0.01, -0.01),
        ).animate(
          CurvedAnimation(parent: _cloudController4, curve: Curves.easeOut),
        );

    // Fase 1: Logo Muncul
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLogoVisible = true;
        });
      }
    });

    // Fase 2: Awan Masuk dan Mulai Melayang
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        // Memulai animasi masuk
        _cloudController1.forward();
        Future.delayed(
          const Duration(milliseconds: 300),
          () => _cloudController2.forward(),
        );
        Future.delayed(
          const Duration(milliseconds: 600),
          () => _cloudController3.forward(),
        );
        Future.delayed(const Duration(milliseconds: 900), () {
          _cloudController4.forward().whenComplete(() {
            // Setelah semua awan masuk, mulai animasi melayang (looping)
            _cloudController1.repeat(reverse: true);
            _cloudController2.repeat(reverse: true);
            _cloudController3.repeat(reverse: true);
            _cloudController4.repeat(reverse: true);
          });
        });
      }
    });

    // CATATAN: Panggilan navigasi dipindahkan ke didChangeDependencies -> _startNavigation
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Panggil fungsi navigasi kondisional (lebih aman untuk context.read)
    _startNavigation();
  }

  void _startNavigation() async {
    // 1. Tunggu Animasi Selesai (2.5 detik untuk buffer)
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final authNotifier = context.read<AuthNotifier>();

    // ⭐ [FUNGSI AUTO-LOGIN] Panggil checkAuthStatus untuk memverifikasi token.
    // authNotifier akan mengupdate authState menjadi Loaded jika token valid.
    await authNotifier.checkAuthStatus();

    if (!mounted) return;

    // ⭐ [LOGIKA NAVIGASI SUDAH BENAR]
    // Jika authState = Loaded dan user ada, arahkan ke Home Page.
    final String destinationRoute =
        authNotifier.authState == RequestState.Loaded &&
            authNotifier.user != null
        ? HomePage.ROUTE_NAME
        : LoginPage.ROUTE_NAME;

    // 4. Navigasi ke rute tujuan
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (context, animation, secondaryAnimation) {
          // Menggunakan logika if-else untuk mengembalikan instance widget
          if (destinationRoute == HomePage.ROUTE_NAME) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _cloudController1.dispose();
    _cloudController2.dispose();
    _cloudController3.dispose();
    _cloudController4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kPrimaryBrown,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ----------------------------------------------------
          // Awan 1 (Kiri Atas)
          // ----------------------------------------------------
          AnimatedBuilder(
            animation: _cloudAnimation1,
            builder: (context, child) {
              return Positioned(
                left: -screenWidth * 0.15,
                top: screenHeight * 0.0,
                child: Transform.translate(
                  offset: Offset(
                    _cloudAnimation1.value.dx * screenWidth * 0.2,
                    _cloudAnimation1.value.dy * screenHeight * 0.1,
                  ),
                  child: Image.asset(
                    'assets/images/logo_awan.png',
                    width: screenWidth * 0.45, // Ukuran awan disesuaikan
                    height: screenWidth * 0.45,
                  ),
                ),
              );
            },
          ),

          // ----------------------------------------------------
          // Awan 2 (Kanan Atas)
          // ----------------------------------------------------
          AnimatedBuilder(
            animation: _cloudAnimation2,
            builder: (context, child) {
              return Positioned(
                right: -screenWidth * 0.1,
                top: screenHeight * 0.2,
                child: Transform.translate(
                  offset: Offset(
                    _cloudAnimation2.value.dx * screenWidth * 0.2,
                    _cloudAnimation2.value.dy * screenHeight * 0.1,
                  ),
                  child: Image.asset(
                    'assets/images/logo_awan.png',
                    width: screenWidth * 0.35,
                    height: screenWidth * 0.4,
                  ),
                ),
              );
            },
          ),

          // ----------------------------------------------------
          // Awan 3 (Kiri Bawah)
          // ----------------------------------------------------
          AnimatedBuilder(
            animation: _cloudAnimation3,
            builder: (context, child) {
              return Positioned(
                left: screenWidth * 0.05,
                bottom: screenHeight * 0.15,
                child: Transform.translate(
                  offset: Offset(
                    _cloudAnimation3.value.dx * screenWidth * 0.2,
                    _cloudAnimation3.value.dy * screenHeight * 0.1,
                  ),
                  child: Image.asset(
                    'assets/images/logo_awan.png',
                    width: screenWidth * 0.35,
                    height: screenWidth * 0.35,
                  ),
                ),
              );
            },
          ),

          // ----------------------------------------------------
          // Awan 4 (Kanan Bawah)
          // ----------------------------------------------------
          AnimatedBuilder(
            animation: _cloudAnimation4,
            builder: (context, child) {
              return Positioned(
                right: -screenWidth * 0.05,
                bottom: screenHeight * 0.05,
                child: Transform.translate(
                  offset: Offset(
                    _cloudAnimation4.value.dx * screenWidth * 0.2,
                    _cloudAnimation4.value.dy * screenHeight * 0.1,
                  ),
                  child: Image.asset(
                    'assets/images/logo_awan.png',
                    width: screenWidth * 0.45,
                    height: screenWidth * 0.45,
                  ),
                ),
              );
            },
          ),

          // ----------------------------------------------------
          // Logo dan Nama Aplikasi (di tengah)
          // ----------------------------------------------------
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: screenWidth * 0.55,
                  width: screenWidth * 0.55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kScaffoldBackground,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: _isLogoVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        child: Hero(
                          tag: 'appLogo',
                          child: Image.asset(
                            'assets/images/logo_rekaloka.png',
                            width: screenWidth * 0.4,
                            height: screenWidth * 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedOpacity(
                        opacity: _isLogoVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        child: Text(
                          'Rekaloka',
                          style: kHeadingRekaloka.copyWith(
                            color: kSecondaryBrown,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
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
