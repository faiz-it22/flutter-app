import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projects/data/services/bluetooth_service.dart';

enum ScannerStatus {
  initial,
  loading,
  bluetoothDisabled,
  permissionDenied,
  success,
  failure,
  connecting,
  connected,
  disconnecting,
}

class ScannerState {
  final ScannerStatus status;
  final List<ScanResult> devices;
  final String? errorMessage;
  final BluetoothAdapterState adapterState;
  final BluetoothDevice? connectedDevice;
  final List<BluetoothService> services;
  final Map<String, List<int>> characteristicValues;
  final Set<String> loadingCharacteristics;
  final Map<String, String> characteristicErrors;
  final String? connectingDeviceId;

  ScannerState({
    this.status = ScannerStatus.initial,
    this.devices = const [],
    this.errorMessage,
    this.adapterState = BluetoothAdapterState.unknown,
    this.connectedDevice,
    this.services = const [],
    this.characteristicValues = const {},
    this.loadingCharacteristics = const {},
    this.characteristicErrors = const {},
    this.connectingDeviceId,
  });

  bool get isConnected => status == ScannerStatus.connected && connectedDevice != null;

  ScannerState copyWith({
    ScannerStatus? status,
    List<ScanResult>? devices,
    String? errorMessage,
    BluetoothAdapterState? adapterState,
    BluetoothDevice? connectedDevice,
    bool clearConnectedDevice = false,
    List<BluetoothService>? services,
    Map<String, List<int>>? characteristicValues,
    Set<String>? loadingCharacteristics,
    Map<String, String>? characteristicErrors,
    String? connectingDeviceId,
    bool clearConnectingDevice = false,
  }) {
    return ScannerState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      errorMessage: errorMessage ?? this.errorMessage,
      adapterState: adapterState ?? this.adapterState,
      connectedDevice: clearConnectedDevice ? null : (connectedDevice ?? this.connectedDevice),
      services: services ?? this.services,
      characteristicValues: characteristicValues ?? this.characteristicValues,
      loadingCharacteristics: loadingCharacteristics ?? this.loadingCharacteristics,
      characteristicErrors: characteristicErrors ?? this.characteristicErrors,
      connectingDeviceId: clearConnectingDevice ? null : (connectingDeviceId ?? this.connectingDeviceId),
    );
  }
}

@lazySingleton
class ScannerCubit extends Cubit<ScannerState> {
  final TBluetoothService _bluetoothService;
  StreamSubscription? _adapterStateSubscription;
  StreamSubscription? _scanResultsSubscription;

  ScannerCubit(this._bluetoothService) : super(ScannerState()) {
    _adapterStateSubscription = _bluetoothService.adapterState.listen((newAdapterState) {
      emit(state.copyWith(adapterState: newAdapterState));
      if (newAdapterState != BluetoothAdapterState.on &&
          newAdapterState != BluetoothAdapterState.unknown) {
        emit(state.copyWith(
          status: ScannerStatus.bluetoothDisabled,
          clearConnectedDevice: true,
          services: [],
        ));
      }
    });

    _scanResultsSubscription = _bluetoothService.scanResults.listen((results) {
      // Don't overwrite connected state with scan results
      if (state.status != ScannerStatus.connected &&
          state.status != ScannerStatus.connecting) {
        emit(state.copyWith(devices: results, status: ScannerStatus.success));
      } else {
        emit(state.copyWith(devices: results));
      }
    });
  }

  Future<void> initScan() async {
    final permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      emit(state.copyWith(status: ScannerStatus.permissionDenied));
      return;
    }

    if (state.adapterState != BluetoothAdapterState.on) {
      if (state.adapterState == BluetoothAdapterState.off) {
        try {
          await FlutterBluePlus.turnOn();
        } catch (_) {
          emit(state.copyWith(status: ScannerStatus.bluetoothDisabled));
          return;
        }
      } else {
        emit(state.copyWith(status: ScannerStatus.bluetoothDisabled));
        return;
      }
    }

    await startScanning();
  }

  Future<void> startScanning() async {
    emit(state.copyWith(status: ScannerStatus.loading));
    await _bluetoothService.startScan();
  }

  Future<void> stopScanning() async {
    await _bluetoothService.stopScan();
    emit(state.copyWith(status: ScannerStatus.initial));
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }

  Future<void> connect(BluetoothDevice device) async {
    emit(state.copyWith(
      status: ScannerStatus.connecting,
      connectingDeviceId: device.remoteId.str,
    ));
    try {
      await _bluetoothService.stopScan();
      final services = await _bluetoothService.connect(device);
      emit(state.copyWith(
        status: ScannerStatus.connected,
        connectedDevice: device,
        services: services,
        characteristicValues: {},
        clearConnectingDevice: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ScannerStatus.failure,
        errorMessage: 'Failed to connect: $e',
        clearConnectingDevice: true,
      ));
    }
  }

  Future<void> disconnect() async {
    final device = state.connectedDevice;
    if (device == null) return;
    emit(state.copyWith(status: ScannerStatus.disconnecting));
    try {
      await _bluetoothService.disconnect(device);
    } catch (_) {}
    emit(state.copyWith(
      status: ScannerStatus.success,
      clearConnectedDevice: true,
      services: [],
      characteristicValues: {},
    ));
  }

  Future<void> readCharacteristic(BluetoothCharacteristic characteristic) async {
    final key = characteristic.characteristicUuid.toString();
    final clearedErrors = Map<String, String>.from(state.characteristicErrors)..remove(key);
    emit(state.copyWith(
      loadingCharacteristics: {...state.loadingCharacteristics, key},
      characteristicErrors: clearedErrors,
    ));

    Object? lastError;
    for (int attempt = 0; attempt < 3; attempt++) {
      if (attempt > 0) await Future.delayed(const Duration(milliseconds: 300));
      try {
        final value = await _bluetoothService.readCharacteristic(characteristic);
        final updated = Map<String, List<int>>.from(state.characteristicValues);
        updated[key] = value;
        final loading = Set<String>.from(state.loadingCharacteristics)..remove(key);
        emit(state.copyWith(characteristicValues: updated, loadingCharacteristics: loading));
        return;
      } catch (e) {
        lastError = e;
      }
    }

    final loading = Set<String>.from(state.loadingCharacteristics)..remove(key);
    final errors = Map<String, String>.from(state.characteristicErrors);
    errors[key] = _friendlyReadError(lastError.toString());
    emit(state.copyWith(loadingCharacteristics: loading, characteristicErrors: errors));
  }

  String _friendlyReadError(String raw) {
    if (raw.contains('returned false')) return 'Device refused the read (try reconnecting)';
    if (raw.contains('133') || raw.contains('GATT')) return 'GATT error — try reconnecting';
    if (raw.contains('not connected')) return 'Device disconnected';
    return 'Read failed';
  }

  @override
  Future<void> close() {
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _bluetoothService.stopScan();
    return super.close();
  }
}
