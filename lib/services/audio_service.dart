// lib/services/audio_service.dart

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  Timer? _fadeTimer;

  Future<void> playMusic(String filePath) async {
    await _musicPlayer.setVolume(1.0); // Ensure volume is at max
    await _musicPlayer.play(AssetSource(filePath));
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playSfx(String filePath) async {
    await _sfxPlayer.play(AssetSource(filePath));
    _sfxPlayer.setReleaseMode(ReleaseMode.release);
  }

  void stopMusic() {
    _musicPlayer.stop();
  }

  // NEW: Fades music out over a given duration
  Future<void> fadeOutMusic({Duration duration = const Duration(seconds: 2)}) async {
    double currentVolume = 1.0;
    // Calculate how much to decrease the volume in each step
    final double step = currentVolume / (duration.inMilliseconds / 100);

    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      currentVolume -= step;
      if (currentVolume <= 0) {
        await _musicPlayer.stop();
        await _musicPlayer.setVolume(1.0); // Reset volume for next time
        timer.cancel();
      } else {
        await _musicPlayer.setVolume(currentVolume);
      }
    });
  }

  void dispose() {
    _fadeTimer?.cancel();
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
