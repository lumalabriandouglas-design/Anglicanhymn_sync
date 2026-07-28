import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Future<void> init() async {
    // Basic service initialization setup
  }

  /// Loads audio from either a web URL or local asset bundle
  Future<void> loadAudio(String urlOrAsset) async {
    try {
      if (urlOrAsset.startsWith('http')) {
        await _player.setUrl(urlOrAsset);
      } else {
        await _player.setAsset(urlOrAsset);
      }
    } catch (e) {
      // Audio load failure safety wrapper
    }
  }

  Future<void> play() async => await _player.play();
  Future<void> pause() async => await _player.pause();
  Future<void> stop() async => await _player.stop();
  Future<void> seek(Duration position) async => await _player.seek(position);

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  void dispose() {
    _player.dispose();
  }
}