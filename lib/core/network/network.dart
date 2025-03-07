import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:connectivity_plus/connectivity_plus.dart'; // For web support
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  late final Future<bool> Function() _checkConnection;

  NetworkInfoImpl() {
    if (kIsWeb) {
      // Use connectivity_plus for web
      final connectivity = Connectivity();
      _checkConnection = () async {
        final result = await connectivity.checkConnectivity();
        return result != ConnectivityResult.none;
      };
    } else {
      // Use InternetConnectionChecker for mobile and other platforms
      final connectionChecker = InternetConnectionChecker();
      _checkConnection = () => connectionChecker.hasConnection;
    }
  }

  @override
  Future<bool> get isConnected => _checkConnection();
}
