import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../core/services/audio_player_service.dart';
import '../models/hymn.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;

  Hymn? _currentHymn;
  bool _isPlaying = false;
  double _currentSpeed = 1.0;

  AudioProvider(this._audioService) {
    _audioService.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
      }
      notifyListeners();
    });
  }

  AudioPlayerService get audioService => _audioService;
  Hymn? get currentHymn => _currentHymn;
  bool get isPlaying => _isPlaying;
  double get currentSpeed => _currentSpeed;

  Future<void> playHymn(Hymn hymn, {String? audioUrl}) async {
    _currentHymn = hymn;
    notifyListeners();

    final url = audioUrl ??
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

    await _audioService.loadAudio(url);
    await _audioService.play();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _currentSpeed = speed;
    await _audioService.setSpeed(speed);
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioService.stop();
    _currentHymn = null;
    _isPlaying = false;
    notifyListeners();
  }
}