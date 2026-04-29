import 'dart:async';
import 'dart:math';

class ModbusRegisterUpdate {
  final int register;
  final int value;
  final DateTime timestamp;

  const ModbusRegisterUpdate({
    required this.register,
    required this.value,
    required this.timestamp,
  });
}

class ModbusWriteAck {
  final bool success;
  final String message;

  const ModbusWriteAck({required this.success, required this.message});

  static const ModbusWriteAck ok =
      ModbusWriteAck(success: true, message: 'Write acknowledged (ACK)');

  static ModbusWriteAck error(String reason) =>
      ModbusWriteAck(success: false, message: reason);
}

// Placeholder Modbus service — swap internals for real BLE/RTU comms later.
class ModbusService {
  final _random = Random();

  // Returns a random uint16 (0–65535) after a simulated round-trip delay.
  Future<int> readRegister(int register) async {
    await Future.delayed(const Duration(milliseconds: 180));
    return _random.nextInt(65536);
  }

  // Always acknowledges successfully for now.
  Future<ModbusWriteAck> writeRegister(int register, int value) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return ModbusWriteAck.ok;
  }

  // Emits random register/value pairs at ~800 ms intervals.
  Stream<ModbusRegisterUpdate> streamRegisters() async* {
    const registers = [
      100, 101, 102, 103, 110, 111, 115, 120, 125, 130, //
      131, 140, 141, 150, 155,
    ];
    while (true) {
      await Future.delayed(const Duration(milliseconds: 800));
      yield ModbusRegisterUpdate(
        register: registers[_random.nextInt(registers.length)],
        value: _random.nextInt(65536),
        timestamp: DateTime.now(),
      );
    }
  }
}
