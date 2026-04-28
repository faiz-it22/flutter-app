# Project Overview: Fortes Energy Mobile Application (Enterprise Stack)

The **Fortes Energy Mobile App** serves as the central control system for the **Heat Interface Unit (HIU)**. Its primary purpose is to facilitate commissioning, service, and maintenance activities via **Bluetooth Low Energy (BLE)**.

---

## 🏗 Architecture & Structure

The project follows a **Feature-First / Clean Architecture** pattern.

```
lib/
├── data/
│   ├── repositories/        # Abstracted data access (e.g. AuthenticationRepository)
│   └── services/            # Low-level service wrappers (TBluetoothService)
├── features/
│   ├── authentication/      # Login, onboarding — BLoC + Retrofit
│   └── shop/
│       ├── bloc/            # ScannerCubit — BLE state machine
│       └── screens/home/    # Dashboard + ScannerBottomSheet
├── utils/                   # Theming, constants, logging, validation
├── common/                  # Reusable widgets (connectivity banner, form helpers)
└── init/                    # GetIt + Injectable DI setup
```

---

## 📶 Communication Protocols & Scope

### In Scope
- **BLE**: Local device interaction via `flutter_blue_plus`.
- **Modbus over BLE**: The HIU exposes Modbus registers through a custom GATT characteristic. Three operations are required:
  - **Read** — request the value of one or more Modbus registers.
  - **Write** — set the value of one or more Modbus registers.
  - **Stream** — subscribe to register change notifications via BLE `notify`/`indicate`.
- **FOTA**: Firmware updates via Bluetooth (future).

### Out of Scope
Internet-based device control — all communication is local BLE only.

---

## 🛠 Tech Stack

| Layer | Library |
|---|---|
| State management | `flutter_bloc` — Cubit for simple flows, Bloc for complex |
| Navigation | `go_router` |
| Networking (auth API) | `dio` + `retrofit` |
| Dependency injection | `get_it` + `injectable` |
| Local persistence | `hive` (device records, user session) |
| Secure storage | `flutter_secure_storage` (auth tokens) |
| Serialization | `json_serializable` (+ `freezed` for immutable models) |
| BLE | `flutter_blue_plus ^1.31.11` |
| UI | Material 3, `iconsax_flutter`, Poppins font |
| Monitoring | `sentry_flutter` |

---

## 📡 BLE Layer — Current Implementation

### `TBluetoothService` (`lib/data/services/bluetooth_service.dart`)
Thin singleton wrapper around `flutter_blue_plus`. All methods rethrow on failure so the cubit can handle errors.

| Method | Description |
|---|---|
| `startScan()` | Scan with 15s timeout, fine location on Android |
| `stopScan()` | Stop active scan |
| `connect(device)` | Connect + 500 ms GATT settle delay + `discoverServices()` |
| `disconnect(device)` | Disconnect and log |
| `readCharacteristic(c)` | Read raw bytes from a characteristic |
| `writeCharacteristic(c, value)` | Write bytes; supports `withoutResponse` |
| `setNotifications(c, enable)` | Enable/disable notify/indicate |

> **Why the 500 ms delay in `connect()`?** Android's GATT stack needs a brief settling window after the connection is established before `readCharacteristic()` will succeed. Skipping it causes `gatt.readCharacteristic() returned false` on the first read.

### `ScannerCubit` (`lib/features/shop/bloc/scanner_cubit.dart`)
Drives all BLE UI state. Key behaviours:

- **`initScan()`** — requests permissions → enables BT if off → starts scan.
- **`connect(device)`** — sets `connectingDeviceId` (per-device loading, not global) → connects → emits `connected` with discovered services.
- **`readCharacteristic(c)`** — retries up to **3 times** with 300 ms back-off before storing an error message in `characteristicErrors`.
- Adapter state changes (BT turned off) automatically clear the connected device.

### `ScannerState` fields
```dart
ScannerStatus status
List<ScanResult> devices
BluetoothDevice? connectedDevice
String? connectingDeviceId       // which card is showing a spinner
List<BluetoothService> services
Map<String, List<int>> characteristicValues   // keyed by raw UUID string
Set<String> loadingCharacteristics
Map<String, String> characteristicErrors      // keyed by raw UUID string
BluetoothAdapterState adapterState
```

---

## 🔩 Modbus over BLE — Next Implementation

The HIU exposes Modbus registers through a custom GATT service. The app must support:

### Read
Request the current value of one or more registers. Encodes a Modbus Read Holding Registers (FC03) or Read Input Registers (FC04) PDU, writes it to the Modbus command characteristic, and reads back the response characteristic.

### Write
Set the value of one or more registers. Encodes a Modbus Write Single Register (FC06) or Write Multiple Registers (FC16) PDU and writes it to the command characteristic.

### Stream
Subscribe to a Modbus notify characteristic to receive live register updates pushed by the device. Uses `setNotifications(c, true)` and listens to `characteristic.lastValueStream`.

### Implementation guidance
- Add a `ModbusService` in `lib/data/services/` that encodes/decodes raw Modbus PDUs as `List<int>`.
- Add a `ModbusCubit` (or extend `ScannerCubit`) in `lib/features/shop/bloc/` that exposes `readRegister`, `writeRegister`, and `streamRegister` methods.
- Register UUIDs for the HIU's Modbus service and characteristics in `lib/utils/constants/bluetooth_uuids.dart`.

---

## 🎨 Design & UX Principles
- **Zero-Training Experience**: Guided flows, no jargon exposed to the user.
- **Navigation Efficiency**: Maximum 2–3 taps to reach any function.
- **Visual Focus**: Minimal text, status at a glance.
- **White Label Support**: Theming must support multiple brand identities.

---

## 📝 Development Guidelines
1. **State via BLoC/Cubit** — no business logic in widgets.
2. **Type safety** — all models use `json_serializable`; immutable models use `freezed`.
3. **DI** — every service and repository injected via `GetIt`; annotate with `@lazySingleton` or `@injectable`.
4. **Offline first** — cache device data in Hive; app must not require internet for BLE operations.
5. **Security** — tokens in `flutter_secure_storage` only, never plain `SharedPreferences`.
6. **UUID keys** — always use `characteristic.characteristicUuid.toString()` (raw UUID) as map keys, never the human-readable name from `BluetoothUuids.mapUuids()`.

---

## 🚀 Current Status

- [x] Project structure established
- [x] Theming and utility layers
- [x] Migrated from GetX/http to BLoC/Dio/Retrofit stack
- [x] Authentication (login, secure token storage)
- [x] Hive local persistence
- [x] BLE scan, connect, disconnect
- [x] GATT service/characteristic explorer UI
- [x] Characteristic read with retry logic and per-characteristic error state
- [x] Value parsing (HEX, UTF-8, BOOL, UINT/SINT LE, decoded hex strings)
- [ ] Modbus over BLE — read, write, stream registers
- [ ] Guided commissioning flow
- [ ] FOTA firmware update
- [ ] External user management and RBAC
