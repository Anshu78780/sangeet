import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import 'audio_playback_controller.dart';

class AppAudioHandler extends BaseAudioHandler with SeekHandler {
  AppAudioHandler(this._controller) {
    _controller.player.playbackEventStream.listen(_broadcastState);
    _controller.addListener(_syncMediaState);
    _syncMediaState();
    _broadcastState(_controller.player.playbackEvent);
  }

  static AudioHandler? _instance;

  static Future<void> init() async {
    if (_instance != null) {
      return;
    }

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    _instance = await AudioService.init(
      builder: () => AppAudioHandler(AudioPlaybackController.instance),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.example.sangeet.audio',
        androidNotificationChannelName: 'Sangeet Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }

  final AudioPlaybackController _controller;

  @override
  Future<void> play() => _controller.player.play();

  @override
  Future<void> pause() => _controller.player.pause();

  @override
  Future<void> stop() async {
    await _controller.player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _controller.player.seek(position);

  @override
  Future<void> skipToNext() => _controller.playNext();

  @override
  Future<void> skipToPrevious() => _controller.playPrevious();

  void _syncMediaState() {
    final currentSong = _controller.currentSong;
    if (currentSong != null) {
      mediaItem.add(_toMediaItem(currentSong));
    }
    queue.add(_controller.queue.map(_toMediaItem).toList());
  }

  void _broadcastState(PlaybackEvent event) {
    final player = _controller.player;

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekBackward,
          MediaAction.seekForward,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.stop,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: _mapProcessingState(player.processingState),
        playing: player.playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: _controller.currentIndex < 0 ? 0 : _controller.currentIndex,
      ),
    );
  }

  MediaItem _toMediaItem(Song song) {
    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      artUri: song.thumbnail.isEmpty ? null : Uri.tryParse(song.thumbnail),
      extras: {
        'category': song.category,
      },
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState processingState) {
    switch (processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }
}