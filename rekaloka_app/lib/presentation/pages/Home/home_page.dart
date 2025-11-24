import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'reconstruction_page.dart';
import '../../provider/location_notifier.dart';

import '../../../common/constants.dart';
import '../../../common/state.dart';
import '../../provider/leaderboard_notifier.dart';

// T sl<T extends Object>() => throw UnimplementedError('Dependency Injection not initialized');

class HomePage extends StatefulWidget {
  static const ROUTE_NAME = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const _LocationHeader(),

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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: _HeroSection(),
                    ),

                    const SizedBox(height: 40),

                    _SectionHeader(
                      title: 'Budaya Terkait dari Lokasimu',
                      onSeeAllTap: () {
                        print('Navigate to See All Budaya');
                      },
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 360,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: 3,
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

                    _SectionHeader(
                      title: 'Leaderboard',
                      onSeeAllTap: () {
                        print('Navigate to full leaderboard');
                      },
                    ),

                    const SizedBox(height: 16),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: LeaderboardSection(),
                    ),

                    const SizedBox(height: 80),
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

// ******************************************************
// WIDGET LEADERBOARD (MODIFIED)
// ******************************************************

class LeaderboardSection extends StatefulWidget {
  const LeaderboardSection({super.key});

  @override
  State<LeaderboardSection> createState() => _LeaderboardSectionState();
}

class _LeaderboardSectionState extends State<LeaderboardSection> {
  // Menghapus inisialisasi AuthLocalDatasource dan _currentUserId
  // late final AuthLocalDatasource _authLocalDatasource = sl<AuthLocalDatasource>();
  // String? _currentUserId;

@override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      // GANTI BARIS INI:
      
      final notifier = Provider.of<LeaderboardNotifier>(context, listen: false); 
      
      notifier.fetchLeaderboard(8).then((_) {
      });
    });
  }
  @override
  Widget build(BuildContext context) {

    return Consumer<LeaderboardNotifier>(
      builder: (context, notifier, child) {

        // 1. Loading State
        if (notifier.state == RequestState.Loading) {
          return _buildLoadingState();
        }

        // 2. Error State
        if (notifier.state == RequestState.Error) {
          return _buildErrorState(notifier.message);
        }

        // 3. Empty State (setelah loaded tapi list kosong)
        if (notifier.state == RequestState.Loaded && notifier.entries.isEmpty) {
          return _buildEmptyState();
        }

        // 4. Loaded State - Process Data
        print('🟢 UI BUILD: Processing ${notifier.entries.length} entries...');

        try {
          final List<Map<String, dynamic>> processedData = notifier.entries.map((entry) {
            final entryMap = (entry as dynamic).toMap();

            final username = entryMap['username'] ?? 'User Name';
            final level = entryMap['level'] ?? 0;
            final rank = entryMap['rank'] ?? 999;
            final badges = entryMap['badges'] ?? [];

            final String badgeName = (badges.isNotEmpty && badges.first is Map && (badges.first as Map).containsKey('name'))
                ? (badges.first as Map)['name']
                : _determineBadgeByLevel(level);

            return {
              'name': username,
              'level': level,
              'rank': rank,
              'badge': badgeName,
              // Menghilangkan flag current user
              // 'isCurrentUser': isCurrentUser,
              // 'id': entryId,
            };
          }).toList().cast<Map<String, dynamic>>();

          if (processedData.isNotEmpty) {
          }

          final topThree = processedData.length >= 3 ? processedData.sublist(0, 3) : processedData;
          final otherUsers = processedData.length > 3 ? processedData.sublist(3) : [];

          topThree.sort((a, b) => (a['rank'] as int).compareTo(b['rank'] as int));

          final List<Map<String, dynamic>> podiumOrder = [];
          if (topThree.length == 3) {
            podiumOrder.add(topThree[1]); 
            podiumOrder.add(topThree[0]); 
            podiumOrder.add(topThree[2]); 
          } else {
            podiumOrder.addAll(topThree);
          }

          return Container(
            padding: const EdgeInsets.all(16),
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / 3;
                    return SizedBox(
                      height: 220,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: podiumOrder.map((user) {
                          final rank = user['rank'] as int;
                          return SizedBox(
                            width: itemWidth,
                            child: _buildPodiumItem(user, rank, itemWidth),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                ...otherUsers.map((user) => _buildLeaderboardItem(user)),
              ],
            ),
          );
        } catch (e) {
          return _buildErrorState('Kesalahan format data UI. Cek log untuk detail.');
        }
      },
    );
  }

  // =======================================================
  // Logika Badge
  // =======================================================

  String _determineBadgeByLevel(int level) {
    if (level >= 80) return 'Maestro';
    if (level >= 50) return 'Pakar Warisan';
    if (level >= 20) return 'Penjelajah Budaya';
    return 'Turis Biasa';
  }

  Color _getBadgeColor(dynamic badge) {
    if (badge == null) return Colors.grey;
    String badgeStr = badge.toString().toLowerCase();

    if (badgeStr.contains('maestro')) return Colors.purple;
    if (badgeStr.contains('pakar')) return Colors.red.shade600;
    if (badgeStr.contains('penjelajah')) return Colors.blue;
    if (badgeStr.contains('turis')) return Colors.green.shade600;

    if (badgeStr.contains('master')) return Colors.purple;
    if (badgeStr.contains('explorer')) return Colors.blue;
    return Colors.grey;
  }

  IconData _getBadgeIconFromName(dynamic badge) {
    if (badge == null) return Icons.shield;
    String badgeStr = badge.toString().toLowerCase();

    if (badgeStr.contains('maestro')) return Icons.school;
    if (badgeStr.contains('pakar')) return Icons.star_half;
    if (badgeStr.contains('penjelajah')) return Icons.explore;
    if (badgeStr.contains('turis')) return Icons.directions_walk;

    if (badgeStr.contains('master')) return Icons.workspace_premium;
    if (badgeStr.contains('explorer')) return Icons.explore;
    return Icons.shield;
  }

  // =======================================================
  // UI States
  // =======================================================

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: kAccentOrange),
            const SizedBox(height: 16),
            Text('Memuat Leaderboard...', style: kBodyText.copyWith(color: kPrimaryBrown)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.shade300, width: 1),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                'Gagal Memuat Data:',
                style: kSubtitle.copyWith(color: kPrimaryBrown, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                textAlign: TextAlign.center,
                style: kBodyText.copyWith(color: kPrimaryBrown),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  print('🔄 UI: Retry button pressed');
                  sl<LeaderboardNotifier>().fetchLeaderboard(8);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentOrange,
                  foregroundColor: kTextWhite,
                ),
                child: const Text('Coba Lagi'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kPrimaryBrown.withOpacity(0.3), width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 60, color: kPrimaryBrown.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'Belum ada data leaderboard',
              style: kSubtitle.copyWith(color: kPrimaryBrown),
            ),
            const SizedBox(height: 8),
            Text(
              'Jadilah yang pertama!',
              style: kBodyText.copyWith(color: kPrimaryBrown.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================
  // UI Components
  // =======================================================

  Widget _buildPodiumItem(Map<String, dynamic> user, int rank, double maxWidth) {
    final isFirst = rank == 1;
    final profileSize = isFirst ? maxWidth * 0.7 : maxWidth * 0.6;
    final iconSize = isFirst ? profileSize * 0.5 : profileSize * 0.45;
    final trophySize = profileSize * 0.4;
    final fontSizeName = isFirst ? 12.0 : 11.0;
    final fontSizeLevel = 10.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar dan Trofi
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: profileSize,
              height: profileSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: _getRankColor(rank), width: isFirst ? 4 : 3),
              ),
              child: Icon(
                Icons.person,
                size: iconSize,
                color: kPrimaryBrown.withOpacity(0.3),
              ),
            ),
            if (isFirst)
              Positioned(
                top: -trophySize / 2,
                left: 0,
                right: 0,
                child: Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: trophySize,
                ),
              ),
          ],
        ),

        const SizedBox(height: 6),

        // Nama
        Text(
          user['name'].toString(),
          style: kBodyText.copyWith(
            fontSize: fontSizeName,
            fontWeight: FontWeight.w600,
            color: kPrimaryBrown,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Badge Rank
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
              fontSize: fontSizeLevel,
              fontWeight: FontWeight.w700,
              color: kPrimaryBrown,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user) {
    // Menghilangkan isCurrentUser dan styling terkait
    // final isCurrentUser = user['isCurrentUser'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        // Styling seragam
        color: kPrimaryBrown.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        // border: isCurrentUser ? Border.all(color: kAccentOrange, width: 2) : null,
      ),
      child: Row(
        children: [
          // Menghilangkan icon bintang isCurrentUser
          // if (isCurrentUser)
          //   const Padding(
          //     padding: EdgeInsets.only(right: 6),
          //     child: Icon(Icons.star, color: kAccentOrange, size: 18),
          //   ),

          // Rank
          SizedBox(
            width: 25,
            child: Text(
              '${user['rank']}',
              style: kBodyText.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kTextWhite, // Warna seragam
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
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
                color: kTextWhite, // Warna seragam
              ),
              overflow: TextOverflow.ellipsis,
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
              color: Colors.white.withOpacity(0.9), // Warna seragam
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Lvl. ${user['level']}',
              style: kBodyText.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: kPrimaryBrown, // Warna seragam
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
}

// ******************************************************
// OTHER WIDGETS (Unchanged from original)
// ******************************************************

class _LocationHeader extends StatefulWidget {
  const _LocationHeader();

  @override
  State<_LocationHeader> createState() => _LocationHeaderState();
}

class _LocationHeaderState extends State<_LocationHeader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationNotifier>(context, listen: false).fetchLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocationNotifier>();

    return Container(
      width: double.infinity,
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
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
                    Row(
                      children: [
                        const Icon(
                          Icons.location_pin,
                          color: kTextWhite,
                          size: 18,
                        ),
                        const SizedBox(width: 2),
                        Padding(
                          padding: const EdgeInsets.only(left: 22),
                          child: provider.loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : provider.addressName != null
                                  ? Text(
                                      provider.addressName!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: kTextWhite,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : provider.failure != null
                                      ? const Text(
                                          "Gagal mengambil lokasi.",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: kTextWhite,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      : const Text(
                                          "Mengambil lokasi...",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: kTextWhite,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
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
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize
                  .min, 
              children: [
                // Teks Judul
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

                const SizedBox(
                  height: 16,
                ), 
                // Tombol Rekonstruksi
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kAccentOrange, kAccentOrange.withOpacity(0.8)],
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
                      Navigator.of(
                        context,
                      ).pushNamed(ReconstructionPage.ROUTE_NAME);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: kTextWhite,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
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

          // Jarak horizontal antara kolom
          const SizedBox(width: 8),

          Expanded(
            flex: 5,
            child: Image.asset(
              'assets/images/fg_wayang.png',
              fit: BoxFit.fitHeight,
              height: 150,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
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