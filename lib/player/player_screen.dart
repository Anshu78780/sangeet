import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import '../models/song.dart';
import '../services/recommendation_service.dart';
import 'audio_playback_controller.dart';

class PlayerScreen extends StatefulWidget {
  final Song song;
  final String heroTag;
  final List<Song> playlist;
  
  const PlayerScreen({
    super.key,
    required this.song,
    required this.heroTag,
    required this.playlist,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlaybackController _audio = AudioPlaybackController.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Song> _recommendations = const [];
  bool _isRecommendationsLoading = false;
  String? _recommendationError;
  String? _recommendationsForSongId;
  StreamSubscription<PlayerState>? _playerStateSub;
  bool _isHandlingCompletion = false;

  @override
  void initState() {
    super.initState();
    _audio.addListener(_onAudioUpdated);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audio.playSong(widget.song, queue: widget.playlist);
    });
    _playerStateSub = _audio.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleTrackCompletion();
      }
    });
  }

  @override
  void didUpdateWidget(covariant PlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.id != widget.song.id) {
      _audio.playSong(widget.song, queue: widget.playlist);
    }
  }

  void _onAudioUpdated() {
    final activeSongId = _audio.currentSong?.id ?? widget.song.id;
    if (_recommendationsForSongId != activeSongId) {
      _loadRecommendations(activeSongId);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadRecommendations(String songId) async {
    if (_isRecommendationsLoading || _recommendationsForSongId == songId) {
      return;
    }

    _isRecommendationsLoading = true;
    _recommendationError = null;
    if (mounted) {
      setState(() {});
    }

    final recs = await RecommendationService.getRecommendations(songId, limit: 50);
    if (!mounted) {
      return;
    }

    _recommendations = recs;
    _recommendationsForSongId = songId;
    _isRecommendationsLoading = false;

    if (recs.isEmpty) {
      _recommendationError = 'No recommendations available right now.';
    }

    final mergedQueue = <Song>[];
    final seen = <String>{};
    for (final song in [..._audio.queue, ...recs]) {
      if (song.id.isEmpty || seen.contains(song.id)) {
        continue;
      }
      seen.add(song.id);
      mergedQueue.add(song);
    }

    if (mergedQueue.isNotEmpty) {
      _audio.updateQueue(mergedQueue, currentSongId: songId);
    }

    setState(() {});
  }

  Future<void> _handleTrackCompletion() async {
    if (_isHandlingCompletion) {
      return;
    }

    _isHandlingCompletion = true;
    try {
      if (_audio.hasNext) {
        await _audio.playNext();
      }
    } finally {
      Future.delayed(const Duration(milliseconds: 450), () {
        _isHandlingCompletion = false;
      });
    }
  }

  void _openRecommendationsDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Future<void> _playFromRecommendation(Song song) async {
    await _audio.playSong(song, queue: _audio.queue);
    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  void dispose() {
    _audio.removeListener(_onAudioUpdated);
    _playerStateSub?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final activeSong = _audio.currentSong ?? widget.song;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF121212),
      endDrawer: _RecommendationDrawer(
        isLoading: _isRecommendationsLoading,
        error: _recommendationError,
        recommendations: _recommendations,
        currentSongId: activeSong.id,
        onTapSong: _playFromRecommendation,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Now Playing',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music_rounded, color: Colors.white),
            onPressed: _openRecommendationsDrawer,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final coverSize = (constraints.maxWidth - 48).clamp(220.0, 360.0);
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
              // Beautiful animated or static album art
              Hero(
                tag: widget.heroTag,
                child: Container(
                  width: coverSize,
                  height: coverSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(activeSong.thumbnail),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title and Artist
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeSong.title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeSong.artist,
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white, size: 28),
                    onPressed: () {},
                  )
                ],
              ),
              const SizedBox(height: 24),

              if (_audio.error != null)
                Text(
                  _audio.error!,
                  style: GoogleFonts.outfit(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),

              // Progress Bar
              StreamBuilder<Duration>(
                stream: _audio.player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _audio.player.duration ?? Duration.zero;

                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          min: 0,
                          max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
                          value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0),
                          onChanged: (value) {
                            _audio.player.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shuffle, color: Colors.white54, size: 28),
                    onPressed: _openRecommendationsDrawer,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white, size: 40),
                    onPressed: _audio.playPrevious,
                  ),
                  _audio.isLoading
                      ? Container(
                          width: 72,
                          height: 72,
                          padding: const EdgeInsets.all(18),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1AE3B0),
                          ),
                          child: const CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 3,
                          ),
                        )
                      : StreamBuilder<PlayerState>(
                          stream: _audio.player.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final playing = playerState?.playing ?? false;
                            return GestureDetector(
                              onTap: () {
                                _audio.togglePlayPause();
                              },
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF1AE3B0),
                                ),
                                child: Icon(
                                  playing ? Icons.pause : Icons.play_arrow,
                                  color: Colors.black,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white, size: 40),
                    onPressed: _audio.playNext,
                  ),
                  IconButton(
                    icon: const Icon(Icons.repeat, color: Colors.white54, size: 28),
                    onPressed: _openRecommendationsDrawer,
                  ),
                ],
              ),
              const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecommendationDrawer extends StatelessWidget {
  const _RecommendationDrawer({
    required this.isLoading,
    required this.error,
    required this.recommendations,
    required this.currentSongId,
    required this.onTapSong,
  });

  final bool isLoading;
  final String? error;
  final List<Song> recommendations;
  final String currentSongId;
  final ValueChanged<Song> onTapSong;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.86,
      backgroundColor: const Color(0xFF10151E),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1AE3B0).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Up Next',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF1AE3B0)),
                    )
                  : error != null && recommendations.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              error!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(color: Colors.white54),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                          itemCount: recommendations.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final song = recommendations[index];
                            final isCurrent = song.id == currentSongId;
                            return Material(
                              color: const Color(0xFF19212D),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: isCurrent ? null : () => onTapSong(song),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(9),
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: song.thumbnail.isEmpty
                                              ? Container(
                                                  color: const Color(0xFF263246),
                                                  child: const Icon(Icons.music_note, color: Colors.white54),
                                                )
                                              : Image.network(
                                                  song.thumbnail,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    color: const Color(0xFF263246),
                                                    child: const Icon(Icons.music_note, color: Colors.white54),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              song.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              song.artist,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isCurrent)
                                        const Icon(Icons.graphic_eq_rounded, color: Color(0xFF1AE3B0))
                                      else
                                        const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
