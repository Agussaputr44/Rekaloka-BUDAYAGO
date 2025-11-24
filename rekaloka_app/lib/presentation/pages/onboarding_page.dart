import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/login_page.dart';
import 'home/home_page.dart';
import '../provider/auth_notifier.dart';
import '../../../common/constants.dart';
import '../../common/state.dart';

class OnboardingPage extends StatefulWidget {
  static const ROUTE_NAME = '/onboarding';
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      title: 'Rekaloka',
      subtitle:
          'Platform Mobile Edukasi dan Rekonstruksi\nWarisan Budaya dengan Model 3D dan AI',
      description:
          'Rekaloka hadir sebagai gerbang baru untuk menjelajahi, mempelajari, dan menghidupkan kembali warisan budaya Indonesia. Dengan teknologi AI dan model 3D modern, Rekaloka membantu Anda merasakan pengalaman eksplorasi budaya yang lebih dekat, interaktif, dan imersif.',
      secondDescription:
          'Temukan kembali nilai sejarah, seni, dan identitas bangsa melalui rekonstruksi digital yang cerdas dan penuh makna.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCloudDecoration({
    required double width,
    required double height,
    required double opacity,
  }) {
    // Custom cloud shape jika gambar tidak ada atau kotak
    return ClipPath(
      clipper: CloudClipper(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(opacity),
              Colors.white.withOpacity(opacity * 0.5),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: kPrimaryBrown,
        child: Stack(
          children: [
            // Cloud decoration - top right (above card)
            Positioned(
              top: 40,
              right: -20,
              child: Opacity(
                opacity: 0.25,
                child: Image.asset(
                  'assets/images/logo_awan.png',
                  width: 180,
                  height: 90,
                  fit: BoxFit.contain,
                  color: Colors.white.withOpacity(0.3), // Tint white
                  colorBlendMode: BlendMode.modulate,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildCloudDecoration(
                        width: 180,
                        height: 90,
                        opacity: 0.25,
                      ),
                ),
              ),
            ),

            // Cloud decoration - left side (middle)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: -60,
              child: Transform.rotate(
                angle: 0.2,
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/images/logo_awan.png',
                    width: 160,
                    height: 80,
                    fit: BoxFit.contain,
                    color: Colors.white.withOpacity(0.3),
                    colorBlendMode: BlendMode.modulate,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildCloudDecoration(
                          width: 160,
                          height: 80,
                          opacity: 0.2,
                        ),
                  ),
                ),
              ),
            ),

            // Cloud decoration - bottom left
            Positioned(
              bottom: 40,
              left: -40,
              child: Transform.rotate(
                angle: -0.1,
                child: Opacity(
                  opacity: 0.25,
                  child: Image.asset(
                    'assets/images/logo_awan.png',
                    width: 200,
                    height: 100,
                    fit: BoxFit.contain,
                    color: Colors.white.withOpacity(0.3),
                    colorBlendMode: BlendMode.modulate,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildCloudDecoration(
                          width: 200,
                          height: 100,
                          opacity: 0.25,
                        ),
                  ),
                ),
              ),
            ),

            // Cloud decoration - bottom right (small)
            Positioned(
              bottom: 80,
              right: -30,
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/images/logo_awan.png',
                  width: 140,
                  height: 70,
                  fit: BoxFit.contain,
                  color: Colors.white.withOpacity(0.3),
                  colorBlendMode: BlendMode.modulate,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildCloudDecoration(
                        width: 140,
                        height: 70,
                        opacity: 0.15,
                      ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Center(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_pages[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingContent content) {
    void startNavigation() async {
      await Future.delayed(const Duration(milliseconds: 2500));

      if (!mounted) return;

      final authNotifier = context.read<AuthNotifier>();

      await authNotifier.checkAuthStatus();

      if (!mounted) return;

      final String destinationRoute =
          authNotifier.authState == RequestState.Loaded &&
              authNotifier.user != null
          ? HomePage.ROUTE_NAME
          : LoginPage.ROUTE_NAME;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (context, animation, secondaryAnimation) {
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Cloud decoration - Top (above container)
                Positioned(
                  top: -20,
                  left: -MediaQuery.of(context).size.width * 0.15,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.width * 0.20,
                    child: Opacity(
                      opacity: 0.3,
                      child: Image.asset(
                        'assets/images/logo_awan.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(),
                      ),
                    ),
                  ),
                ),

                // Cloud decoration - Top Right
                Positioned(
                  top: -10,
                  right: -MediaQuery.of(context).size.width * 0.18,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.32,
                    height: MediaQuery.of(context).size.width * 0.18,
                    child: Opacity(
                      opacity: 0.25,
                      child: Image.asset(
                        'assets/images/logo_awan.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(),
                      ),
                    ),
                  ),
                ),

                // Main card
                Container(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.85,
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 80),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo with circles
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF5E6D3).withOpacity(0.4),
                          ),
                          child: Center(
                            child: Container(
                              width: 95,
                              height: 95,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE8C4A0).withOpacity(0.6),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/logo_rekaloka.png',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: kPrimaryBrown.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.account_balance,
                                          size: 35,
                                          color: kPrimaryBrown,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          content.title,
                          style: kHeadingRekaloka.copyWith(
                            fontSize: 34,
                            color: kPrimaryBrown,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          content.subtitle,
                          style: kBodyText.copyWith(
                            fontSize: 11.5,
                            color: kPrimaryBrown.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            letterSpacing: 0.1,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        // Divider
                        Container(
                          width: 70,
                          height: 3,
                          decoration: BoxDecoration(
                            color: kAccentOrange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Description 1
                        Text(
                          content.description,
                          style: kBodyText.copyWith(
                            fontSize: 12,
                            color: kPrimaryBrown,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.1,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 14),

                        // Description 2
                        Text(
                          content.secondDescription,
                          style: kBodyText.copyWith(
                            fontSize: 12,
                            color: kPrimaryBrown,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Cloud decoration - Bottom Left (below container)
                Positioned(
                  bottom: -15,
                  left: -MediaQuery.of(context).size.width * 0.18,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.width * 0.20,
                    child: Opacity(
                      opacity: 0.3,
                      child: Image.asset(
                        'assets/images/logo_awan.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(),
                      ),
                    ),
                  ),
                ),

                // Cloud decoration - Bottom Right
                Positioned(
                  bottom: -25,
                  right: -MediaQuery.of(context).size.width * 0.15,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.30,
                    height: MediaQuery.of(context).size.width * 0.18,
                    child: Opacity(
                      opacity: 0.25,
                      child: Image.asset(
                        'assets/images/logo_awan.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(),
                      ),
                    ),
                  ),
                ),

                // Arrow button at bottom right of card
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        startNavigation();
                      }
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: kAccentOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kAccentOrange.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

//   Widget _buildPageIndicator(int index) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       width: _currentPage == index ? 24 : 8,
//       height: 8,
//       decoration: BoxDecoration(
//         color: _currentPage == index
//             ? kAccentOrange
//             : Colors.white.withOpacity(0.5),
//         borderRadius: BorderRadius.circular(4),
//       ),
//     );
//   }
}

class OnboardingContent {
  final String title;
  final String subtitle;
  final String description;
  final String secondDescription;

  OnboardingContent({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.secondDescription,
  });
}

// Custom cloud clipper for cloud shape
class CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Create cloud-like shape with curves
    path.moveTo(w * 0.2, h * 0.6);

    // Bottom curve
    path.quadraticBezierTo(w * 0.1, h * 0.8, w * 0.25, h * 0.9);
    path.quadraticBezierTo(w * 0.4, h, w * 0.6, h * 0.9);
    path.quadraticBezierTo(w * 0.75, h * 0.85, w * 0.9, h * 0.7);

    // Right side
    path.quadraticBezierTo(w, h * 0.5, w * 0.95, h * 0.3);

    // Top curves
    path.quadraticBezierTo(w * 0.9, h * 0.15, w * 0.75, h * 0.1);
    path.quadraticBezierTo(w * 0.6, h * 0.05, w * 0.5, h * 0.1);
    path.quadraticBezierTo(w * 0.35, h * 0.15, w * 0.25, h * 0.25);

    // Left side
    path.quadraticBezierTo(w * 0.1, h * 0.4, w * 0.2, h * 0.6);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
