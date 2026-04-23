import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:projects/features/shop/bloc/scanner_cubit.dart';
import 'package:projects/utils/constants/bluetooth_uuids.dart';
import 'package:projects/utils/constants/colors.dart';
import 'package:projects/utils/constants/sizes.dart';

class ScannerBottomSheet extends StatelessWidget {
  const ScannerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: BlocBuilder<ScannerCubit, ScannerState>(
            builder: (context, state) {
              final isBusy = state.status == ScannerStatus.connecting ||
                  state.status == ScannerStatus.disconnecting;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        TSizes.defaultSpace, 12, TSizes.defaultSpace, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.isConnected
                                    ? 'Connected Device'
                                    : 'Scan for Devices',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (state.isConnected)
                                Text(
                                  state.connectedDevice!.platformName.isNotEmpty
                                      ? state.connectedDevice!.platformName
                                      : state.connectedDevice!.remoteId
                                          .toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.green),
                                ),
                            ],
                          ),
                        ),
                        if (state.status == ScannerStatus.loading ||
                            state.status == ScannerStatus.connecting)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        if (!state.isConnected && !isBusy)
                          IconButton(
                            tooltip: 'Refresh scan',
                            onPressed: () =>
                                context.read<ScannerCubit>().initScan(),
                            icon: const Icon(Iconsax.refresh_copy),
                          ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: _buildContent(
                        context, state, isBusy, scrollController),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    ScannerState state,
    bool isBusy,
    ScrollController scrollController,
  ) {
    if (state.status == ScannerStatus.bluetoothDisabled) {
      return _EmptyState(
        icon: Iconsax.bluetooth_copy,
        title: 'Bluetooth is Off',
        message: 'Enable Bluetooth to scan for nearby devices.',
        buttonText: 'Turn On Bluetooth',
        onPressed: () => context.read<ScannerCubit>().initScan(),
      );
    }

    if (state.status == ScannerStatus.permissionDenied) {
      return _EmptyState(
        icon: Iconsax.security_safe_copy,
        title: 'Permission Required',
        message: 'Bluetooth access is needed to discover devices.',
        buttonText: 'Grant Access',
        onPressed: () => context.read<ScannerCubit>().initScan(),
      );
    }

    if (state.status == ScannerStatus.failure) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Connection Failed',
        message:
            state.errorMessage ?? 'Something went wrong. Please try again.',
        buttonText: 'Try Again',
        onPressed: () => context.read<ScannerCubit>().initScan(),
      );
    }

    if (state.isConnected) {
      return _ConnectedView(state: state, scrollController: scrollController);
    }

    if (state.status == ScannerStatus.loading && state.devices.isEmpty) {
      return const _ScanningState();
    }

    if (state.status == ScannerStatus.success && state.devices.isEmpty) {
      return _EmptyState(
        icon: Iconsax.search_normal_copy,
        title: 'No Devices Found',
        message: 'Make sure your HIU device is powered on and nearby.',
        buttonText: 'Scan Again',
        onPressed: () => context.read<ScannerCubit>().startScanning(),
      );
    }

    return _DeviceList(
      state: state,
      isBusy: isBusy,
      scrollController: scrollController,
    );
  }
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

class _ScanningState extends StatelessWidget {
  const _ScanningState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: TSizes.spaceBtwItems),
          Text('Scanning for devices...'),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: TColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: TColors.primary),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Device list
// ---------------------------------------------------------------------------

class _DeviceList extends StatelessWidget {
  const _DeviceList({
    required this.state,
    required this.isBusy,
    required this.scrollController,
  });

  final ScannerState state;
  final bool isBusy;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.defaultSpace, vertical: 4),
      itemCount: state.devices.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final result = state.devices[index];
        final device = result.device;
        final name = device.platformName.isNotEmpty
            ? device.platformName
            : 'Unknown Device';

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: TColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.cpu_copy, color: TColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        device.remoteId.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _RssiBars(rssi: result.rssi),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: isBusy
                      ? null
                      : () =>
                          context.read<ScannerCubit>().connect(device),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Connect'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RssiBars extends StatelessWidget {
  const _RssiBars({required this.rssi});
  final int rssi;

  @override
  Widget build(BuildContext context) {
    final strength = rssi >= -60 ? 3 : rssi >= -75 ? 2 : 1;
    final color = strength == 3
        ? Colors.green
        : strength == 2
            ? Colors.orange
            : Colors.red;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              Container(
                width: 4,
                height: 6.0 + i * 4.0,
                decoration: BoxDecoration(
                  color: i < strength ? color : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '$rssi',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 9,
              ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Connected view
// ---------------------------------------------------------------------------

class _ConnectedView extends StatelessWidget {
  const _ConnectedView(
      {required this.state, required this.scrollController});

  final ScannerState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: state.status == ScannerStatus.disconnecting
                  ? null
                  : () => context.read<ScannerCubit>().disconnect(),
              icon: const Icon(Icons.bluetooth_disabled_rounded, size: 18),
              label: state.status == ScannerStatus.disconnecting
                  ? const Text('Disconnecting...')
                  : const Text('Disconnect'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: Text(
            'Services & Characteristics',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: state.services.isEmpty
              ? const Center(child: Text('No services discovered.'))
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: TSizes.defaultSpace, vertical: 4),
                  itemCount: state.services.length,
                  itemBuilder: (context, index) => _ServiceTile(
                    service: state.services[index],
                    state: state,
                  ),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Service tile
// ---------------------------------------------------------------------------

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.state});

  final BluetoothService service;
  final ScannerState state;

  @override
  Widget build(BuildContext context) {
    final rawUuid = service.serviceUuid.toString();
    final serviceName = BluetoothUuids.mapUuids(rawUuid);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        side:
            BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ExpansionTile(
        shape: const Border(),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: TColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              const Icon(Iconsax.cpu_copy, size: 18, color: TColors.primary),
        ),
        title: Text(
          serviceName,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          rawUuid.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
          overflow: TextOverflow.ellipsis,
        ),
        children: service.characteristics
            .map((char) =>
                _CharacteristicTile(characteristic: char, state: state))
            .toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Characteristic tile
// ---------------------------------------------------------------------------

class _CharacteristicTile extends StatelessWidget {
  const _CharacteristicTile(
      {required this.characteristic, required this.state});

  final BluetoothCharacteristic characteristic;
  final ScannerState state;

  @override
  Widget build(BuildContext context) {
    final rawUuid = characteristic.characteristicUuid.toString();
    final displayName = BluetoothUuids.mapUuids(rawUuid);
    final isLoading = state.loadingCharacteristics.contains(rawUuid);
    final value = state.characteristicValues[rawUuid];

    final props = [
      if (characteristic.properties.read) 'Read',
      if (characteristic.properties.write) 'Write',
      if (characteristic.properties.notify) 'Notify',
      if (characteristic.properties.indicate) 'Indicate',
    ];

    return InkWell(
      onTap: characteristic.properties.read ? () => _onTap(context) : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 50),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children:
                        props.map((p) => _PropChip(label: p)).toList(),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _hexString(value),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: TColors.primary,
                              fontFamily: 'monospace',
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (characteristic.properties.read)
              isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: Icon(
                        value == null
                            ? Iconsax.eye_copy
                            : Iconsax.refresh_copy,
                        size: 18,
                      ),
                      tooltip: value == null ? 'Read value' : 'Re-read',
                      onPressed: () => context
                          .read<ScannerCubit>()
                          .readCharacteristic(characteristic),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                          minWidth: 32, minHeight: 32),
                    ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    final rawUuid = characteristic.characteristicUuid.toString();
    if (state.characteristicValues[rawUuid] == null) {
      context.read<ScannerCubit>().readCharacteristic(characteristic);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ScannerCubit>(),
        child: _CharacteristicDetailSheet(characteristic: characteristic),
      ),
    );
  }

  String _hexString(List<int> bytes) => bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join(' ')
      .toUpperCase();
}

// ---------------------------------------------------------------------------
// Property chip
// ---------------------------------------------------------------------------

class _PropChip extends StatelessWidget {
  const _PropChip({required this.label});
  final String label;

  static const Map<String, Color> _colors = {
    'Read': Color(0xFF1976D2),
    'Write': Color(0xFF388E3C),
    'Notify': Color(0xFFF57C00),
    'Indicate': Color(0xFF7B1FA2),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[label] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Characteristic detail sheet
// ---------------------------------------------------------------------------

class _CharacteristicDetailSheet extends StatelessWidget {
  const _CharacteristicDetailSheet({required this.characteristic});
  final BluetoothCharacteristic characteristic;

  @override
  Widget build(BuildContext context) {
    final rawUuid = characteristic.characteristicUuid.toString();
    final displayName = BluetoothUuids.mapUuids(rawUuid);

    return BlocBuilder<ScannerCubit, ScannerState>(
      builder: (context, state) {
        final isLoading = state.loadingCharacteristics.contains(rawUuid);
        final value = state.characteristicValues[rawUuid];

        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                displayName,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                rawUuid.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (characteristic.properties.read)
                    const _PropChip(label: 'Read'),
                  if (characteristic.properties.write)
                    const _PropChip(label: 'Write'),
                  if (characteristic.properties.notify)
                    const _PropChip(label: 'Notify'),
                  if (characteristic.properties.indicate)
                    const _PropChip(label: 'Indicate'),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (value != null) ...[
                _ValueRow(title: 'HEX', value: _hexString(value)),
                const SizedBox(height: 10),
                _ValueRow(title: 'UTF-8', value: _utf8String(value)),
                if (value.length <= 4) ...[
                  const SizedBox(height: 10),
                  _ValueRow(
                      title: 'INT (LE)', value: _leInt(value).toString()),
                ],
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      characteristic.properties.read
                          ? 'Tap "Read Value" to fetch data'
                          : 'This characteristic is not readable',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              if (characteristic.properties.read) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => context
                            .read<ScannerCubit>()
                            .readCharacteristic(characteristic),
                    icon: const Icon(Iconsax.refresh_copy, size: 18),
                    label: Text(value == null ? 'Read Value' : 'Re-read'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _hexString(List<int> bytes) => bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join(' ')
      .toUpperCase();

  String _utf8String(List<int> bytes) {
    try {
      final s = utf8.decode(bytes);
      return s.isEmpty ? '(empty)' : s;
    } catch (_) {
      return '(not valid UTF-8)';
    }
  }

  int _leInt(List<int> bytes) {
    int result = 0;
    for (int i = bytes.length - 1; i >= 0; i--) {
      result = (result << 8) | (bytes[i] & 0xFF);
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// Value row with copy button
// ---------------------------------------------------------------------------

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontFamily: 'monospace'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
