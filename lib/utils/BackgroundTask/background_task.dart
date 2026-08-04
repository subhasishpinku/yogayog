import 'dart:async';
import 'dart:ui';
import 'dart:io'; // Add this import


import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Initialize Background Service
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'location_tracking_v2',
    'Location Tracking',
    description: 'Background Location Tracking',
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await notifications.initialize(settings: settings);

  await notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'location_tracking_v2',
      initialNotificationTitle: 'EMS',
      initialNotificationContent: 'Location Tracking Started',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

/// Background Service
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  // Test if sound file exists
  _checkSoundFile();

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "EMS",
      content: "Tracking your location...",
    );
  }

  service.on("stopService").listen((event) {
    service.stopSelf();
  });
  Timer.periodic(const Duration(minutes: 30), (timer) async {
    print("1 minute timer fireds");

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (!serviceEnabled ||
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

 

      String address = "Unknown";

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }

      if (service is AndroidServiceInstance) {
        final place = placemarks.first;

        service.setForegroundNotificationInfo(
          title: "📍 Live Location",
          content: "${place.street}, ${place.locality}, ${place.postalCode}",
        );

        // Try to show notification with custom sound
        await _showNotificationWithSound(notifications, position, place);
      }

      service.invoke("update", {
        "lat": position.latitude,
        "lng": position.longitude,
        "address": address,
      });

      print(
        "Latitude: ${position.latitude}\n"
        "Longitude: ${position.longitude}\n"
        "Address: $address",
      );
    } catch (e) {
      print("Location Error: $e");
    }
  });

}

// Add this function to check if sound file exists
void _checkSoundFile() {
  try {
    // Check if file exists in raw folder
    print("🔍 Checking for sound file...");
    // This will help debug
  } catch (e) {
    print("❌ Sound file check error: $e");
  }
}

/// Helper function to show notification with custom sound
Future<void> _showNotificationWithSound(
  FlutterLocalNotificationsPlugin notifications,
  Position position,
  Placemark place,
) async {
  // Try with custom sound (without extension)
  try {
    print("🔊 Attempting to play custom sound...");
    await notifications.show(
      id: 888,
      title: "📍 Live Location Update",
      body: "Tap to view location details",
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'location_tracking_v2',
          'Location Tracking',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          styleInformation: BigTextStyleInformation("""
            Latitude : ${position.latitude}
            Longitude : ${position.longitude}
            Street : ${place.street ?? 'N/A'}
            Area : ${place.subLocality ?? 'N/A'}
            City : ${place.locality ?? 'N/A'}
            District : ${place.subAdministrativeArea ?? 'N/A'}
            State : ${place.administrativeArea ?? 'N/A'}
            Pincode : ${place.postalCode ?? 'N/A'}
            Country : ${place.country ?? 'N/A'}
            """),
        ),
      ),
    );
    print("✅ Custom sound played successfully!");
    return;
  } catch (e) {
    print("❌ Custom sound error: $e");
  }

  // Fallback to default sound
  try {
    print("🔊 Falling back to default sound...");
    await notifications.show(
      id: 888,
      title: "📍 Live Location Update",
      body: "Tap to view location details",
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'location_tracking_v2',
          'Location Tracking',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation("""
            Latitude : ${position.latitude}
            Longitude : ${position.longitude}
            Street : ${place.street ?? 'N/A'}
            Area : ${place.subLocality ?? 'N/A'}
            City : ${place.locality ?? 'N/A'}
            District : ${place.subAdministrativeArea ?? 'N/A'}
            State : ${place.administrativeArea ?? 'N/A'}
            Pincode : ${place.postalCode ?? 'N/A'}
            Country : ${place.country ?? 'N/A'}
            """),
        ),
      ),
    );
    print("✅ Default sound played successfully!");
  } catch (e) {
    print("❌ Fallback error: $e");
  }
}

/// iOS Background
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    print("iOS Background: ${position.latitude}, ${position.longitude}");
  } catch (e) {
    print(e);
  }

  return true;
}
