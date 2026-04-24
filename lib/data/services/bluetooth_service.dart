import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:injectable/injectable.dart';
import 'package:projects/utils/logging/logger.dart';

@lazySingleton
class TBluetoothService {
  // Streams for UI to listen to
  Stream<List<fbp.ScanResult>> get scanResults => fbp.FlutterBluePlus.onScanResults;
  Stream<bool> get isScanning => fbp.FlutterBluePlus.isScanning;
  Stream<fbp.BluetoothAdapterState> get adapterState => fbp.FlutterBluePlus.adapterState;

  /// Start scanning for devices
  Future<void> startScan({List<fbp.Guid> withServices = const [], Duration? timeout}) async {
    try {
      // Check if bluetooth is on
      if (await fbp.FlutterBluePlus.adapterState.first != fbp.BluetoothAdapterState.on) {
        TLoggerHelper.error("Bluetooth is turned off");
        return;
      }

      await fbp.FlutterBluePlus.startScan(
        withServices: withServices,
        timeout: timeout ?? const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      TLoggerHelper.error("Error starting scan: $e");
    }
  }

  /// Stop scanning
  Future<void> stopScan() async {
    await fbp.FlutterBluePlus.stopScan();
  }

  /// Connect to a device and return discovered services
  Future<List<fbp.BluetoothService>> connect(fbp.BluetoothDevice device, {bool autoConnect = false}) async {
    try {
      await device.connect(autoConnect: autoConnect);
      // Give the Android GATT stack a moment to settle before discovering
      // services — skipping this causes readCharacteristic() to return false
      // on the first read attempt for many devices.
      await Future.delayed(const Duration(milliseconds: 500));
      final services = await device.discoverServices();
      TLoggerHelper.info("Connected to ${device.platformName}, found ${services.length} services");
      return services;
    } catch (e) {
      TLoggerHelper.error("Error connecting to device: $e");
      rethrow;
    }
  }

  /// Disconnect from a device
  Future<void> disconnect(fbp.BluetoothDevice device) async {
    await device.disconnect();
    TLoggerHelper.info("Disconnected from ${device.platformName}");
  }

  /// Discover services for a connected device
  Future<List<fbp.BluetoothService>> discoverServices(fbp.BluetoothDevice device) async {
    try {
      return await device.discoverServices();
    } catch (e) {
      TLoggerHelper.error("Error discovering services: $e");
      rethrow;
    }
  }

  /// Write data to a characteristic
  Future<void> writeCharacteristic(
    fbp.BluetoothCharacteristic characteristic,
    List<int> value, {
    bool withoutResponse = false,
  }) async {
    try {
      await characteristic.write(value, withoutResponse: withoutResponse);
    } catch (e) {
      TLoggerHelper.error("Error writing characteristic: $e");
      rethrow;
    }
  }

  /// Read data from a characteristic
  Future<List<int>> readCharacteristic(fbp.BluetoothCharacteristic characteristic) async {
    try {
      print("Reading from characteristic: ${characteristic.uuid}");
      return await characteristic.read();
    } catch (e) {
      TLoggerHelper.error("Error reading characteristic: $e");
      rethrow;
    }
  }

  /// Subscribe to notifications
  Future<bool> setNotifications(fbp.BluetoothCharacteristic characteristic, bool enable) async {
    try {
      return await characteristic.setNotifyValue(enable);
    } catch (e) {
      TLoggerHelper.error("Error setting notifications: $e");
      return false;
    }
  }
}
