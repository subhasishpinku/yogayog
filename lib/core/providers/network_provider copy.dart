// lib/core/providers/network_provider.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkProvider extends ChangeNotifier {
  bool _hasInternet = true;
  bool _isLoading = false;

  bool get hasInternet => _hasInternet;
  bool get isLoading => _isLoading;

  StreamSubscription? _subscription;

  NetworkProvider() {
    startListening();
  }

  Future<void> startListening() async {
    _isLoading = true;
    notifyListeners();

    try {
      _hasInternet = await InternetConnection().hasInternetAccess;
      notifyListeners();

      _subscription = Connectivity().onConnectivityChanged.listen((event) async {
        _hasInternet = await InternetConnection().hasInternetAccess;
        notifyListeners();
        print("📡 Internet Status Changed: ${_hasInternet ? 'ON' : 'OFF'}");
      });
    } catch (e) {
      print("❌ Internet Check Error: $e");
      _hasInternet = false;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Added checkInternet method
  Future<void> checkInternet() async {
    _isLoading = true;
    notifyListeners();

    try {
      _hasInternet = await InternetConnection().hasInternetAccess;
      notifyListeners();
      print("📡 Internet Status Checked: ${_hasInternet ? 'ON' : 'OFF'}");
    } catch (e) {
      print("❌ Internet Check Error: $e");
      _hasInternet = false;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Refresh internet status (alias for checkInternet)
  Future<void> refreshInternet() async {
    await checkInternet();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}