import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projects/data/services/modbus_service.dart';

class ModbusEntry {
  final int register;
  final int value;
  final DateTime timestamp;

  ModbusEntry({
    required this.register,
    required this.value,
    required this.timestamp,
  });
}

enum ModbusOperation { none, reading, writing }

class ModbusState {
  final ModbusOperation operation;

  // Read result
  final int? lastReadRegister;
  final int? lastReadValue;

  // Write result
  final int? lastWriteRegister;
  final int? lastWriteValue;
  final bool? writeSuccess;
  final String? writeMessage;

  // Stream log
  final List<ModbusEntry> streamEntries;
  final bool isStreaming;

  final String? errorMessage;

  const ModbusState({
    this.operation = ModbusOperation.none,
    this.lastReadRegister,
    this.lastReadValue,
    this.lastWriteRegister,
    this.lastWriteValue,
    this.writeSuccess,
    this.writeMessage,
    this.streamEntries = const [],
    this.isStreaming = false,
    this.errorMessage,
  });

  ModbusState copyWith({
    ModbusOperation? operation,
    int? lastReadRegister,
    int? lastReadValue,
    int? lastWriteRegister,
    int? lastWriteValue,
    bool? writeSuccess,
    String? writeMessage,
    List<ModbusEntry>? streamEntries,
    bool? isStreaming,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ModbusState(
      operation: operation ?? this.operation,
      lastReadRegister: lastReadRegister ?? this.lastReadRegister,
      lastReadValue: lastReadValue ?? this.lastReadValue,
      lastWriteRegister: lastWriteRegister ?? this.lastWriteRegister,
      lastWriteValue: lastWriteValue ?? this.lastWriteValue,
      writeSuccess: writeSuccess ?? this.writeSuccess,
      writeMessage: writeMessage ?? this.writeMessage,
      streamEntries: streamEntries ?? this.streamEntries,
      isStreaming: isStreaming ?? this.isStreaming,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ModbusCubit extends Cubit<ModbusState> {
  final ModbusService _service;
  StreamSubscription<ModbusRegisterUpdate>? _streamSub;

  ModbusCubit(this._service) : super(const ModbusState());

  Future<void> readRegister(int register) async {
    emit(state.copyWith(
      operation: ModbusOperation.reading,
      clearError: true,
    ));
    try {
      final value = await _service.readRegister(register);
      emit(state.copyWith(
        operation: ModbusOperation.none,
        lastReadRegister: register,
        lastReadValue: value,
      ));
    } catch (e) {
      emit(state.copyWith(
        operation: ModbusOperation.none,
        errorMessage: 'Read failed: $e',
      ));
    }
  }

  Future<void> writeRegister(int register, int value) async {
    emit(state.copyWith(
      operation: ModbusOperation.writing,
      clearError: true,
    ));
    try {
      final ack = await _service.writeRegister(register, value);
      emit(state.copyWith(
        operation: ModbusOperation.none,
        lastWriteRegister: register,
        lastWriteValue: value,
        writeSuccess: ack.success,
        writeMessage: ack.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        operation: ModbusOperation.none,
        errorMessage: 'Write failed: $e',
      ));
    }
  }

  void startStream() {
    _streamSub?.cancel();
    emit(state.copyWith(isStreaming: true, streamEntries: [], clearError: true));
    _streamSub = _service.streamRegisters().listen((update) {
      final next = List<ModbusEntry>.from(state.streamEntries)
        ..add(ModbusEntry(
          register: update.register,
          value: update.value,
          timestamp: update.timestamp,
        ));
      if (next.length > 100) next.removeAt(0);
      emit(state.copyWith(streamEntries: next));
    });
  }

  void stopStream() {
    _streamSub?.cancel();
    _streamSub = null;
    emit(state.copyWith(isStreaming: false));
  }

  @override
  Future<void> close() {
    _streamSub?.cancel();
    return super.close();
  }
}
