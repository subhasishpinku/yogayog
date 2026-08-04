// lib/core/utils/sound_service.dart

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playAlertSound() async {
    try {
      // Play from assets
      await _player.play(AssetSource('notification_sound.mp3'));

      // Alternative: Play from network URL
      // await _player.play(UrlSource('https://example.com/sound.mp3'));

      // Alternative: Play from file
      // await _player.play(DeviceFileSource('/path/to/sound.mp3'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  static Future<void> stopSound() async {
    await _player.stop();
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}
