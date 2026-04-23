import 'package:flutter/material.dart';
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
    return Container(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      height: MediaQuery.of(context).size.height * 0.75,
      child: BlocBuilder<ScannerCubit, ScannerState>(
        builder: (context, state) {
          final isBusy = state.status == ScannerStatus.connecting ||
              state.status == ScannerStatus.disconnecting;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      state.isConnected
                          ? 'Connected: ${state.connectedDevice!.platformName.isNotEmpty ? state.connectedDevice!.platformName : 'Unknown HIU'}'
                          : 'Scan for HIU',
                      style: Theme.of(context).textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      if (state.status == ScannerStatus.loading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      if (!state.isConnected && !isBusy)
                        IconButton(
                          tooltip: 'Refresh',
                          onPressed: () =>
                              context.read<ScannerCubit>().initScan(),
                          icon: const Icon(Iconsax.refresh_copy),
                        ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Iconsax.close_circle_copy),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              // State-based content
              if (state.status == ScannerStatus.bluetoothDisabled)
                _buildErrorState(
                  context,
                  icon: Iconsax.bluetooth_copy,
                  message: 'Bluetooth is turned off.',
                  buttonText: 'Turn On',
                  onPressed: () => context.read<ScannerCubit>().initScan(),
                )
              else if (state.status == ScannerStatus.permissionDenied)
                _buildErrorState(
                  context,
                  icon: Iconsax.security_safe_copy,
                  message: 'Bluetooth permissions are required.',
                  buttonText: 'Grant Permissions',
                  onPressed: () => context.read<ScannerCubit>().initScan(),
                )
              else if (state.status == ScannerStatus.success &&
                  state.devices.isEmpty &&
                  !state.isConnected)
                _buildErrorState(
                  context,
                  icon: Iconsax.search_normal_copy,
                  message: 'No HIU devices found nearby.',
                  buttonText: 'Rescan',
                  onPressed: () =>
                      context.read<ScannerCubit>().startScanning(),
                )
              else if (state.isConnected)
                _buildConnectedView(context, state)
              else
                _buildDeviceList(context, state, isBusy),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeviceList(
      BuildContext context, ScannerState state, bool isBusy) {
    return Expanded(
      child: ListView.separated(
        itemCount: state.devices.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: TSizes.spaceBtwItems),
        itemBuilder: (context, index) {
          final device = state.devices[index].device;
          return ListTile(
            leading: const CircleAvatar(child: Icon(Iconsax.cpu_copy)),
            title: Text(
              device.platformName.isNotEmpty
                  ? device.platformName
                  : 'Unknown HIU',
            ),
            subtitle: Text(device.remoteId.toString()),
            trailing: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
              child: ElevatedButton(
                onPressed: isBusy
                    ? null
                    : () => context.read<ScannerCubit>().connect(device),
                child: isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Connect'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectedView(BuildContext context, ScannerState state) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: state.status == ScannerStatus.disconnecting
                    ? null
                    : () => context.read<ScannerCubit>().disconnect(),
                icon: const Icon(Iconsax.bluetooth_copy),
                label: state.status == ScannerStatus.disconnecting
                    ? const Text('Disconnecting...')
                    : const Text('Disconnect'),
                style:
                    OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text('Services & Characteristics',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: TSizes.spaceBtwItems),
          Expanded(
            child: state.services.isEmpty
                ? const Center(child: Text('No services discovered.'))
                : ListView.builder(
                    itemCount: state.services.length,
                    itemBuilder: (context, sIndex) {
                      return _ServiceTile(
                        service: state.services[sIndex],
                        state: state,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: TColors.primary),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                  onPressed: onPressed, child: Text(buttonText)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.state});

  final BluetoothService service;
  final ScannerState state;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Iconsax.cpu_copy),
      title: Text(
        BluetoothUuids.mapUuids(service.serviceUuid.toString()),
        style: Theme.of(context).textTheme.bodySmall,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('${service.characteristics.length} characteristics'),
      children: service.characteristics
          .map((char) => _CharacteristicTile(characteristic: char, state: state))
          .toList(),
    );
  }
}

class _CharacteristicTile extends StatelessWidget {
  const _CharacteristicTile(
      {required this.characteristic, required this.state});

  final BluetoothCharacteristic characteristic;
  final ScannerState state;

  @override
  Widget build(BuildContext context) {
    final uuid = BluetoothUuids.mapUuids(characteristic.characteristicUuid.toString());
    final isLoading = state.loadingCharacteristics.contains(uuid);
    final value = state.characteristicValues[uuid];

    final props = [
      if (characteristic.properties.read) 'Read',
      if (characteristic.properties.write) 'Write',
      if (characteristic.properties.notify) 'Notify',
      if (characteristic.properties.indicate) 'Indicate',
    ];

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      title: Text(
        uuid,
        style: Theme.of(context).textTheme.bodySmall,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (props.isNotEmpty)
            Text(
              props.join(' · '),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          if (value != null)
            Text(
              'Value: ${value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: TColors.primary),
            ),
        ],
      ),
      trailing: characteristic.properties.read
          ? isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Iconsax.refresh_copy, size: 18),
                  tooltip: 'Read value',
                  onPressed: () => context
                      .read<ScannerCubit>()
                      .readCharacteristic(characteristic),
                )
          : null,
      onTap: characteristic.properties.read
          ? () => context
              .read<ScannerCubit>()
              .readCharacteristic(characteristic)
          : null,
    );
  }
}
