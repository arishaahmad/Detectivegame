// lib/services/audio_service.dart

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  Timer? _fadeTimer;

  Future<void> playMusic(String filePath) async {
    await _musicPlayer.setVolume(1.0);
    await _musicPlayer.play(AssetSource(filePath));
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playSfx(String filePath) async {
    await _sfxPlayer.play(AssetSource(filePath));
  }

  // NEW: Plays a sound multiple times with a short delay
  Future<void> playRapidSfx(String filePath, {int count = 4, Duration delay = const Duration(milliseconds: 300)}) async {
    for (int i = 0; i < count; i++) {
      await _sfxPlayer.play(AssetSource(filePath));
      await Future.delayed(delay);
    }
  }

  Future<void> fadeOutMusic({Duration duration = const Duration(seconds: 2)}) async {
    double currentVolume = 1.0;
    final double step = currentVolume / (duration.inMilliseconds / 100);

    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      currentVolume -= step;
      if (currentVolume <= 0) {
        await _musicPlayer.stop();
        await _musicPlayer.setVolume(1.0);
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