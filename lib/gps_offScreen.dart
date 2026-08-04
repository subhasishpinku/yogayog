// lib/view/SplashScreen/gps_offScreen.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/core/providers/location_service_provider.dart';

class GpsOffScreen extends StatefulWidget {
  const GpsOffScreen({super.key});

  @override
  State<GpsOffScreen> createState() => _GpsOffScreenState();
}

class _GpsOffScreenState extends State<GpsOffScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _playAlertSound();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playAlertSound() async {
    if (_isPlaying) return;
    
    try {
      _isPlaying = true;
      await _player.play(AssetSource('assets/notification_sound.mp3'));
      await _player.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  Future<void> _stopSound() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      print("Error stopping sound: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocationServiceProvider>();

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // GPS Off Icon
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_off,
                    color: Colors.red.shade700,
                    size: 70,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "GPS is Turned Off",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "This application requires Location Service to be enabled.\n\nPlease turn on GPS to continue.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // Turn On GPS Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            await provider.openGpsSettings();
                            _playAlertSound();
                          },
                    icon: const Icon(Icons.location_on),
                    label: Text(
                      provider.isLoading ? "Checking..." : "Turn On GPS",
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Refresh Button
                TextButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          await provider.refreshGpsStatus();
                          if (provider.isGpsOn) {
                            _stopSound();
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          } else {
                            _playAlertSound();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("GPS is still turned off"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  icon: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    provider.isLoading ? "Checking..." : "Refresh",
                  ),
                ),

                const SizedBox(height: 20),

                // Sound Indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.volume_up,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Alert sound playing",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // GPS Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "GPS: ${provider.isGpsOn ? 'ON' : 'OFF'}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}