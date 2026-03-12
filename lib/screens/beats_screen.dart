import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BeatsScreen extends StatelessWidget {
  const BeatsScreen({super.key});

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
              Text('Beats',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Trending tracks right now',
                  style: GoogleFonts.outfit(
                      color: Colors.white38, fontSize: 14)),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: _tracks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, i) {
                    final t = _tracks[i];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(t['color'] as int),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.music_note,
                            color: Colors.white, size: 22),
                      ),
                      title: Text(t['title'] as String,
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      subtitle: Text(t['artist'] as String,
                          style: GoogleFonts.outfit(
                              color: Colors.white38, fontSize: 12)),
                      trailing: const Icon(Icons.play_circle_fill,
                          color: Color(0xFF1AE3B0), size: 32),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _tracks = [
  {'title': 'Blinding Lights', 'artist': 'The Weeknd', 'color': 0xFF1A1A2E},
  {'title': 'Levitating', 'artist': 'Dua Lipa', 'color': 0xFF16213E},
  {'title': 'Stay', 'artist': 'The Kid LAROI', 'color': 0xFF1F1035},
  {'title': 'Peaches', 'artist': 'Justin Bieber', 'color': 0xFF0E4A4A},
  {'title': 'Good 4 U', 'artist': 'Olivia Rodrigo', 'color': 0xFF3B1F2B},
  {'title': 'Montero', 'artist': 'Lil Nas X', 'color': 0xFF1A2E1A},
  {'title': 'Industry Baby', 'artist': 'Lil Nas X', 'color': 0xFF2E1A1A},
];
