import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class NetworkManager {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // Using a StreamController for reactive updates in our new stack
  final StreamController<List<ConnectivityResult>> _statusController = StreamController<List<ConnectivityResult>>.broadcast();
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _statusController.stream;

  NetworkManager() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  /// Update the connection status based on changes in connectivity.
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    _statusController.add(result);
  }

  /// Check the terminal internet connection status.
  /// Returns 'true' if connected, 'false' otherwise.
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.none)) {
        return false;
      } else {
        return true;
      }
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Dispose the subscription
  @disposeMethod
  void dispose() {
    _connectivitySubscription.cancel();
    _statusController.close();
  }
}
