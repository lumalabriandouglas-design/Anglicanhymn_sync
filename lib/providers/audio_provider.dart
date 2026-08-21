import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../core/services/audio_player_service.dart';
import '../models/hymn.dart';

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

  StreamSubscription? _playerStateSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;

  AudioProvider(this._audioService) {
    _initListeners();
  }

  // ====================== GETTERS ======================
  AudioPlayerService get audioService => _audioService;
  Hymn? get currentHymn => _currentHymn;
  bool get isPlaying => _isPlaying;
  double get currentSpeed => _currentSpeed;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get progress {
    if (_duration.inMilliseconds <= 0) return 0.0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
  }

  void setHymns(List<Hymn> hymns) {
    _allHymns = hymns;
  }

  // ====================== LISTENERS ======================
  void _initListeners() {
    _playerStateSub = _audioService.playerStateStream.listen((state) {
      _isPlaying = state.playing;

      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _position = Duration.zero;
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

  // ====================== CORE PLAYBACK ======================
  Future<void> playHymn(Hymn hymn, {String? audioUrl}) async {
    try {
      _error = null;
      _isLoading = true;
      _currentHymn = hymn;
      notifyListeners();

      final url = audioUrl ?? _getAudioUrl(hymn);

      await _audioService.loadAudio(url);
      await _audioService.setSpeed(_currentSpeed);
      await _audioService.play();
    } catch (e) {
      _error = 'Failed to play audio';
      debugPrint('playHymn error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getAudioUrl(Hymn hymn) {
    final title = hymn.title.toLowerCase();

    // Nina omukwano gwange / What A Friend We Have In Jesus
    if (title.contains('nina omukwano') ||
        title.contains('omukwano gwange') ||
        title.contains('friend') ||
        title.contains('what a friend')) {
      return 'https://pub-22426af78c4e41d989b240b35aa21225.r2.dev/What%20A%20Friend%20We%20Have%20In%20Jesus%20Lyric%20Video%20Lydia%20Walker%20Acoustic%20Hymns%20with%20Lyrics-128.m4a';
    }

    // Fallback test track
    return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
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

  // ====================== NEXT / PREVIOUS ======================
  Future<void> playNext() async {
    if (_currentHymn == null || _allHymns.isEmpty) return;

    final currentIndex =
        _allHymns.indexWhere((h) => h.number == _currentHymn!.number);

    if (currentIndex == -1 || currentIndex >= _allHymns.length - 1) {
      await playHymn(_allHymns.first);
    } else {
      await playHymn(_allHymns[currentIndex + 1]);
    }
  }

  Future<void> playPrevious() async {
    if (_currentHymn == null || _allHymns.isEmpty) return;

    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    final currentIndex =
        _allHymns.indexWhere((h) => h.number == _currentHymn!.number);

    if (currentIndex <= 0) {
      await playHymn(_allHymns.last);
    } else {
      await playHymn(_allHymns[currentIndex - 1]);
    }
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    super.dispose();
  }
}