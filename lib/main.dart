import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/core/providers/locationProvider.dart';
import 'package:yogayog/core/providers/location_service_provider.dart';
import 'package:yogayog/core/providers/network_provider.dart';
import 'package:yogayog/gps_offScreen.dart';
import 'package:yogayog/no_internet.dart';
import 'package:yogayog/splash_screen.dart';
import 'package:yogayog/utils/BackgroundTask/background_task.dart';
import 'package:yogayog/utils/sound_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.notification.request();

  final FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await notification.initialize(settings: settings);

  await initializeService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
        ChangeNotifierProvider(create: (_) => LocationServiceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Yogayog",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
      builder: (context, child) {
        final network = context.watch<NetworkProvider>();
        final gps = context.watch<LocationServiceProvider>();

        // Play sound when GPS is off
        // if (!gps.isGpsOn) {
        //   SoundService.playAlertSound();
        // }

        // //  Play sound when Internet is off
        // if (!network.hasInternet) {
        //   SoundService.playAlertSound();
        // }

        if (!network.hasInternet) {
          return const NoInternetScreen();
        }

        if (!gps.isGpsOn) {
          return const GpsOffScreen();
        }

        return child!;
      },
    );
  }
}
