import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationProvider extends ChangeNotifier {
  bool _isTracking = false;
  String _address = "Fetching location...";
  double? _lat;
  double? _lng;

  bool get isTracking => _isTracking;
  String get address => _address;
  double? get lat => _lat;
  double? get lng => _lng;

  Future<bool> _requestPermission() async {
    // HomeScreen only needs the user's current location while the app is
    // open. Asking for `locationAlways` here sends users to App Info/settings
    // on newer Android versions, so request foreground location only.
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      _address = status.isPermanentlyDenied
          ? 'Location permission is disabled'
          : 'Location permission not granted';
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<void> startTracking() async {
    bool granted = await _requestPermission();
    if (!granted) {
      print("Location permission not granted");
      return;
    }

    final service = FlutterBackgroundService();
    if (!await service.isRunning()) {
      await service.startService();
    }

    // 🔹 Listen to updates from service
    service.on("update").listen((event) {
      if (event != null) {
        _lat = event["lat"];
        _lng = event["lng"];
        _address = event["address"] ?? "Unknown location";
        print(
          "Foreground _address: "
          "Lat: ${_lat}, "
          "Lng: ${_lng}, "
          "Address: $address",
        );
        notifyListeners();
      }
    });

    _isTracking = true;
    notifyListeners();
  }

  Future<void> stopTracking() async {
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke("stopService");
    }
    _isTracking = false;
    notifyListeners();
  }
}
