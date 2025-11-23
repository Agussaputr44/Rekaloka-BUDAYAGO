import 'package:flutter/material.dart';
import 'package:rekaloka_app/presentation/pages/Home/reconstruction_page.dart';

import '../../../common/constants.dart';
import '../../../common/utils.dart';

const List<Map<String, String>> _dummyData = [
  {
    'title': 'Vihara Hok Ann Kiong',
    'address': 'Jl. Yos Sudarso No.124/F, Bengkalis Kota, Kec. Bengkalis',
    'imageUrl':
        'https://placehold.co/400x300/6A4C32/FFFFFF?text=Vihara+Bengkalis',
  },
  {
    'title': 'Rumah Adat Selaso Jatuh Kembar',
    'address': 'Jl. Sudirman, Pekanbaru, Riau',
    'imageUrl':
        'https://placehold.co/400x300/3E8D62/FFFFFF?text=Selaso+Jatuh+Kembar',
  },
  {
    'title': 'Istana Siak Sri Indrapura',
    'address': 'Komp. Istana Siak, Siak, Riau',
    'imageUrl': 'https://placehold.co/400x300/4B778D/FFFFFF?text=Istana+Siak',
  },
];

class HomePage extends StatefulWidget {
  static const ROUTE_NAME = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomePage> {
  // Removed RouteAware mixin since we're using it in wrapper

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header tanpa SafeArea agar langsung dari atas
          const _LocationHeader(),
          
          // Konten dengan background putih dan rounded top
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section (Kartu Utama)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: _HeroSection(),
                    ),

                    const SizedBox(height: 40),

                    // Header Bagian (Budaya Terkait)
                    _SectionHeader(
                      title: 'Budaya Terkait dari Lokasimu',
                      onSeeAllTap: () {
                        print('Navigate to See All Budaya');
                      },
                    ),

                    const SizedBox(height: 16),

                    // Daftar Horizontal (Cultural POI Cards)
                    SizedBox(
                      height: 360,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: const [
                          {
                            'title': 'Vihara Hok Ann Kiong',
                            'address': 'Jl. Yos Sudarso No.124/F, Bengkalis Kota',
                            'imageUrl': 'https://placehold.co/400x300/6A4C32/FFFFFF?text=Vihara',
                          },
                          {
                            'title': 'Rumah Adat Selaso Jatuh Kembar',
                            'address': 'Jl. Sudirman, Pekanbaru, Riau',
                            'imageUrl': 'https://placehold.co/400x300/3E8D62/FFFFFF?text=Rumah+Adat',
                          },
                          {
                            'title': 'Istana Siak Sri Indrapura',
                            'address': 'Komp. Istana Siak, Siak, Riau',
                            'imageUrl': 'https://placehold.co/400x300/4B778D/FFFFFF?text=Istana',
                          },
                        ].length,
                        itemBuilder: (context, index) {
                          final items = const [
                            {
                              'title': 'Vihara Hok Ann Kiong',
                              'address': 'Jl. Yos Sudarso No.124/F, Bengkalis Kota',
                              'imageUrl': 'https://placehold.co/400x300/6A4C32/FFFFFF?text=Vihara',
                            },
                            {
                              'title': 'Rumah Adat Selaso Jatuh Kembar',
                              'address': 'Jl. Sudirman, Pekanbaru, Riau',
                              'imageUrl': 'https://placehold.co/400x300/3E8D62/FFFFFF?text=Rumah+Adat',
                            },
                            {
                              'title': 'Istana Siak Sri Indrapura',
                              'address': 'Komp. Istana Siak, Siak, Riau',
                              'imageUrl': 'https://placehold.co/400x300/4B778D/FFFFFF?text=Istana',
                            },
                          ];
                          final item = items[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == items.length - 1 ? 0 : 16.0,
                            ),
                            child: _CulturalPoiCard(data: item),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Leaderboard Section
                    _SectionHeader(
                      title: 'Leaderboard',
                      onSeeAllTap: () {
                        print('Navigate to full leaderboard');
                      },
                    ),

                    const SizedBox(height: 16),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: _LeaderboardSection(),
                    ),

                    const SizedBox(height: 80), // Extra space for bottom nav
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Leaderboard Section
class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection();

  @override
  Widget build(BuildContext context) {
    // DUMMY DATA for leaderboard
    final topThree = [
      {'name': 'John Smith', 'level': 58, 'rank': 2},
      {'name': 'Sarah M', 'level': 100, 'rank': 1},
      {'name': 'Alice Wang', 'level': 30, 'rank': 3},
    ];

    final otherUsers = [
      {'name': 'Dinda Sari', 'level': 28, 'rank': 4, 'badge': 'explorer'},
      {'name': 'Fajar M', 'level': 25, 'rank': 5, 'badge': 'explorer'},
      {'name': 'Mia Tania', 'level': 19, 'rank': 6, 'badge': 'explorer'},
      {'name': 'Kamu', 'level': 12, 'rank': 7, 'badge': 'beginner', 'isCurrentUser': true},
      {'name': 'Lusi N', 'level': 9, 'rank': 8, 'badge': 'beginner'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryBrown.withOpacity(0.5), width: 1),
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBrown.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top 3 Podium
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rank 2
                _buildPodiumItem(topThree[0], 2),
                const SizedBox(width: 12),
                // Rank 1
                _buildPodiumItem(topThree[1], 1),
                const SizedBox(width: 12),
                // Rank 3
                _buildPodiumItem(topThree[2], 3),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // List of other users
          ...otherUsers.map((user) => _buildLeaderboardItem(user)),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> user, int rank) {
    final isFirst = rank == 1;
    
    return SizedBox(
      width: 90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Avatar with crown
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: isFirst ? 70 : 60,
                height: isFirst ? 70 : 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: _getRankColor(rank),
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: isFirst ? 35 : 30,
                  color: kPrimaryBrown.withOpacity(0.3),
                ),
              ),
              if (isFirst)
                Positioned(
                  top: -12,
                  left: 0,
                  right: 0,
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          // Name
          Text(
            user['name'].toString(),
            style: kBodyText.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kPrimaryBrown,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _getRankColor(rank).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getBadgeIcon(rank),
              size: 12,
              color: _getRankColor(rank),
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Lvl. ${user['level']}',
              style: kBodyText.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: kPrimaryBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user) {
    final isCurrentUser = user['isCurrentUser'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kPrimaryBrown.withOpacity(isCurrentUser ? 0.15 : 0.8),
        borderRadius: BorderRadius.circular(14),
        border: isCurrentUser
            ? Border.all(color: kAccentOrange, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Star for current user
          if (isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                Icons.star,
                color: kAccentOrange,
                size: 18,
              ),
            ),
          
          // Rank
          SizedBox(
            width: 25,
            child: Text(
              '${user['rank']}',
              style: kBodyText.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isCurrentUser ? kPrimaryBrown : kTextWhite,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              Icons.person,
              size: 18,
              color: kPrimaryBrown.withOpacity(0.3),
            ),
          ),
          
          const SizedBox(width: 10),
          
          // Name
          Expanded(
            child: Text(
              user['name'].toString(),
              style: kBodyText.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isCurrentUser ? kPrimaryBrown : kTextWhite,
              ),
            ),
          ),
          
          // Badge icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getBadgeColor(user['badge']).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getBadgeIconFromName(user['badge']),
              size: 14,
              color: _getBadgeColor(user['badge']),
            ),
          ),
          
          const SizedBox(width: 10),
          
          // Level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isCurrentUser ? kAccentOrange : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Lvl. ${user['level']}',
              style: kBodyText.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isCurrentUser ? kTextWhite : kPrimaryBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade300;
      default:
        return kPrimaryBrown;
    }
  }

  IconData _getBadgeIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.workspace_premium;
      case 2:
        return Icons.military_tech;
      case 3:
        return Icons.diamond;
      default:
        return Icons.shield;
    }
  }

  Color _getBadgeColor(dynamic badge) {
    if (badge == null) return Colors.grey;
    String badgeStr = badge.toString().toLowerCase();
    if (badgeStr.contains('master')) return Colors.purple;
    if (badgeStr.contains('premium')) return Colors.orange;
    if (badgeStr.contains('explorer')) return Colors.blue;
    return Colors.grey;
  }

  IconData _getBadgeIconFromName(dynamic badge) {
    if (badge == null) return Icons.shield;
    String badgeStr = badge.toString().toLowerCase();
    if (badgeStr.contains('master')) return Icons.workspace_premium;
    if (badgeStr.contains('premium')) return Icons.military_tech;
    if (badgeStr.contains('explorer')) return Icons.explore;
    return Icons.shield;
  }
}

// ------------------------------------
// ## Sub-Widgets
// ------------------------------------

// Widget Header Lokasi
class _LocationHeader extends StatelessWidget {
  const _LocationHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Tambahkan padding top untuk status bar
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        16,
      ),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/bg_awan.png'),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
        color: kPrimaryBrown.withOpacity(0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teks "Home"
          Text(
            'Home',
            style: kHeading5.copyWith(
              color: kTextWhite,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Kolom untuk "Rekaloka" dan "Riau"
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_pin,
                          color: kTextWhite,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Rekaloka',
                          style: kHeadingRekaloka.copyWith(
                            color: kTextWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(left: 22),
                      child: Text(
                        'Riau',
                        style: kBodyText.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: kTextWhite.withOpacity(0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kAccentOrange.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kTextWhite.withOpacity(0.3),
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/bg_awan.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget Hero Section (Kartu Utama)
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kPrimaryBrown,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBrown.withOpacity(0.6),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Bagian Kiri: Teks dan Tombol
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jelajahi & Rekonstruksi Warisan Budaya dengan 3D',
                  style: kHeading5.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextWhite,
                    height: 1.3,
                  ),
                  maxLines: 4,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kAccentOrange,
                        kAccentOrange.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: kAccentOrange.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(ReconstructionPage.ROUTE_NAME);
                      // print('Mulai Rekonstruksi tapped');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: kTextWhite,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Mulai Rekonstruksi',
                          style: kButtonText.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios, size: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Bagian Kanan: Gambar Wayang
          Expanded(
            flex: 4,
            child: Image.asset(
              'assets/images/fg_wayang.png',
              fit: BoxFit.fitHeight,
              height: 150,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF50341F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Karakter 3D',
                    style: kBodyText.copyWith(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Header Bagian ("Budaya Terkait dari Lokasimu")
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAllTap;

  const _SectionHeader({required this.title, required this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: kHeading5.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kPrimaryBrown,
            ),
          ),
          GestureDetector(
            onTap: onSeeAllTap,
            child: Text(
              'see all',
              style: kSubtitle.copyWith(
                color: kAccentOrange,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Kartu POI Budaya (Item Horizontal Scroll)
class _CulturalPoiCard extends StatelessWidget {
  final Map<String, String> data;

  const _CulturalPoiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: kPrimaryBrown.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              data['imageUrl']!,
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 170,
                color: const Color(0xFF42342E),
                child: Center(
                  child: Text(
                    'Gambar POI',
                    style: kBodyText.copyWith(color: Colors.white70),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title']!,
                  style: kSubtitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextWhite,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  data['address']!,
                  style: kBodyText.copyWith(
                    fontSize: 12,
                    color: kTextWhite.withOpacity(0.75),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      print('Lihat ${data['title']} tapped');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentOrange,
                      foregroundColor: kTextWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat',
                          style: kButtonText.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios, size: 12),
                      ],
                    ),
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