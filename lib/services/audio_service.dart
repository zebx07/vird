import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _ambientPlayer = AudioPlayer();
  static final AudioPlayer _effectPlayer = AudioPlayer();

  static bool _isAmbientPlaying = false;

  static Future<void> playAmbientSound(String soundType) async {
    if (_isAmbientPlaying) {
      await stopAmbientSound();
    }

    String audioPath;
    switch (soundType) {
      case 'masjid':
        audioPath = 'audio/masjid_ambient.mp3';
        break;
      case 'wind':
        audioPath = 'audio/wind_ambient.mp3';
        break;
      case 'night':
        audioPath = 'audio/night_ambient.mp3';
        break;
      case 'rain':
        audioPath = 'audio/rain_ambient.mp3';
        break;
      default:
        audioPath = 'audio/silence.mp3';
    }

    try {
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambientPlayer.setVolume(0.3);
      await _ambientPlayer.play(AssetSource(audioPath));
      _isAmbientPlaying = true;
    } catch (e) {
      print('Error playing ambient sound: $e');
    }
  }

  static Future<void> stopAmbientSound() async {
    try {
      await _ambientPlayer.stop();
      _isAmbientPlaying = false;
    } catch (e) {
      print('Error stopping ambient sound: $e');
    }
  }

  static Future<void> playCompletionSound() async {
    try {
      await _effectPlayer.play(AssetSource('audio/completion_chime.mp3'));
    } catch (e) {
      print('Error playing completion sound: $e');
    }
  }

  static Future<void> playTapSound() async {
    try {
      await _effectPlayer.setVolume(0.5);
      await _effectPlayer.play(AssetSource('audio/soft_tap.mp3'));
    } catch (e) {
      print('Error playing tap sound: $e');
    }
  }

  static bool get isAmbientPlaying => _isAmbientPlaying;

  static Future<void> setAmbientVolume(double volume) async {
    await _ambientPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  static Future<void> dispose() async {
    await _ambientPlayer.dispose();
    await _effectPlayer.dispose();
  }
}// TODO Implement this library.