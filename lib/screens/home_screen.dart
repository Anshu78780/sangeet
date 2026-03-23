import "../player/player_screen.dart";
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _error;
  List<Song> _recentItems = [];
  Map<String, List<Song>> _categorizedSongs = {};

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    try {
      final response = await http.get(Uri.parse('https://vibra-server-v33i.onrender.com/homepage'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        final List dynamicSongs = data['trending_music'] ?? [];
        
        final List<Song> allSongs = dynamicSongs.map((e) => Song.fromJson(e)).toList();

        final Map<String, List<Song>> categorized = {};
        for (var song in allSongs) {
          if (song.category.isNotEmpty) {
            categorized.putIfAbsent(song.category, () => []).add(song);
          }
        }

        setState(() {
          _recentItems = allSongs.take(6).toList();
          _categorizedSongs = categorized;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load data (Status ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  String _formatCategoryName(String key) {
    if (key == 'new_releases') return 'New Releases';
    final parts = key.split('_');
    return parts.map((e) => e.isNotEmpty ? '${e[0].toUpperCase()}${e.substring(1)}' : '').join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Spotify dark background
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1AE3B0)))
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: GoogleFonts.outfit(color: Colors.white),
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Good Evening',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.search, color: Colors.white),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const SearchScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              _buildChip('Music'),
                              const SizedBox(width: 8),
                              _buildChip('Podcasts & Shows'),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      if (_recentItems.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 3.0,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return _RecentSongCard(
                                  song: _recentItems[index],
                                  playlist: _recentItems,
                                );
                              },
                              childCount: _recentItems.length,
                            ),
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 24)),

                      ..._categorizedSongs.entries.map((entry) {
                        return SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(
                                  _formatCategoryName(entry.key),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 200,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: entry.value.length,
                                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                                  itemBuilder: (context, i) => _FeaturedSongCard(
                                    song: entry.value[i],
                                    playlist: entry.value,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      }),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _RecentSongCard extends StatelessWidget {
  final Song song;
  final List<Song> playlist;

  const _RecentSongCard({required this.song, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(
              song: song,
              heroTag: 'recent_album_art_${song.id}',
              playlist: playlist,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Hero(
              tag: 'recent_album_art_${song.id}',
              child: Image.network(
                song.thumbnail,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[800],
                  child: const Icon(Icons.music_note, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  song.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedSongCard extends StatelessWidget {
  final Song song;
  final List<Song> playlist;

  const _FeaturedSongCard({required this.song, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(
              song: song,
              heroTag: 'featured_album_art_${song.id}',
              playlist: playlist,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 140,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFF282828),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Hero(
                tag: 'featured_album_art_${song.id}',
                child: Image.network(
                  song.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.music_note, color: Colors.white54, size: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: const Color(0xFFA7A7A7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
