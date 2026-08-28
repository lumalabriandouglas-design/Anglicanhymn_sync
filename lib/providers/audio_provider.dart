import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../core/constants/hymn_audio.dart';
import '../core/services/audio_player_service.dart';
import '../models/hymn.dart';
import 'settings_provider.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;

  Hymn? _currentHymn;
  List<Hymn> _allHymns = [];
  bool _isPlaying = false;
  double _currentSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = false;
  String? _error;
  LyricsLanguage _audioLanguage = LyricsLanguage.english;

  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;

  AudioProvider(this._audioService) {
    _initListeners();
  }

  AudioPlayerService get audioService => _audioService;
  Hymn? get currentHymn => _currentHymn;
  bool get isPlaying => _isPlaying;
  double get currentSpeed => _currentSpeed;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LyricsLanguage get audioLanguage => _audioLanguage;

  List<Hymn> get playableHymns =>
      _allHymns.where(HymnAudio.hasAudio).toList();

  double get progress {
    if (_duration.inMilliseconds <= 0) return 0.0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  void setHymns(List<Hymn> hymns) {
    _allHymns = hymns;
  }

  void setAudioLanguage(LyricsLanguage language) {
    _audioLanguage = language;
    notifyListeners();
  }

  void _initListeners() {
    _playerStateSub = _audioService.playerStateStream.listen((state) {
      _isPlaying = state.playing;

      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _position = Duration.zero;
        playNext();
      }

      _isLoading = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;

      notifyListeners();
    });

    _positionSub = _audioService.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _durationSub = _audioService.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });
  }

  Future<void> playHymn(
    Hymn hymn, {
    String? audioUrl,
    LyricsLanguage? language,
  }) async {
    if (language != null) _audioLanguage = language;

    final url = audioUrl ?? HymnAudio.urlFor(hymn, language: _audioLanguage);
    if (url == null) {
      _error = 'No audio for this hymn yet';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      _error = null;
      _isLoading = true;
      _currentHymn = hymn;
      notifyListeners();

      await _audioService.loadAudio(url);
      await _audioService.setSpeed(_currentSpeed);
      await _audioService.play();
    } catch (e) {
      _error = 'Failed to play audio. On web, check R2 CORS.';
      debugPrint('playHymn error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentHymn == null) return;
    if (_isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
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
    _position = Duration.zero;
    _duration = Duration.zero;
    _error = null;
    notifyListeners();
  }

  Future<void> playNext() async {
    final list = playableHymns;
    if (_currentHymn == null || list.isEmpty) return;

    final currentIndex =
        list.indexWhere((h) => h.number == _currentHymn!.number);
    final nextIndex =
        (currentIndex == -1) ? 0 : (currentIndex + 1) % list.length;
    await playHymn(list[nextIndex]);
  }

  Future<void> playPrevious() async {
    final list = playableHymns;
    if (_currentHymn == null || list.isEmpty) return;

    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    final currentIndex =
        list.indexWhere((h) => h.number == _currentHymn!.number);
    final prevIndex = (currentIndex <= 0) ? list.length - 1 : currentIndex - 1;
    await playHymn(list[prevIndex]);
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    super.dispose();
  }
}
