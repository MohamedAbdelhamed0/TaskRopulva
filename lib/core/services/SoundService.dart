import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class SoundService {
  final AudioPlayer _player;
  bool _isInitialized = false;

  SoundService() : _player = AudioPlayer();

  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        // Configure audio session
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.music,
            usage: AndroidAudioUsage.game,
          ),
          androidAudioFocusGainType:
              AndroidAudioFocusGainType.gainTransientMayDuck,
        ));

        _isInitialized = true;
      } catch (e) {
        if (kDebugMode) {
          print('Error initializing audio session: $e');
        }
      }
    }
  }

  Future<void> playSound(String assetPath, {double speed = 1.0}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Stop any current playback
      await _player.stop();

      // Set the asset and play
      await _player.setAsset(assetPath);
      await _player.setSpeed(speed);
      await _player.play();
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound: $e');
      }
    }
  }

  Future<void> dispose() async {
    try {
      await _player.stop();
      await _player.dispose();
      _isInitialized = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing sound player: $e');
      }
    }
  }
}
