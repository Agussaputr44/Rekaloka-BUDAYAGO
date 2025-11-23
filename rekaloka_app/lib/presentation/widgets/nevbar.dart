import 'package:flutter/material.dart';
import '../../../common/constants.dart';
import '../pages/home/home_page.dart';

/// Main Navigation Wrapper
/// 
/// BEST PRACTICE EXPLANATION:
/// 1. Gunakan 1 wrapper widget yang handle semua navigation
/// 2. Jangan taruh BottomNavigationBar di setiap page
/// 3. PageView atau IndexedStack untuk switch between pages
/// 4. State management di wrapper, bukan di individual pages
/// 
/// CARA PENGGUNAAN:
/// Di main.dart atau router, arahkan ke MainNavigationWrapper:
/// '/main': (context) => MainNavigationWrapper(),
/// 
/// Keuntungan:
/// - Navbar tidak re-render saat ganti page
/// - State preserved saat switch pages
/// - Performance lebih baik
/// - Code lebih clean dan maintainable

class MainNavigationWrapper extends StatefulWidget {
  static const ROUTE_NAME = '/main';
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  
  // Page Controller untuk smooth transition
  final PageController _pageController = PageController();

  // List of pages
  final List<Widget> _pages = [
    const HomePage(),
    // const LeaderboardPage(),
    const ProfilePage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Animate to page with smooth transition
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        // Disable swipe if you want users to only use bottom nav
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7), // Cream color from design
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home,
                activeIcon: Icons.home,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.emoji_events_outlined,
                activeIcon: Icons.emoji_events,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isActive ? kPrimaryBrown : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: kPrimaryBrown.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? Colors.white : kPrimaryBrown.withOpacity(0.6),
          size: 28,
        ),
      ),
    );
  }
}

// Dummy Profile Page (you can replace with your actual profile page)
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                size: 80,
                color: kPrimaryBrown.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Profile Page',
                style: kHeading5.copyWith(
                  color: kPrimaryBrown,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coming Soon',
                style: kBodyText.copyWith(
                  color: kPrimaryBrown.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}