import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:projects/features/shop/bloc/scanner_cubit.dart';
import 'package:projects/init/injection.dart';
import 'package:projects/utils/constants/colors.dart';
import 'package:projects/utils/constants/sizes.dart';

class ScannerBottomSheet extends StatelessWidget {
  const ScannerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ScannerCubit>()..initScan(),
      child: Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        height: MediaQuery.of(context).size.height * 0.6,
        child: BlocBuilder<ScannerCubit, ScannerState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Scan for HIU', style: Theme.of(context).textTheme.headlineSmall),
                    if (state.status == ScannerStatus.loading)
                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Iconsax.close_circle_copy)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: TSizes.spaceBtwItems),
                
                // Handle different states
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
                else if (state.status == ScannerStatus.success && state.devices.isEmpty)
                  _buildErrorState(
                    context,
                    icon: Iconsax.search_normal_copy,
                    message: 'No HIU devices found nearby.',
                    buttonText: 'Rescan',
                    onPressed: () => context.read<ScannerCubit>().startScanning(),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.devices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
                      itemBuilder: (context, index) {
                        final device = state.devices[index].device;
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Iconsax.cpu_copy)),
                          title: Text(device.platformName.isNotEmpty ? device.platformName : 'Unknown HIU'),
                          subtitle: Text(device.remoteId.toString()),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Handle Connection Logic
                            },
                            child: const Text('Connect'),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, {required IconData icon, required String message, required String buttonText, required VoidCallback onPressed}) {
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
              child: ElevatedButton(onPressed: onPressed, child: Text(buttonText)),
            ),
          ],
        ),
      ),
    );
  }
}
