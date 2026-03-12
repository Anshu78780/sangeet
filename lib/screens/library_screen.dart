import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Library',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1AE3B0),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.add, color: Colors.black, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _sectionHeader('Playlists'),
                    const SizedBox(height: 12),
                    ..._playlists.map((p) => _LibraryTile(
                          title: p['title'] as String,
                          sub: p['sub'] as String,
                          color: Color(p['color'] as int),
                        )),
                    const SizedBox(height: 20),
                    _sectionHeader('Albums'),
                    const SizedBox(height: 12),
                    ..._albums.map((a) => _LibraryTile(
                          title: a['title'] as String,
                          sub: a['sub'] as String,
                          color: Color(a['color'] as int),
                          isAlbum: true,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title,
        style: GoogleFonts.outfit(
            color: Colors.white54, fontSize: 12, letterSpacing: 1.2));
  }
}

class _LibraryTile extends StatelessWidget {
  final String title;
  final String sub;
  final Color color;
  final bool isAlbum;

  const _LibraryTile({
    required this.title,
    required this.sub,
    required this.color,
    this.isAlbum = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  isAlbum ? BorderRadius.circular(4) : BorderRadius.circular(8),
            ),
            child: Icon(
              isAlbum ? Icons.album : Icons.queue_music,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(sub,
                  style:
                      GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

const _playlists = [
  {'title': 'Liked Songs', 'sub': '142 songs', 'color': 0xFF297AFF},
  {'title': 'Chill Mode', 'sub': '34 songs', 'color': 0xFF1AE3B0},
  {'title': 'Workout Mix', 'sub': '21 songs', 'color': 0xFFFF6B35},
];

const _albums = [
  {'title': 'Midnights', 'sub': 'Taylor Swift', 'color': 0xFF1A1A2E},
  {'title': 'SOS', 'sub': 'SZA', 'color': 0xFF1F1035},
];
