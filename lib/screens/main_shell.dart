import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/song.dart';
import '../player/audio_playback_controller.dart';
import '../player/player_screen.dart';
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
  final AudioPlaybackController _audio = AudioPlaybackController.instance;
  bool _miniExpanded = false;
  Timer? _autoCollapseTimer;

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
  void initState() {
    super.initState();
    _audio.addListener(_onAudioChanged);
  }

  @override
  void dispose() {
    _autoCollapseTimer?.cancel();
    _audio.removeListener(_onAudioChanged);
    super.dispose();
  }

  void _onAudioChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _onMiniInteraction() {
    if (!_miniExpanded) {
      return;
    }
    _autoCollapseTimer?.cancel();
    _autoCollapseTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _miniExpanded = false;
        });
      }
    });
  }

  void _toggleMiniExpanded() {
    setState(() {
      _miniExpanded = !_miniExpanded;
    });
    _onMiniInteraction();
  }

  void _openFullPlayer() {
    final song = _audio.currentSong;
    if (song == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          song: song,
          heroTag: 'mini_album_art_${song.id}',
          playlist: _audio.queue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          if (_audio.currentSong != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 92,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  alignment: _miniExpanded ? Alignment.bottomCenter : Alignment.bottomRight,
                  child: _MiniPlayerDock(
                    expanded: _miniExpanded,
                    onTapCollapsed: _toggleMiniExpanded,
                    onTapExpandIcon: _toggleMiniExpanded,
                    onInteraction: _onMiniInteraction,
                    onOpenFullPlayer: _openFullPlayer,
                    controller: _audio,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomNavBar(
              currentIndex: _currentIndex,
              items: _navItems,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ],
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
                color: Colors.black.withValues(alpha: 0.45),
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

class _MiniPlayerDock extends StatefulWidget {
  const _MiniPlayerDock({
    required this.expanded,
    required this.onTapCollapsed,
    required this.onTapExpandIcon,
    required this.onInteraction,
    required this.onOpenFullPlayer,
    required this.controller,
  });

  final bool expanded;
  final VoidCallback onTapCollapsed;
  final VoidCallback onTapExpandIcon;
  final VoidCallback onInteraction;
  final VoidCallback onOpenFullPlayer;
  final AudioPlaybackController controller;

  @override
  State<_MiniPlayerDock> createState() => _MiniPlayerDockState();
}

class _MiniPlayerDockState extends State<_MiniPlayerDock> with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _syncSpin();
  }

  @override
  void didUpdateWidget(covariant _MiniPlayerDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSpin();
  }

  void _syncSpin() {
    final shouldSpin = widget.controller.player.playing;
    if (shouldSpin) {
      _spinController.repeat();
    } else {
      _spinController.stop();
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.controller.currentSong;
    if (song == null) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final expandedWidth = (screenWidth - 32).clamp(250.0, 340.0);
    final width = widget.expanded ? expandedWidth : 64.0;
    final isPlaying = widget.controller.player.playing;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      width: width,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final canRenderExpanded = widget.expanded && constraints.maxWidth >= 220;
          if (canRenderExpanded) {
            return _ExpandedMiniContent(
              song: song,
              spinController: _spinController,
              isPlaying: isPlaying,
              onOpenFullPlayer: widget.onOpenFullPlayer,
              onInteraction: widget.onInteraction,
              onPlayPause: widget.controller.togglePlayPause,
              onNext: widget.controller.playNext,
              onPrevious: widget.controller.playPrevious,
              onCollapse: widget.onTapExpandIcon,
            );
          }
          return _CollapsedMiniContent(
            song: song,
            spinController: _spinController,
            onTap: widget.onTapCollapsed,
          );
        },
      ),
    );
  }
}

class _CollapsedMiniContent extends StatelessWidget {
  const _CollapsedMiniContent({
    required this.song,
    required this.spinController,
    required this.onTap,
  });

  final Song song;
  final AnimationController spinController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Center(
          child: RotationTransition(
            turns: spinController,
            child: Hero(
              tag: 'mini_album_art_${song.id}',
              child: CircleAvatar(
                radius: 27,
                backgroundColor: const Color(0xFF2C2C2C),
                backgroundImage: NetworkImage(song.thumbnail),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandedMiniContent extends StatelessWidget {
  const _ExpandedMiniContent({
    required this.song,
    required this.spinController,
    required this.isPlaying,
    required this.onOpenFullPlayer,
    required this.onInteraction,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onCollapse,
  });

  final Song song;
  final AnimationController spinController;
  final bool isPlaying;
  final VoidCallback onOpenFullPlayer;
  final VoidCallback onInteraction;
  final Future<void> Function() onPlayPause;
  final Future<void> Function() onNext;
  final Future<void> Function() onPrevious;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              onInteraction();
              onOpenFullPlayer();
            },
            child: RotationTransition(
              turns: spinController,
              child: Hero(
                tag: 'mini_album_art_${song.id}',
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF2C2C2C),
                  backgroundImage: NetworkImage(song.thumbnail),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _MiniControlButton(
            onPressed: () {
              onInteraction();
              onPrevious();
            },
            icon: const Icon(Icons.skip_previous, color: Colors.white, size: 20),
          ),
          _MiniControlButton(
            onPressed: () {
              onInteraction();
              onPlayPause();
            },
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: const Color(0xFF1AE3B0),
              size: 22,
            ),
          ),
          _MiniControlButton(
            onPressed: () {
              onInteraction();
              onNext();
            },
            icon: const Icon(Icons.skip_next, color: Colors.white, size: 20),
          ),
          _MiniControlButton(
            onPressed: () {
              onInteraction();
              onCollapse();
            },
            icon: const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }
}

class _MiniControlButton extends StatelessWidget {
  const _MiniControlButton({required this.onPressed, required this.icon});

  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Center(child: icon),
        ),
      ),
    );
  }
}

