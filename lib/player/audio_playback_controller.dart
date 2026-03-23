import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../extractors/vidsave.dart';
import '../extractors/ytdlpro.dart';
import '../models/song.dart';

class AudioPlaybackController extends ChangeNotifier {
  AudioPlaybackController._internal() {
    player.playerStateStream.listen((_) => notifyListeners());
    player.positionStream.listen((position) {
      _maybePrefetchNext(position);
      notifyListeners();
    });
    player.durationStream.listen((_) => notifyListeners());
  }

  static final AudioPlaybackController instance = AudioPlaybackController._internal();

  final AudioPlayer player = AudioPlayer();

  Song? currentSong;
  List<Song> _queue = const [];
  int _currentIndex = -1;
  bool isLoading = false;
  String? error;
  final Map<String, String> _prefetchedUrls = {};
  String? _prefetchingSongId;

  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;

  bool get hasNext => _currentIndex >= 0 && _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  void updateQueue(List<Song> queue, {String? currentSongId}) {
    if (queue.isEmpty) {
      return;
    }

    _queue = queue;
    final targetId = currentSongId ?? currentSong?.id;
    if (targetId != null) {
      final idx = _queue.indexWhere((song) => song.id == targetId);
      if (idx >= 0) {
        _currentIndex = idx;
      }
    }
    notifyListeners();
  }

  Future<void> playSong(
    Song song, {
    List<Song>? queue,
  }) async {
    if (queue != null && queue.isNotEmpty) {
      _queue = queue;
    } else if (_queue.isEmpty) {
      _queue = [song];
    }

    var index = _queue.indexWhere((s) => s.id == song.id);
    if (index < 0) {
      _queue = [..._queue, song];
      index = _queue.length - 1;
    }

    // If same song is already loaded, just resume.
    if (currentSong?.id == song.id && player.audioSource != null) {
      isLoading = false;
      error = null;
      if (!player.playing) {
        await player.play();
      }
      _currentIndex = index;
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    currentSong = song;
    _currentIndex = index;
    notifyListeners();

    try {
      final prefetchedUrl = _prefetchedUrls.remove(song.id);
      final streamUrl = prefetchedUrl ?? await _resolveStreamUrl(song.id);
      if (streamUrl == null || streamUrl.isEmpty) {
        error = 'Could not extract stream link.';
        isLoading = false;
        notifyListeners();
        return;
      }

      await player.setUrl(streamUrl);
      await player.play();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = 'Playback Error: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (player.playing) {
      await player.pause();
    } else {
      await player.play();
    }
    notifyListeners();
  }

  Future<void> playNext() async {
    if (!hasNext) {
      return;
    }
    final nextSong = _queue[_currentIndex + 1];
    await playSong(nextSong, queue: _queue);
  }

  Future<void> playPrevious() async {
    if (!hasPrevious) {
      await player.seek(Duration.zero);
      notifyListeners();
      return;
    }
    final previousSong = _queue[_currentIndex - 1];
    await playSong(previousSong, queue: _queue);
  }

  Future<String?> _resolveStreamUrl(String videoId) async {
    final ytUrl = 'https://www.youtube.com/watch?v=$videoId';

    try {
      final track = await fetchAudioTracks(ytUrl);
      if (track != null && track.audioResources.isNotEmpty) {
        return track.audioResources.first.downloadUrl;
      }
    } catch (_) {
      // Ignore and fallback.
    }

    try {
      return await fetchYtdlproAudioUrl(ytUrl);
    } catch (_) {
      return null;
    }
  }

  void _maybePrefetchNext(Duration position) {
    if (!hasNext) {
      return;
    }

    final duration = player.duration;
    if (duration == null || duration <= Duration.zero) {
      return;
    }

    final remaining = duration - position;
    if (remaining > const Duration(seconds: 20)) {
      return;
    }

    final nextSong = _queue[_currentIndex + 1];
    if (_prefetchedUrls.containsKey(nextSong.id) || _prefetchingSongId == nextSong.id) {
      return;
    }

    _prefetchingSongId = nextSong.id;
    _prefetchNextUrl(nextSong);
  }

  Future<void> _prefetchNextUrl(Song song) async {
    try {
      final url = await _resolveStreamUrl(song.id);
      if (url != null && url.isNotEmpty) {
        _prefetchedUrls[song.id] = url;
      }
    } finally {
      if (_prefetchingSongId == song.id) {
        _prefetchingSongId = null;
      }
    }
  }
}