// lib/core/providers/location_service_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationServiceProvider extends ChangeNotifier {
  bool _isGpsOn = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isGpsOn => _isGpsOn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  StreamSubscription<ServiceStatus>? _subscription;

  LocationServiceProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isGpsOn = await Geolocator.isLocationServiceEnabled();
      notifyListeners();

      _subscription = Geolocator.getServiceStatusStream().listen((status) {
        final bool newStatus = status == ServiceStatus.enabled;
        if (_isGpsOn != newStatus) {
          _isGpsOn = newStatus;
          notifyListeners();
          
          // Print status change for debugging
          print("📡 GPS Status Changed: ${_isGpsOn ? 'ON' : 'OFF'}");
        }
      });
    } catch (e) {
      _errorMessage = "Failed to check GPS status: $e";
      print("❌ GPS Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Refresh GPS Status manually
  Future<void> refreshGpsStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isGpsOn = await Geolocator.isLocationServiceEnabled();
      notifyListeners();
      print("📡 GPS Status Refreshed: ${_isGpsOn ? 'ON' : 'OFF'}");
    } catch (e) {
      _errorMessage = "Failed to refresh GPS status: $e";
      print("❌ GPS Refresh Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Open GPS Settings
  Future<void> openGpsSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      print("❌ Error opening GPS settings: $e");
    }
  }

  // ✅ Check if GPS is enabled
  Future<bool> checkGpsStatus() async {
    try {
      _isGpsOn = await Geolocator.isLocationServiceEnabled();
      notifyListeners();
      return _isGpsOn;
    } catch (e) {
      print("❌ Error checking GPS: $e");
      return false;
    }
  }

  // ✅ Request Location Permission
  Future<LocationPermission> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Permission permanently denied, open app settings
        await Geolocator.openAppSettings();
      }
      
      return permission;
    } catch (e) {
      print("❌ Permission Error: $e");
      return LocationPermission.denied;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}