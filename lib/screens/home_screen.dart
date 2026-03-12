import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good Evening',
                            style: GoogleFonts.outfit(
                                color: Colors.white54, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('Welcome back!',
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF1AE3B0),
                      child: Text('S',
                          style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text('Recently Played',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3.2,
                ),
                delegate: SliverChildListDelegate(
                  _recentItems.map((item) => _RecentCard(item: item)).toList(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text('Featured',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _featuredItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) =>
                      _FeaturedCard(item: _featuredItems[i]),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

const _recentItems = [
  {'title': 'Chill Vibes', 'color': 0xFF1AE3B0},
  {'title': 'Top Hits', 'color': 0xFF297AFF},
  {'title': 'Rap Caviar', 'color': 0xFFFF6B6B},
  {'title': 'Deep Jazz', 'color': 0xFFFFD166},
];

const _featuredItems = [
  {'title': 'Lo-Fi Beats', 'sub': 'Relax & Focus', 'color': 0xFF1A1A2E},
  {'title': 'Midnight', 'sub': 'Taylor Swift', 'color': 0xFF16213E},
  {'title': 'Rap Caviar', 'sub': 'Hot right now', 'color': 0xFF1F1035},
];

class _RecentCard extends StatelessWidget {
  final Map<String, Object> item;
  const _RecentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            decoration: BoxDecoration(
              color: Color(item['color'] as int),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: const Icon(Icons.music_note, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item['title'] as String,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Map<String, Object> item;
  const _FeaturedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Color(item['color'] as int),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(item['title'] as String,
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(item['sub'] as String,
              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }
}
