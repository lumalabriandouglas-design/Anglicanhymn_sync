import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  // Streams the UI will listen to
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  Future<void> init() async {
    // Future-proofing for audio_service / background later
    try {
      // You can add audio session configuration here later if needed
    } catch (e) {
      debugPrint('AudioPlayerService init error: $e');
    }
  }

  /// Load from network URL or local asset
  Future<void> loadAudio(String urlOrAsset) async {
    try {
      if (urlOrAsset.startsWith('http') || urlOrAsset.startsWith('https')) {
        await _player.setUrl(urlOrAsset);
      } else {
        // Local asset (e.g. 'assets/audio/hymn_1.mp3')
        await _player.setAsset(urlOrAsset);
      }
    } catch (e) {
      debugPrint('Failed to load audio: $e');
      rethrow;
    }
  }

  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      debugPrint('Play error: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('Pause error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      await _player.seek(Duration.zero);
    } catch (e) {
      debugPrint('Stop error: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('Seek error: $e');
    }
  }

  Future<void> setSpeed(double speed) async {
    try {
      await _player.setSpeed(speed);
    } catch (e) {
      debugPrint('Set speed error: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('Set volume error: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}