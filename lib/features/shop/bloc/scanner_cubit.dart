import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projects/data/services/bluetooth_service.dart';

enum ScannerStatus { initial, loading, bluetoothDisabled, permissionDenied, success, failure }

class ScannerState {
  final ScannerStatus status;
  final List<ScanResult> devices;
  final String? errorMessage;
  final BluetoothAdapterState adapterState;

  ScannerState({
    this.status = ScannerStatus.initial,
    this.devices = const [],
    this.errorMessage,
    this.adapterState = BluetoothAdapterState.unknown,
  });

  ScannerState copyWith({
    ScannerStatus? status,
    List<ScanResult>? devices,
    String? errorMessage,
    BluetoothAdapterState? adapterState,
  }) {
    return ScannerState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      errorMessage: errorMessage ?? this.errorMessage,
      adapterState: adapterState ?? this.adapterState,
    );
  }
}

@injectable
class ScannerCubit extends Cubit<ScannerState> {
  final TBluetoothService _bluetoothService;
  StreamSubscription? _adapterStateSubscription;
  StreamSubscription? _scanResultsSubscription;

  ScannerCubit(this._bluetoothService) : super(ScannerState()) {
    // Monitor Bluetooth Adapter State (ON/OFF)
    // Renamed parameter to 'newAdapterState' to avoid shadowing the Cubit's 'state'
    _adapterStateSubscription = _bluetoothService.adapterState.listen((newAdapterState) {
      emit(state.copyWith(adapterState: newAdapterState));
      
      // If bluetooth is turned off while we were doing something, update status
      if (newAdapterState != BluetoothAdapterState.on && newAdapterState != BluetoothAdapterState.unknown) {
        emit(state.copyWith(status: ScannerStatus.bluetoothDisabled));
      }
    });

    // Monitor Scan Results
    _scanResultsSubscription = _bluetoothService.scanResults.listen((results) {
      emit(state.copyWith(devices: results, status: ScannerStatus.success));
    });
  }

  /// Entry point to start the scanning process with all necessary checks
  Future<void> initScan() async {
    // 1. Request Permissions
    final permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      emit(state.copyWith(status: ScannerStatus.permissionDenied));
      return;
    }

    // 2. Check if Bluetooth is ON
    if (state.adapterState != BluetoothAdapterState.on) {
      // Prompt user to turn on Bluetooth if it's off
      if (state.adapterState == BluetoothAdapterState.off) {
        try {
          // On Android, we can try to turn it on automatically or show the system dialog
          await FlutterBluePlus.turnOn();
        } catch (e) {
          emit(state.copyWith(status: ScannerStatus.bluetoothDisabled));
          return;
        }
      } else {
        emit(state.copyWith(status: ScannerStatus.bluetoothDisabled));
        return;
      }
    }

    // 3. Start Scanning
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
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  @override
  Future<void> close() {
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _bluetoothService.stopScan();
    return super.close();
  }
}
