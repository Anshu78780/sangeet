import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'beats_screen.dart';
import 'library_screen.dart';
import 'account_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    ExploreScreen(),
    BeatsScreen(),
    LibraryScreen(),
    AccountScreen(),
  ];

  static const _navItems = [
    _NavItem(icon: MaterialCommunityIcons.home, label: 'Home'),
    _NavItem(icon: MaterialCommunityIcons.compass_outline, label: 'Explore'),
    _NavItem(icon: MaterialCommunityIcons.play_circle_outline, label: 'Beats'),
    _NavItem(icon: MaterialCommunityIcons.bookmark_outline, label: 'Library'),
    _NavItem(icon: MaterialCommunityIcons.account_outline, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double barHeight = 62.0;
    const double hMargin = 20.0;
    const double bMargin = 16.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(hMargin, 0, hMargin, bMargin),
        child: Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Black shared background
            borderRadius: BorderRadius.circular(barHeight / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (i) {
              final isActive = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: isActive
                      ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                      : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: isActive
                      ? BoxDecoration(
                          color: const Color(0xFF1AE3B0),
                          borderRadius: BorderRadius.circular(30),
                        )
                      : const BoxDecoration(
                          color: Colors.transparent,
                        ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].icon,
                        color: isActive ? Colors.black : Colors.white54,
                        size: isActive ? 18 : 22,
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 5),
                        Text(
                          items[i].label,
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

