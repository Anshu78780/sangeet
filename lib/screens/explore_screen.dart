import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

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
              Text('Explore',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: Colors.white38, size: 20),
                    const SizedBox(width: 8),
                    Text('Artists, songs, playlists…',
                        style: GoogleFonts.outfit(
                            color: Colors.white38, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Browse Categories',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: _categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                  ),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: Color(cat['color'] as int),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Text(cat['name'] as String,
                          style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600)),
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

const _categories = [
  {'name': 'Pop', 'color': 0xFF1DB954},
  {'name': 'Hip-Hop', 'color': 0xFFE91429},
  {'name': 'Lo-Fi', 'color': 0xFF297AFF},
  {'name': 'Jazz', 'color': 0xFF8B5CF6},
  {'name': 'Rock', 'color': 0xFFFF6B35},
  {'name': 'Classical', 'color': 0xFF1AE3B0},
  {'name': 'Electronic', 'color': 0xFFEC4899},
  {'name': 'R&B', 'color': 0xFFF59E0B},
];
