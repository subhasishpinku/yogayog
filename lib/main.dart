import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/providers/location_service_provider.dart';
import 'package:yogayog/core/providers/network_provider.dart';
import 'package:yogayog/loginscreen/provider/auth_provider.dart';
import 'package:yogayog/loginscreen/provider/login_save_provider.dart';
import 'package:yogayog/profile/provider/profile_provider.dart';
import 'package:yogayog/gps_offScreen.dart';
import 'package:yogayog/homescreen/home_provider.dart';
import 'package:yogayog/no_internet.dart';
import 'package:yogayog/otpscreen/provider/otp_provider.dart';
import 'package:yogayog/splash_screen.dart';
import 'package:yogayog/utils/BackgroundTask/background_task.dart';
import 'package:yogayog/utils/sound_service.dart';
import 'package:yogayog/viewledger/provider/viewledger_provider.dart';
import 'package:yogayog/history/provider/history_provider.dart';
import 'package:yogayog/bikescreen/provider/bikescreen_provider.dart';
import 'package:yogayog/CutOffTime/provider/cut_of_time_provider.dart';
import 'package:yogayog/nearesthub/provider/nearesthub_provider.dart';
import 'package:yogayog/branchaddresses/provider/branchaddresses_provider.dart';
import 'package:yogayog/contactpersons/provider/contactpersons_provider.dart';
import 'package:yogayog/pincodecheck/provider/pincodecheck_provider.dart';
import 'package:yogayog/termsprivacy/provider/term_privacy_provider.dart';
import 'package:yogayog/savedaddresses/provider/savedaddresses_provider.dart';
import 'package:yogayog/adddropadress/provider/add_drop_address_provider.dart';
import 'package:yogayog/Payment/provider/payment_provider.dart';
import 'package:yogayog/truckscreen/provider/truck_local_provider.dart';
import 'package:yogayog/nationaldetails/provider/national_provider.dart';
import 'package:yogayog/internationaldetails/provider/international_details_provider.dart';
import 'package:yogayog/Payment/provider/payment_national_provider.dart';
import 'package:yogayog/Payment/provider/payment_national_import_provider.dart';
import 'package:yogayog/paperworkrequired/provider/paperwork_required_provider.dart';
import 'package:yogayog/internationalimport/provider/international_import_provider.dart';
import 'package:yogayog/Invoices/provider/invoices_provider.dart';
import 'package:yogayog/Payment/provider/payment_national_export_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ApiClient.loadToken();

  await Permission.notification.request();

  final FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await notification.initialize(settings: settings);

  // await initializeService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
        ChangeNotifierProvider(create: (_) => LocationServiceProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LoginSaveProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => OtpProvider()),
        ChangeNotifierProvider(create: (_) => ViewledgerProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => BikescreenProvider()),
        ChangeNotifierProvider(create: (_) => CutOffTimeProvider()),
        ChangeNotifierProvider(create: (_) => NearestHubProvider()),
        ChangeNotifierProvider(create: (_) => BranchAddressesProvider()),
        ChangeNotifierProvider(create: (_) => ContactPersonsProvider()),
        ChangeNotifierProvider(create: (_) => PincodeCheckProvider()),
        ChangeNotifierProvider(create: (_) => TermPrivacyProvider()),
        ChangeNotifierProvider(create: (_) => SavedAddressesProvider()),
        ChangeNotifierProvider(create: (_) => AddDropAddressProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => TruckLocalProvider()),
        ChangeNotifierProvider(create: (_) => NationalProvider()),
        ChangeNotifierProvider(create: (_) => InternationalDetailsProvider()),
        ChangeNotifierProvider(create: (_) => PaymentNationalProvider()),
        ChangeNotifierProvider(create: (_) => PaymentNationalExportProvider()),
        ChangeNotifierProvider(create: (_) => PaymentNationalImportProvider()),
        ChangeNotifierProvider(create: (_) => InternationalImportProvider()),
        ChangeNotifierProvider(create: (_) => InvoicesProvider()),
        ChangeNotifierProvider(create: (_) => PaperworkRequiredProvider()),
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
