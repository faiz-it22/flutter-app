# Project Overview: Fortes Energy Mobile Application (Enterprise Stack)

The **Fortes Energy Mobile App** serves as the central control system for the **Heat Interface Unit (HIU)**. Its primary purpose is to facilitate commissioning, service, and maintenance activities via **Bluetooth Low Energy (BLE)**.

---

## 🏗 Architecture & Structure
The project follows a **Feature-First / Clean Architecture** pattern, utilizing a "Military-Grade" enterprise stack for reliability and maintainability.

- **`lib/features/`**: Core logic divided by domain (Authentication, Commissioning, Diagnostics).
- **`lib/data/`**: Data layer handling persistence and networking.
  - `repositories/`: Abstracted data access.
  - `sources/`: Remote (Retrofit/Dio) and Local (Hive) data sources.
- **`lib/utils/`**: Utilities for Theming, Validation, Constants, and Logging.
- **`lib/common/`**: Reusable UI components following the **Fortes Design Language**.
- **`lib/init/`**: Dependency injection setup using `GetIt` and `Injectable`.

---

## 📶 Communication Protocols & Scope
- **In Scope**:
  - **BLE**: Local device interaction.
  - **Modbus over BLE**: Operations like Request All Single, Write All Single, and Request Multiple Registers.
  - **FOTA**: Firmware updates via Bluetooth.
- **Out of Scope**: Internet-based device control (local BLE only).

---

## 🛠 Tech Stack (Enterprise Revision)
- **State Management**: `flutter_bloc` (Cubit/Bloc) for predictable state.
- **Navigation**: `go_router` for declarative routing and deep linking.
- **Networking**: `dio` + `retrofit` for type-safe API calls.
- **Dependency Injection**: `get_it` + `injectable` for robust decoupling.
- **Persistence**: 
  - **`Hive`**: Lightweight and fast NoSQL database for local storage.
  - `flutter_secure_storage`: For sensitive tokens (Auth).
- **Serialization**: `freezed` + `json_serializable`.
- **UI & Styling**: Material 3, **Fortes Design System**, `iconsax_flutter`, `Poppins` font.
- **Monitoring**: `sentry_flutter` for crash reporting and performance.

---

## 🎨 Design & UX Principles
- **Zero-Training Experience**: Prioritizes ease of use and guided flows.
- **Navigation Efficiency**: Maximum 2-3 taps to reach any functionality.
- **Visual Focus**: Minimal text, high-quality assets.
- **White Label Support**: Multiple brands/white labels support.

---

## 📝 Development Guidelines
1. **Predictability**: Use `Bloc` for all complex states.
2. **Type Safety**: All API responses must be modeled using `freezed` and `json_serializable`.
3. **Decoupling**: Services and Repositories must be injected via `GetIt`.
4. **Offline First**: Use **`Hive`** to ensure app remains functional without internet.
5. **Security**: Never store tokens in plain text; use `flutter_secure_storage`.

---

## 🚀 Current Status
- [x] Project structure established.
- [x] Theming and Utility layers.
- [x] Migrated from GetX/http to BLoC/Dio/Retrofit stack.
- [x] Bluetooth Service and Scanner UI implementation.
- [x] Setting up Hive NoSQL Persistence.
- [ ] Implement BLE/Modbus communication layer.
- [ ] Develop Guided Commissioning flow.
- [ ] Integrate External User Management and RBAC.
